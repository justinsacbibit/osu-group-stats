defmodule DataTest do
  use UwOsu.ModelCase
  import Ecto.Query, only: [from: 2]
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

  defp mock_user_dict(overrides \\ %{}) do
    default = %{
      "user_id" => "123",
      "username" => "testuser",
      "count300" => "8260346",
      "count100" => "639175",
      "count50" => "63029",
      "playcount" => "45432",
      "ranked_score" => "13352117327",
      "total_score" => "70088502830",
      "pp_rank" => "2815",
      "level" => "100.432",
      "pp_raw" => "5033.02",
      "accuracy" => "99.01136779785156",
      "count_rank_ss" => "81",
      "count_rank_s" => "632",
      "count_rank_a" => "650",
      "country" => "CA",
      "pp_country_rank" => "103",
      "events" => [],
    }
    Dict.merge(default, overrides)
  end

  defp mock_event_dict(overrides \\ %{}) do
    default = %{
      "display_html" => "<img src='/images/S_small.png'/> <b><a href='/u/1579374'>influxd</a></b> achieved rank #998 on <a href='/b/696783?m=0'>AKINO from bless4 - MIIRO [Hime]</a> (osu!)",
      "beatmap_id" => "696783",
      "beatmapset_id" => "312042",
      "date" => "2015-12-31 14:31:35",
      "epicfactor" => "1",
    }
    Dict.merge(default, overrides)
  end

  defp mock_score_dict(overrides \\ %{}) do
    default = %{
      "beatmap_id" => "759192",
      "score" => "69954590",
      "maxcombo" => "1768",
      "count50" => "0",
      "count100" => "16",
      "count300" => "1263",
      "countmiss" => "1",
      "countkatu" => "9",
      "countgeki" => "203",
      "perfect" => "0",
      "enabled_mods" => "0",
      "user_id" => "1579374",
      "date" => "2015-12-28 04:25:55",
      "rank" => "A",
      "pp" => "281.856",
    }
    Dict.merge(default, overrides)
  end

  test_with_mock "user username", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [mock_user_dict]} end,
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
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [mock_user_dict]} end,
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
        mock_user_dict %{"events" => [mock_event_dict]}
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
        mock_user_dict %{"events" => [mock_event_dict, mock_event_dict]}
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
        mock_user_dict
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        mock_score_dict
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
        mock_user_dict
      ]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        mock_score_dict,
        mock_score_dict
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
        mock_user_dict %{"user_id" => "#{id}"}
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

  defp mock_beatmap_dict(overrides) do
    default = %{
      "approved" => "1",
      "approved_date" => "2013-07-02 01:01:12",
      "last_update" => "2013-07-06 16:51:22",
      "artist" => "Luxion",
      "beatmap_id" => "252002",
      "beatmapset_id" => "93398",
      "bpm" => "196.5",
      "creator" => "RikiH",
      "difficultyrating" => "5.59516",
      "diff_size" => "3.8",
      "diff_overall" => "6.01",
      "diff_approach" => "9.2",
      "diff_drain" => "6.7",
      "hit_length" => "113",
      "source" => "BMS",
      "genre_id" => "1",
      "language_id" => "5",
      "title" => "High-Priestess",
      "total_length" => "145",
      "version" => "Overkill",
      "file_md5" => "c8f08438204abfcdd1a748ebfae67421",
      "mode" => "0",
      "tags" => "melodious long",
      "favourite_count" => "121",
      "playcount" => "9001",
      "passcount" => "1337",
      "max_combo" => "2101",
    }
    Dict.merge default, overrides
  end

  defp mock_snapshot_dict(overrides) do
    default = %{
      "user_id" => 1,
      "generation_id" => 1,
      "username" => "a",
      "count300" => 1,
      "count100" => 1,
      "count50" => 1,
      "playcount" => 1,
      "ranked_score" => 1,
      "total_score" => 1,
      "pp_rank" => 1,
      "level" => 1,
      "pp_raw" => 1,
      "accuracy" => 1,
      "count_rank_ss" => 1,
      "count_rank_s" => 1,
      "count_rank_a" => 1,
      "country" => "CA",
      "pp_country_rank" => 1,
    }
    Dict.merge default, overrides
  end

  test_with_mock "collect beatmaps", Osu, [
    start: fn -> end,
    get_beatmaps!: fn(%{b: 234}, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
        mock_beatmap_dict(%{
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
    Repo.insert!(%User{id: 1})
    changeset = Score.changeset(%Score{}, mock_score_dict(%{
      "beatmap_id" => "234",
      "user_id" => 1,
    }))
    Repo.insert!(changeset)

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
        mock_beatmap_dict(%{
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
    Repo.insert!(%User{id: 1})
    Repo.insert!(%User{id: 2})
    changeset = Score.changeset(%Score{}, mock_score_dict(%{
      "beatmap_id" => "234",
      "user_id" => 1,
    }))
    Repo.insert!(changeset)
    changeset = Score.changeset(%Score{}, mock_score_dict(%{
      "beatmap_id" => "234",
      "user_id" => 2,
    }))
    Repo.insert!(changeset)

    Data.collect_beatmaps %Osu.Client{api_key: "abc"}

    assert Repo.one!(count_query) == 1
  end

  test_with_mock "collect beatmaps does not collect a beatmap that already is in db", Osu, [
    start: fn -> end,
  ] do
    count_query = from b in Beatmap, select: count(b.id), where: b.id == 234
    assert Repo.one!(count_query) == 0

    Repo.insert! Beatmap.changeset(%Beatmap{}, mock_beatmap_dict(%{
      "id" => "234",
      "beatmapset_id" => "123456",
      "version" => "Overkill",
    }))

    assert Repo.one!(count_query) == 1

    # insert a score that points to the 234 beatmap
    Repo.insert!(%User{id: 1})
    changeset = Score.changeset(%Score{}, mock_score_dict(%{
      "beatmap_id" => "234",
      "user_id" => 1,
    }))
    Repo.insert!(changeset)

    Data.collect_beatmaps %Osu.Client{api_key: "abc"}
  end

  # queries

  test "get daily generations" do
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 1,
      "inserted_at" => "2015-01-01 05:00:00",
      "updated_at" => "2015-01-01 05:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 2,
      "inserted_at" => "2015-01-01 06:00:00",
      "updated_at" => "2015-01-01 06:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
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
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 1,
      "inserted_at" => "2015-01-01 05:00:00",
      "updated_at" => "2015-01-01 05:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 2,
      "inserted_at" => "2015-01-01 06:00:00",
      "updated_at" => "2015-01-01 06:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 3,
      "inserted_at" => "2015-01-02 05:00:00",
      "updated_at" => "2015-01-02 05:00:00",
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 1,
      "username" => "a",
    }
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 1,
    })
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 2,
    })
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 3,
    })
    Repo.insert! User.changeset %User{}, %{
      "id" => 2,
      "username" => "a",
    }
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 2,
      "generation_id" => 1,
    })
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 2,
      "generation_id" => 2,
    })
    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 2,
      "generation_id" => 3,
    })

    [u1, u2] = Repo.all Data.get_users

    [u1_snapshot] = u1.snapshots
    assert u1_snapshot.generation_id == 3

    [u2_snapshot] = u2.snapshots
    assert u2_snapshot.generation_id == 3
  end

  test "get weekly snapshots" do
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 1,
      "inserted_at" => "2015-12-30 05:00:00",
      "updated_at" => "2015-12-30 05:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 2,
      "inserted_at" => "2015-12-31 06:00:00",
      "updated_at" => "2015-12-31 06:00:00",
    }
    Repo.insert! Generation.changeset %Generation{}, %{
      "id" => 3,
      "inserted_at" => "2016-01-06 05:00:00",
      "updated_at" => "2016-01-06 05:00:00",
    }

    Repo.insert! User.changeset %User{}, %{
      "id" => 1,
    }

    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 1,
      "playcount" => 5,
      "pp_rank" => 1380,
      "level" => 100,
      "pp_raw" => 3000,
      "accuracy" => 98.98,
      "pp_country_rank" => 50,
    })

    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 2,
    })

    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 1,
      "generation_id" => 3,
      "playcount" => 11,
      "pp_rank" => 1360,
      "level" => 101,
      "pp_raw" => 3050,
      "accuracy" => 98.99,
      "pp_country_rank" => 49,
    })

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
    Repo.insert! User.changeset %User{}, %{
      "id" => 1,
      "username" => "a",
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 2,
      "username" => "a",
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 3,
      "username" => "a",
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 4,
      "username" => "a",
    }
    Repo.insert! Beatmap.changeset %Beatmap{}, mock_beatmap_dict %{
      "id" => 1,
    }
    Repo.insert! Beatmap.changeset %Beatmap{}, mock_beatmap_dict %{
      "id" => 2,
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 1,
      "user_id" => 1,
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 1,
      "user_id" => 2,
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2015-01-01 05:00:00",
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2015-01-01 06:00:00",
    }
    # Duplicate (beatmap_id, user_id) may affect the beatmap ordering
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
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
