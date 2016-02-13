defmodule BeatmapCollectionTest do
  use UwOsu.ModelCase
  import Ecto.Query, only: [from: 2]
  import UwOsu.RepoHelper
  alias UwOsu.ApiData
  alias UwOsu.Data.BeatmapCollection
  alias UwOsu.Models.Beatmap
  alias UwOsu.Osu
  alias UwOsu.Repo
  import Mock
  doctest UwOsu.Data.BeatmapCollection

  test_with_mock "collect beatmaps", Osu, [
    start: fn -> end,
    get_beatmaps!: fn(%Osu.Client{api_key: "abc"}, b: 234) ->
      %HTTPoison.Response{body: [
        ApiData.beatmap(%{
          "beatmap_id" => "234",
          "beatmapset_id" => "123456",
          "version" => "Overkill",
        }),
      ]}
    end
  ] do
    count_query = from b in Beatmap,
      where: b.id == 234,
      select: count(b.id)
    assert Repo.one!(count_query) == 0

    # insert a score that points to the 234 beatmap
    insert_user! %{id: 1}
    insert_score! %{
      "beatmap_id" => "234",
      "user_id" => 1,
    }

    BeatmapCollection.collect_beatmaps(%Osu.Client{api_key: "abc"})

    assert Repo.one!(count_query) == 1

    beatmap = Repo.get!(Beatmap, 234)
    assert beatmap.approved == 1
    assert beatmap.approved_date == Ecto.DateTime.cast("2013-07-02 01:01:12") |> elem(1)
    assert beatmap.last_update == Ecto.DateTime.cast("2013-07-06 16:51:22") |> elem(1)
    assert beatmap.artist == "Luxion"
    assert beatmap.beatmapset_id == 123456
    assert beatmap.bpm == 196.5
    assert beatmap.creator == "RikiH"
    assert beatmap.difficultyrating == 5.59516
    assert beatmap.diff_size == 3.8
    assert beatmap.diff_overall == 6.01
    assert beatmap.diff_approach == 9.2
    assert beatmap.diff_drain == 6.7
    assert beatmap.hit_length == 113
    assert beatmap.source == "BMS"
    assert beatmap.genre_id == 1
    assert beatmap.language_id == 5
    assert beatmap.title == "High-Priestess"
    assert beatmap.total_length == 145
    assert beatmap.version == "Overkill"
    assert beatmap.file_md5 == "c8f08438204abfcdd1a748ebfae67421"
    assert beatmap.mode == 0
    assert beatmap.tags == "melodious long"
    assert beatmap.favourite_count == 121
    assert beatmap.playcount == 9001
    assert beatmap.passcount == 1337
    assert beatmap.max_combo == 2101
  end

  test_with_mock "collect beatmaps only collects for distinct beatmap ids", Osu, [
    start: fn -> end,
    get_beatmaps!: fn(%Osu.Client{api_key: "abc"}, b: 234) ->
      %HTTPoison.Response{body: [
        ApiData.beatmap(%{
          "beatmap_id" => "234",
          "beatmapset_id" => "123456",
          "version" => "Overkill",
        }),
      ]}
    end
  ] do
    count_query = from b in Beatmap,
      where: b.id == 234,
      select: count(b.id)
    assert Repo.one!(count_query) == 0

    # insert two scores that point to the 234 beatmap
    insert_user! %{id: 1}
    insert_user! %{id: 2}
    insert_score! %{
      "beatmap_id" => "234",
      "user_id" => 1,
    }
    insert_score! %{
      "beatmap_id" => "234",
      "user_id" => 2,
    }

    BeatmapCollection.collect_beatmaps %Osu.Client{api_key: "abc"}

    assert Repo.one!(count_query) == 1
  end

  test_with_mock "collect beatmaps does not collect a beatmap that already is in db", Osu, [
    start: fn -> end,
  ] do
    count_query = from b in Beatmap,
      where: b.id == 234,
      select: count(b.id)
    assert Repo.one!(count_query) == 0

    insert_beatmap! %{
      "id" => "234",
      "beatmapset_id" => "123456",
      "version" => "Overkill",
    }

    assert Repo.one!(count_query) == 1

    # insert a score that points to the 234 beatmap
    insert_user! %{id: 1}
    insert_score! %{
      "beatmap_id" => "234",
      "user_id" => 1,
    }

    BeatmapCollection.collect_beatmaps %Osu.Client{api_key: "abc"}
  end
end

