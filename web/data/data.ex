defmodule UwOsu.Data do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsu.Osu
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Group
  alias UwOsu.Models.Score
  alias UwOsu.Models.User
  alias UwOsu.Models.UserGroup
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Repo

  def get_users(group_id) do
    from u in User,
      join: s in assoc(u, :snapshots),
      join: g in assoc(s, :generation),
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: gr.id == ugr.group_id and gr.mode == g.mode,
      where: s.generation_id in fragment("(
        SELECT g.id
        FROM generation g
        WHERE g.mode = (?)
        ORDER BY inserted_at DESC
        LIMIT 1
      )", g.mode),
      order_by: [desc: s.pp_raw],
      preload: [snapshots: s]
  end

  def get_users_with_snapshots(group_id) do
    from u in User,
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id,
      join: s in UserSnapshot,
        on: s.user_id == u.id,
      join: g in Generation,
        on: s.generation_id == g.id and g.mode == gr.mode,
      join: i in fragment("
      SELECT MIN(s.inserted_at), s.user_id, g.mode
      FROM user_snapshot s
      JOIN generation g
      ON s.generation_id = g.id
      WHERE s.inserted_at::time >= '5:00'
      GROUP BY s.inserted_at::date, s.user_id, g.mode
      "),
        on: s.inserted_at == i.min
        and s.user_id == i.user_id
        and i.mode == gr.mode,
      order_by: [asc: s.inserted_at],
      preload: [snapshots: s]
  end

  def get_weekly_snapshots do
    from s1 in UserSnapshot,
      join: g1 in assoc(s1, :generation),
      join: s2 in UserSnapshot,
      join: g2 in assoc(s2, :generation),
      where: s1.user_id == s2.user_id and fragment("(?)::date = '2016-01-06'", g1.inserted_at) and
        g2.inserted_at == fragment("
        (SELECT MIN(g.inserted_at)
        FROM generation g
        JOIN user_snapshot s
        ON s.user_id = (?) AND s.generation_id = g.id
        WHERE g.inserted_at::date >= '2015-12-30')
          ", s1.user_id),
      select: {
        s1,
        s2,
        %{
          "playcount" => fragment("(?) - (?)", s1.playcount, s2.playcount),
          "pp_rank" => fragment("(?) - (?)", s1.pp_rank, s2.pp_rank),
          "level" => fragment("(?) - (?)", s1.level, s2.level),
          "pp_raw" => fragment("(?) - (?)", s1.pp_raw, s2.pp_raw),
          "accuracy" => fragment("(?) - (?)", s1.accuracy, s2.accuracy),
          "pp_country_rank" => fragment("(?) - (?)", s1.pp_country_rank, s2.pp_country_rank),
        },
      }
  end

  def get_farmed_beatmaps(group_id) do
    from b in Beatmap,
      join: sc_ in fragment("(
      SELECT *
      FROM (
        SELECT *,
          dense_rank()
          OVER (PARTITION BY mode ORDER BY score_count DESC) AS score_ranking
        FROM (
          SELECT *,
            count(*)
            OVER (PARTITION BY beatmap_id) AS score_count
          FROM (
            SELECT sc.*,
              b.mode,
              row_number()
              OVER (PARTITION BY sc.user_id, b.mode
                ORDER BY sc.pp DESC) AS ranking
            FROM (
              SELECT DISTINCT ON (sc.user_id, sc.beatmap_id) sc.*
              FROM score sc
              ORDER BY sc.user_id, sc.beatmap_id, sc.score DESC
            ) sc
            JOIN beatmap b
              ON sc.beatmap_id = b.id
          ) x
          WHERE ranking <= 100
        ) x
      ) x
      WHERE score_ranking <= 10
      )"),
        on: sc_.beatmap_id == b.id,
      join: sc in Score,
        on: sc.id == sc_.id,
      join: u in User,
        on: u.id == sc.user_id,
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id and gr.mode == b.mode,
      order_by: [desc: sc_.score_ranking],
      preload: [scores: {sc, user: u}],
      select: b
  end

  def get_latest_scores(group_id) do
    from u in User,
      join: s in assoc(u, :scores),
      join: b in assoc(s, :beatmap),
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id and b.mode == gr.mode,
      where: fragment("(?) >= '2016-01-01'", s.date) and fragment("(?) < '2016-02-01'", s.date),
      order_by: [desc: s.score],
      distinct: [u.id, s.beatmap_id],
      preload: [scores: {s, beatmap: b}]
  end

  def collect_beatmaps do
    Osu.start
    client = %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
    Logger.debug "Using API key #{client.api_key}"

    query = from s in Score,
      distinct: s.beatmap_id,
      left_join: b in Beatmap, on: s.beatmap_id == b.id,
      where: is_nil(b.id),
      select: s.beatmap_id

    beatmap_ids = Repo.all(query)

    Logger.info "Fetching #{length beatmap_ids} beatmaps"

    beatmap_ids
    |> Enum.chunk(100, 100, [])
    |> Enum.each(fn(beatmap_ids) ->
      Enum.each beatmap_ids, fn(beatmap_id) ->
        fetch_and_process_beatmap client, beatmap_id
      end
      :timer.sleep 30000 # sleep for 30 seconds
    end)
  end

  defp fetch_and_process_beatmap(client, beatmap_id, attempts_remaining) when attempts_remaining == 0 do
    Logger.error "Failed to fetch beatmap with id #{beatmap_id}"
  end

  defp fetch_and_process_beatmap(client, beatmap_id, attempts_remaining \\ 5) do
    Logger.debug "Fetching beatmap with id #{beatmap_id}"
    %HTTPoison.Response{body: body} = Osu.get_beatmaps!(%{b: beatmap_id}, client)
    case body do
      [beatmap | _] ->
        beatmap = Dict.merge beatmap, %{
          "id" => beatmap["beatmap_id"]
        }
        beatmap = Dict.delete beatmap, "beatmap_id"
        Repo.insert!(Beatmap.changeset(%Beatmap{}, beatmap))
      _ ->
        :timer.sleep 10000 # sleep for 10 seconds
        fetch_and_process_beatmap beatmap_id, attempts_remaining - 1
    end
  end

  def collect(
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
  ) do
    modes = [0, 1, 2, 3]
    Enum.each modes, fn(mode) ->
      collect_mode mode, client
    end
  end

  def collect_mode(
    mode,
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)},
    attempts_remaining \\ 5
  ) do
    if attempts_remaining > 0 do
      attempt_number = 5 - attempts_remaining + 1
      Logger.info "Beginning collection of mode #{mode} on try ##{attempt_number}"
      Osu.start

      try do
        query = from u in User,
          join: ugr in assoc(u, :user_groups),
          join: gr in assoc(ugr, :group),
          where: gr.mode == ^mode,
          distinct: [u.id],
          select: u.id
        user_ids = Repo.all query

        Repo.transaction fn ->
          changeset = Generation.changeset(%Generation{}, %{
            mode: mode,
          })
          generation = Repo.insert!(changeset)
          generation_id = generation.id
          Logger.info "Generation #{generation_id}"

          Enum.each user_ids, fn(user_id) ->
            Repo.transaction fn ->
              process_user(user_id, generation, client)
            end
          end
        end
        Logger.info "Successfully collected mode #{mode} on try ##{attempt_number}"
      rescue
        e ->
          # TODO: Pass error through logger
          IO.inspect e
          Logger.error "Failed to collect mode #{mode} on try ##{attempt_number}"
          :timer.sleep 10000
          collect_mode mode, client, attempts_remaining - 1
      end
    end
  end

  defp process_user(user_id, generation, client) do
    # Get user
    %HTTPoison.Response{
      body: body,
    } = Osu.get_user!(user_id, generation.mode, client)

    case body do
      [user_dict | _] ->
        case user_dict["count300"] do
          nil ->
            Logger.warn "Skipping user with id #{user_id} for mode #{generation.mode}"
          _ ->
            process_user_dict user_dict, generation, client
        end
      _ ->
        Logger.warn "Skipping user with id #{user_id} - get_user returned empty array"
    end
  end

  defp process_user_dict(user_dict, generation, client) do
    username = user_dict["username"]
    id = user_dict["user_id"]
    Logger.debug "Processing for user #{username} (#{id}) with generation #{generation.id}"

    # Update username
    user = Repo.get!(User, id)
    Repo.update! Ecto.Changeset.change(user, username: username)

    # Create snapshot
    snapshot_dict = Dict.merge user_dict, %{
      "user_id" => id,
      "generation_id" => generation.id
    }
    snapshot = UserSnapshot.changeset(%UserSnapshot{}, snapshot_dict)
    Repo.insert!(snapshot)

    Enum.each(user_dict["events"], fn(event_dict) ->
      beatmap_id = event_dict["beatmap_id"]
      date = event_dict["date"]

      query = from e in Event,
        where: e.user_id == ^id
          and e.beatmap_id == ^beatmap_id
          and e.date == ^date

      case Repo.one(query) do
        nil ->
          event = Event.changeset(%Event{}, %{
            user_id: id,
            display_html: event_dict["display_html"],
            beatmap_id: beatmap_id,
            beatmapset_id: event_dict["beatmapset_id"],
            date: date,
            epicfactor: event_dict["epicfactor"],
          })
          Repo.insert(event)
        _ ->
          :ok
      end
    end)

    # Get user scores
    %HTTPoison.Response{
      body: scores,
    } = Osu.get_user_best!(id, generation.mode, client)

    Enum.each(scores, fn(score_dict) ->
      {:ok, date} = Ecto.DateTime.cast(score_dict["date"])

      query = from s in Score,
        where: s.user_id == ^id
          and s.date == ^date

      case Repo.one(query) do
        nil ->
          score_dict = Dict.merge score_dict, %{
            "user_id" => id,
          }
          score = Score.changeset(%Score{}, score_dict)
          Repo.insert(score)
        _ ->
          :ok
      end
    end)
  end
end

