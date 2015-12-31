defmodule UwOsuStat.Data do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsuStat.Osu
  alias UwOsuStat.Models.Event
  alias UwOsuStat.Models.Generation
  alias UwOsuStat.Models.Score
  alias UwOsuStat.Models.User
  alias UwOsuStat.Models.UserSnapshot
  alias UwOsuStat.Repo

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
    %HTTPoison.Response{body: [user | _]} = Osu.get_user!(user_id_or_username, client)

    # Insert into user table if the user is not already there
    {id, _} = Integer.parse(user["user_id"])
    case Repo.get(User, id) do
      nil ->
        Repo.insert!(%User{id: id})
      _ ->
    end

    username = user["username"]
    Logger.info "Processing for user #{username} (#{id}) with generation #{generation_id}"

    # Create snapshot
    snapshot_dict = Dict.merge user, %{
      "user_id" => id,
      "generation_id" => generation_id,
    }
    snapshot = UserSnapshot.changeset(%UserSnapshot{}, snapshot_dict)
    Repo.insert!(snapshot)

    Enum.each(user["events"], fn(event_dict) ->
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
      beatmap_id = score_dict["beatmap_id"]
      {:ok, date} = Ecto.DateTime.cast(score_dict["date"])

      query = from s in Score,
        where: s.user_id == ^id
          and s.date == ^date

      case Repo.one(query) do
        nil ->
          score_dict = Dict.merge score_dict, %{
            "user_id" => id,
            "beatmap_id" => beatmap_id,
            "date" => date,
          }
          score = Score.changeset(%Score{}, score_dict)
          Repo.insert(score)
        _ ->
          :ok
      end
    end)
  end
end

