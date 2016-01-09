defmodule UwOsu.DataViewTest do
  use UwOsu.ConnCase
  alias UwOsu.Repo
  alias UwOsu.Models.Generation
  alias UwOsu.Models.User
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.Score

  defp mock_score_dict(overrides) do
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

  test "get snapshots" do
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

    Repo.insert! User.changeset %User{}, %{
      "id" => 2,
    }

    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 2,
      "generation_id" => 1,
      "playcount" => 1000,
      "pp_rank" => 1380,
      "level" => 100,
      "pp_raw" => 3000,
      "accuracy" => 98.98,
      "pp_country_rank" => 50,
    })

    Repo.insert! UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict(%{
      "user_id" => 2,
      "generation_id" => 3,
      "playcount" => 1001,
      "pp_rank" => 1360,
      "level" => 101,
      "pp_raw" => 3100,
      "accuracy" => 98.99,
      "pp_country_rank" => 49,
    })

    conn = get conn, "/api/weekly-snapshots"
    %{
      "rankings" => %{
        "playcount" => [1, 2],
        "pp_raw" => [2, 1],
      },
      "snapshots" => [
        %{
          "current" => %{
            "generation_id" => 3,
          },
          "past" => %{
            "generation_id" => 1,
          },
          "diffs" => %{
            "playcount" => 6,
          },
        }
        |_ # TODO: Maybe remove
      ]
    } = json_response(conn, 200)
  end

  test "get farmed beatmaps" do
    Repo.insert! User.changeset %User{}, %{
      "id" => 1,
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 2,
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 3,
    }
    Repo.insert! User.changeset %User{}, %{
      "id" => 4,
    }
    Repo.insert! Beatmap.changeset %Beatmap{}, mock_beatmap_dict %{
      "id" => 1,
    }
    Repo.insert! Beatmap.changeset %Beatmap{}, mock_beatmap_dict %{
      "id" => 2,
    }
    Repo.insert! Beatmap.changeset %Beatmap{}, mock_beatmap_dict %{
      "id" => 3,
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
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 3,
      "user_id" => 1,
      "date" => "2015-01-01 01:00:00",
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 3,
      "user_id" => 2,
      "date" => "2015-01-01 02:00:00",
    }
    Repo.insert! Score.changeset %Score{}, mock_score_dict %{
      "beatmap_id" => 3,
      "user_id" => 3,
      "date" => "2015-01-01 03:00:00",
    }

    conn = get conn, "/api/farmed-beatmaps"
    [
      %{"id" => 3, "score_count" => 3},
      %{"id" => 1, "score_count" => 2},
      %{"id" => 2, "score_count" => 1},
    ] = json_response(conn, 200)
  end
end
