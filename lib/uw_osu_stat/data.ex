defmodule UwOsuStat.Data do
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

    Repo.transaction(fn ->
      generation_id = Repo.insert!(%Generation{}).id
      Enum.each(user_ids, fn(user_id) ->
        Repo.transaction(fn ->
          process_user(user_id, generation_id, client)
        end)
      end)
    end)
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
    IO.puts "Processing for user #{username} (#{id}) with generation #{generation_id}"

    # Create snapshot
    snapshot = %UserSnapshot{
      user_id: id,
      generation_id: generation_id,
      username: user["username"],
      count300: elem(Integer.parse(user["count300"]), 0),
      count100: elem(Integer.parse(user["count100"]), 0),
      count50: elem(Integer.parse(user["count50"]), 0),
      playcount: elem(Integer.parse(user["playcount"]), 0),
      ranked_score: elem(Integer.parse(user["ranked_score"]), 0),
      total_score: elem(Integer.parse(user["total_score"]), 0),
      pp_rank: elem(Integer.parse(user["pp_rank"]), 0),
      level: elem(Float.parse(user["level"]), 0),
      pp_raw: elem(Float.parse(user["pp_raw"]), 0),
      accuracy: elem(Float.parse(user["accuracy"]), 0),
      count_rank_ss: elem(Integer.parse(user["count_rank_ss"]), 0),
      count_rank_s: elem(Integer.parse(user["count_rank_s"]), 0),
      count_rank_a: elem(Integer.parse(user["count_rank_a"]), 0),
      country: user["country"],
      pp_country_rank: elem(Integer.parse(user["pp_country_rank"]), 0),
    }
    Repo.insert!(snapshot)

    Enum.each(user["events"], fn(event_dict) ->
      beatmap_id = elem(Integer.parse(event_dict["beatmap_id"]), 0)
      date = String.replace(event_dict["date"], " ", "T")
      {:ok, date} = Ecto.DateTime.cast(date <> "Z")

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
            beatmapset_id: elem(Integer.parse(event_dict["beatmapset_id"]), 0),
            date: date,
            epicfactor: elem(Integer.parse(event_dict["epicfactor"]), 0),
          })
          Repo.insert(event)
        _ ->
          :ok
      end
    end)

    # Get user scores
    %HTTPoison.Response{body: scores} = Osu.get_user_best!(user_id_or_username, client)

    Enum.each(scores, fn(score_dict) ->
      beatmap_id = elem(Integer.parse(score_dict["beatmap_id"]), 0)
      date = String.replace(score_dict["date"], " ", "T")
      {:ok, date} = Ecto.DateTime.cast(date <> "Z")

      query = from s in Score,
        where: s.user_id == ^id
          and s.date == ^date

      case Repo.one(query) do
        nil ->
          score = %Score{
            user_id: id,
            beatmap_id: beatmap_id,
            score: parse_int(score_dict["score"]),
            date: date,
            maxcombo: parse_int(score_dict["maxcombo"]),
            count50: parse_int(score_dict["count50"]),
            count100: parse_int(score_dict["count100"]),
            count300: parse_int(score_dict["count300"]),
            countmiss: parse_int(score_dict["countmiss"]),
            countkatu: parse_int(score_dict["countkatu"]),
            countgeki: parse_int(score_dict["countgeki"]),
            perfect: parse_int(score_dict["perfect"]),
            enabled_mods: parse_int(score_dict["enabled_mods"]),
            rank: score_dict["rank"],
            pp: parse_float(score_dict["pp"]),
          }
          Repo.insert(score)
        _ ->
          :ok
      end
    end)
  end

  defp parse_int(val) do
    {int, _} = Integer.parse(val)
    int
  end

  defp parse_float(val) do
    {float, _} = Float.parse(val)
    float
  end
end

