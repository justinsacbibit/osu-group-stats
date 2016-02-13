defmodule UwOsu.Data.BeatmapCollection do
  import Ecto.Query, only: [from: 2]
  require Logger
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

  def collect_beatmaps(client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}) do
    Osu.start
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
        fetch_and_process_beatmap client, beatmap_id, 5
      end
      unless Mix.env == :test do
        :timer.sleep 30000 # sleep for 30 seconds
      end
    end)
  end

  defp fetch_and_process_beatmap(_client, beatmap_id, attempts_remaining) when attempts_remaining == 0 do
    Logger.error "Failed to fetch beatmap with id #{beatmap_id}"
  end

  defp fetch_and_process_beatmap(client, beatmap_id, attempts_remaining) do
    Logger.debug "Fetching beatmap with id #{beatmap_id}"
    %HTTPoison.Response{body: body} = Osu.get_beatmaps!(client, b: beatmap_id)
    case body do
      [beatmap | _] ->
        beatmap = Dict.merge beatmap, %{
          "id" => beatmap["beatmap_id"]
        }
        beatmap = Dict.delete beatmap, "beatmap_id"
        Repo.insert!(Beatmap.changeset(%Beatmap{}, beatmap))
      _ ->
        :timer.sleep 10000 # sleep for 10 seconds
        fetch_and_process_beatmap client, beatmap_id, attempts_remaining - 1
    end
  end
end

