defmodule UwOsu.Data.UserCollection do
  import Ecto.Query, only: [from: 2]
  require Logger
  alias UwOsu.Osu
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Score
  alias UwOsu.Models.User
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Repo

  def collect(
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
  ) do
    modes = [0, 1, 2, 3]
    Enum.each(modes, fn(mode) ->
      collect_mode mode, client
    end)
  end

  def collect_mode(
    mode,
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)},
    attempts_remaining \\ 10
  ) do
    if attempts_remaining > 0 do
      attempt_number = 10 - attempts_remaining + 1
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

        Repo.transaction([timeout: 120000, pool_timeout: 120000], fn ->
          changeset = Generation.changeset(%Generation{}, %{
            mode: mode,
          })
          generation = Repo.insert!(changeset)
          generation_id = generation.id
          Logger.info "Generation #{generation_id}"

          Enum.each user_ids, fn(user_id) ->
            process_user(user_id, generation, client)
          end
        end)
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
    } = Osu.get_user!(client, user_id, m: generation.mode)

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
    } = Osu.get_user_best!(client, id, m: generation.mode)

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

