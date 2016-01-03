defmodule UwOsuStat.Data do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsuStat.Osu
  alias UwOsuStat.Models.Beatmap
  alias UwOsuStat.Models.Event
  alias UwOsuStat.Models.Generation
  alias UwOsuStat.Models.Score
  alias UwOsuStat.Models.User
  alias UwOsuStat.Models.UserSnapshot
  alias UwOsuStat.Repo

  def get_daily_generations do
    from g in Generation,
      join: i in fragment("SELECT MIN(inserted_at) FROM generation WHERE inserted_at::time >= '5:00' GROUP BY inserted_at::date"),
      on: g.inserted_at == i.min,
      select: g
  end

  def collect_beatmaps(
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu_stat, :osu_api_key)}
  ) do
    Osu.start
    Logger.debug "Using API key #{client.api_key}"

    query = from s in Score,
      distinct: s.beatmap_id,
      left_join: b in Beatmap, on: s.beatmap_id == b.id,
      where: is_nil(b.id),
      select: s.beatmap_id

    beatmap_ids = Repo.all(query)

    Logger.info "Fetching #{length beatmap_ids} beatmaps"

    Enum.each beatmap_ids, fn(beatmap_id) ->
      Logger.info "Fetching #{beatmap_id}"
      %HTTPoison.Response{body: [beatmap | _]} = Osu.get_beatmaps!(%{b: beatmap_id}, client)
      beatmap = Dict.merge beatmap, %{
        "id" => beatmap["beatmap_id"]
      }
      beatmap = Dict.delete beatmap, "beatmap_id"
      Repo.insert!(Beatmap.changeset(%Beatmap{}, beatmap))
    end
  end

  def collect(
    user_ids \\ Application.get_env(:uw_osu_stat, :user_ids),
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu_stat, :osu_api_key)}
  ) do
    Osu.start

    Repo.transaction fn ->
      generation_id = Repo.insert!(%Generation{}).id

      Enum.each user_ids, fn(user_id) ->
        Repo.transaction fn ->
          process_user(user_id, generation_id, client)
        end
      end
    end
  end

  defp process_user(user_id_or_username, generation_id, client) do
    # Get user
    %HTTPoison.Response{body: [user_dict | _]} = Osu.get_user!(user_id_or_username, client)

    # Insert into user table if the user is not already there
    id = user_dict["user_id"]
    user = case Repo.get(User, id) do
      nil ->
        changeset = User.changeset %User{}, %{id: id}
        Repo.insert! changeset
      user ->
        user
    end

    username = user_dict["username"]
    Logger.info "Processing for user #{username} (#{id}) with generation #{generation_id}"

    # Update username
    Repo.update! Ecto.Changeset.change(user, username: username)

    # Create snapshot
    snapshot_dict = Dict.merge user_dict, %{
      "user_id" => id,
      "generation_id" => generation_id,
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
    %HTTPoison.Response{body: scores} = Osu.get_user_best!(user_id_or_username, client)

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

