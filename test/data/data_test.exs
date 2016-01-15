defmodule DataTest do
  use UwOsu.ModelCase
  import Ecto.Query, only: [from: 2]
  import UwOsu.RepoHelper
  alias UwOsu.ApiData
  alias UwOsu.Repo
  alias UwOsu.Data
  alias UwOsu.Osu
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Event
  alias UwOsu.Models.User
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Models.Score
  alias Ecto.Adapters.SQL
  import Mock
  doctest UwOsu.Data

  defp get_next_generation_id do
    %{rows: [[next_generation_id]]} = SQL.query!(Repo, "select nextval('generation_id_seq')", [])
    next_generation_id + 1
  end

  defp invariant_check(next_generation_id, user_ids) do
    assert called Osu.start

    # should create generation
    Repo.get!(Generation, next_generation_id)

    Enum.map user_ids, fn(user_id) ->
      # should create user
      Repo.get!(User, user_id)
    end
  end

  test_with_mock "user username", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [ApiData.user]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    # should create user_snapshot
    user = Repo.get!(User, 123)
    assert user.username == "testuser"
  end

  test_with_mock "snapshot", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [ApiData.user]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    # should create user_snapshot
    snapshot = Repo.get_by!(UserSnapshot, user_id: 123, generation_id: next_generation_id)
    assert snapshot.username == "testuser"
    assert snapshot.count300 == 8260346
    assert snapshot.count100 == 639175
    assert snapshot.count50 == 63029
    assert snapshot.playcount == 45432
    assert snapshot.ranked_score == 13352117327
    assert snapshot.total_score == 70088502830
    assert snapshot.pp_rank == 2815
    assert snapshot.level == 100.432
    assert snapshot.pp_raw == 5033.02
    assert snapshot.accuracy == 99.01136779785156
    assert snapshot.count_rank_ss == 81
    assert snapshot.count_rank_s == 632
    assert snapshot.count_rank_a == 650
    assert snapshot.country == "CA"
    assert snapshot.pp_country_rank == 103
  end

  test_with_mock "events", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.user %{"events" => [ApiData.event]}
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    # should create event
    event = Repo.get_by!(Event, user_id: 123)
    assert event.display_html == "<img src='/images/S_small.png'/> <b><a href='/u/1579374'>influxd</a></b> achieved rank #998 on <a href='/b/696783?m=0'>AKINO from bless4 - MIIRO [Hime]</a> (osu!)"
    assert event.beatmap_id == 696783
    assert event.beatmapset_id == 312042
    assert event.date == Ecto.DateTime.cast("2015-12-31 14:31:35") |> elem(1)
    assert event.epicfactor == 1
  end

  test_with_mock "should not create duplicate event", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.user %{"events" => [ApiData.event, ApiData.event]}
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    query = from e in Event, select: count(e.id)
    assert Repo.one!(query) == 1
  end

  test_with_mock "scores", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.user
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.score
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    # should create score
    score = Repo.get_by!(Score, user_id: 123)
    assert score.beatmap_id == 759192
    assert score.score == 69954590
    assert score.maxcombo == 1768
    assert score.count50 == 0
    assert score.count100 == 16
    assert score.count300 == 1263
    assert score.countmiss == 1
    assert score.countkatu == 9
    assert score.countgeki == 203
    assert score.perfect == 0
    assert score.enabled_mods == 0
    assert score.date == Ecto.DateTime.cast("2015-12-28 04:25:55") |> elem(1)
    assert score.rank == "A"
    assert score.pp == 281.856
  end

  test_with_mock "should not create duplicate score", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.user
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.score,
        ApiData.score
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    query = from s in Score, select: count(s.id)
    assert Repo.one!(query) == 1
  end

  test_with_mock "only one generation is created per run", Osu, [
    start: fn -> end,
    get_user!: fn(id, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.user %{"user_id" => "#{id}"}
      ]} end,
    get_user_best!: fn(_id, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123, 456], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123, 456]

    query = from g in Generation, select: count(g.id)
    assert Repo.one!(query) == 1
  end

  test_with_mock "collect beatmaps", Osu, [
    start: fn -> end,
    get_beatmaps!: fn(%{b: 234}, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.beatmap(%{
          "beatmap_id" => "234",
          "beatmapset_id" => "123456",
          "version" => "Overkill",
        }),
      ]}
    end
  ] do
    count_query = from b in Beatmap, select: count(b.id), where: b.id == 234
    assert Repo.one!(count_query) == 0

    # insert a score that points to the 234 beatmap
    insert_user! %{id: 1}
    insert_score! %{
      "beatmap_id" => "234",
      "user_id" => 1,
    }

    Data.collect_beatmaps %Osu.Client{api_key: "abc"}

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
    get_beatmaps!: fn(%{b: 234}, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        ApiData.beatmap(%{
          "beatmap_id" => "234",
          "beatmapset_id" => "123456",
          "version" => "Overkill",
        }),
      ]}
    end
  ] do
    count_query = from b in Beatmap, select: count(b.id), where: b.id == 234
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

    Data.collect_beatmaps %Osu.Client{api_key: "abc"}

    assert Repo.one!(count_query) == 1
  end

  test_with_mock "collect beatmaps does not collect a beatmap that already is in db", Osu, [
    start: fn -> end,
  ] do
    count_query = from b in Beatmap, select: count(b.id), where: b.id == 234
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

    Data.collect_beatmaps %Osu.Client{api_key: "abc"}
  end

  # queries

  test "get daily generations" do
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-01-01 05:00:00",
      "updated_at" => "2015-01-01 05:00:00",
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-01-01 06:00:00",
      "updated_at" => "2015-01-01 06:00:00",
    }
    insert_generation! %{
      "id" => 3,
      "inserted_at" => "2015-01-02 05:00:00",
      "updated_at" => "2015-01-02 05:00:00",
    }

    generations = Repo.all Data.get_daily_generations

    assert length(generations) == 2

    gen1 = Enum.at(generations, 0)
    assert gen1.id == 1

    gen2 = Enum.at(generations, 1)
    assert gen2.id == 3
  end

  test "get users" do
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-01-01 05:00:00",
      "updated_at" => "2015-01-01 05:00:00",
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-01-01 06:00:00",
      "updated_at" => "2015-01-01 06:00:00",
    }
    insert_generation! %{
      "id" => 3,
      "inserted_at" => "2015-01-02 05:00:00",
      "updated_at" => "2015-01-02 05:00:00",
    }
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 1,
    }
    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 2,
    }
    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 3,
    }
    insert_user! %{
      "id" => 2,
      "username" => "a",
    }
    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 1,
    }
    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 2,
    }
      insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 3,
    }

    [u1, u2] = Repo.all Data.get_users

    [u1_snapshot] = u1.snapshots
    assert u1_snapshot.generation_id == 3

    [u2_snapshot] = u2.snapshots
    assert u2_snapshot.generation_id == 3
  end

  test "get weekly snapshots" do
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-12-30 05:00:00",
      "updated_at" => "2015-12-30 05:00:00",
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-12-31 06:00:00",
      "updated_at" => "2015-12-31 06:00:00",
    }
    insert_generation! %{
      "id" => 3,
      "inserted_at" => "2016-01-06 05:00:00",
      "updated_at" => "2016-01-06 05:00:00",
    }

    insert_user! %{
      "id" => 1,
    }

    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 1,
      "playcount" => 5,
      "pp_rank" => 1380,
      "level" => 100,
      "pp_raw" => 3000,
      "accuracy" => 98.98,
      "pp_country_rank" => 50,
    }

    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 2,
    }

    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 3,
      "playcount" => 11,
      "pp_rank" => 1360,
      "level" => 101,
      "pp_raw" => 3050,
      "accuracy" => 98.99,
      "pp_country_rank" => 49,
    }

    snapshot_tuples = Repo.all Data.get_weekly_snapshots

    assert length(snapshot_tuples) == 1

    [snapshot_tuple | _] = snapshot_tuples
    {s1, s2, %{
        "playcount" => playcount,
        "pp_rank" => pp_rank,
        "level" => level,
        "pp_raw" => pp_raw,
        "accuracy" => accuracy,
        "pp_country_rank" => pp_country_rank,
      }
    } = snapshot_tuple
    assert s1.generation_id == 3
    assert s2.generation_id == 1
    assert playcount == 6
    assert pp_rank == -20
    assert level == 1
    assert pp_raw == 50
    assert Float.round(accuracy, 2) == 0.01
    assert pp_country_rank == -1
  end

  test "get farmed beatmaps" do
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user! %{
      "id" => 2,
      "username" => "a",
    }
    insert_user! %{
      "id" => 3,
      "username" => "a",
    }
    insert_user! %{
      "id" => 4,
      "username" => "a",
    }
    insert_beatmap! %{
      "id" => 1,
    }
    insert_beatmap! %{
      "id" => 2,
    }
    insert_score! %{
      "beatmap_id" => 1,
      "user_id" => 1,
    }
    insert_score! %{
      "beatmap_id" => 1,
      "user_id" => 2,
    }
    insert_score! %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2015-01-01 05:00:00",
    }
    insert_score! %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2015-01-01 06:00:00",
    }
    # Duplicate (beatmap_id, user_id) may affect the beatmap ordering
    insert_score! %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2012-01-01 06:00:00",
    }

    [b1, b2] = Repo.all Data.get_farmed_beatmaps

    assert b1.id == 1
    assert length(b1.scores) == 2

    assert b2.id == 2
    assert length(b2.scores) == 1
  end
end
