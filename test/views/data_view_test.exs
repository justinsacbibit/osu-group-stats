defmodule UwOsu.DataViewTest do
  use UwOsu.ConnCase
  alias UwOsu.Repo
  alias UwOsu.Models.Generation
  alias UwOsu.Models.User
  alias UwOsu.Models.UserSnapshot

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
        |_
      ]
    } = json_response(conn, 200)
  end
end
