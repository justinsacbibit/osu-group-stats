defmodule UwOsu.DataViewTest do
  use UwOsu.ConnCase
  import UwOsu.RepoHelper

  test "get snapshots" do
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

    insert_user! %{
      "id" => 2,
    }

    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 1,
      "playcount" => 1000,
      "pp_rank" => 1380,
      "level" => 100,
      "pp_raw" => 3000,
      "accuracy" => 98.98,
      "pp_country_rank" => 50,
    }

    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 3,
      "playcount" => 1001,
      "pp_rank" => 1360,
      "level" => 101,
      "pp_raw" => 3100,
      "accuracy" => 98.99,
      "pp_country_rank" => 49,
    }

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
    insert_beatmap! %{
      "id" => 3,
    }
    insert_scores! [
      %{
        "beatmap_id" => 1,
        "user_id" => 1,
      },
      %{
        "beatmap_id" => 1,
        "user_id" => 2,
      },
      %{
        "beatmap_id" => 2,
        "user_id" => 1,
        "date" => "2015-01-01 05:00:00",
      },
      %{
        "beatmap_id" => 2,
        "user_id" => 1,
        "date" => "2015-01-01 06:00:00",
      },
      %{
        "beatmap_id" => 3,
        "user_id" => 1,
        "date" => "2015-01-01 01:00:00",
        "pp" => "100",
      },
      %{
        "beatmap_id" => 3,
        "user_id" => 2,
        "date" => "2015-01-01 02:00:00",
        "pp" => "300",
      },
      %{
        "beatmap_id" => 3,
        "user_id" => 3,
        "date" => "2015-01-01 03:00:00",
        "pp" => "200",
      }
    ]

    conn = get conn, "/api/farmed-beatmaps"
    resp = json_response(conn, 200)
    [
      3, 1, 2
    ] = Enum.map resp, fn(%{"id" => id}) -> id end

    [
      %{
        "id" => 3,
        "scores" => [
          %{"pp" => 300.0, "user" => %{"id" => 2}},
          %{"pp" => 200.0},
          %{"pp" => 100.0},
        ],
      },
      %{"id" => 1},
      %{"id" => 2},
    ] = resp
  end

  test "get users" do
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user! %{
      "id" => 2,
      "username" => "a",
    }
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-12-28 04:25:55",
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-12-29 04:25:55",
    }
    insert_user_snapshot! %{
      "user_id" => 1,
      "generation_id" => 2,
      "pp_raw" => 50,
    }
    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 1,
    }
    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 2,
      "pp_raw" => 70,
    }

    conn = get conn, "/api/players"
    resp = json_response(conn, 200)

    [u2, u1] = resp

    assert u2["user_id"] == 2
    assert u2["pp_raw"] == 70

    assert u1["user_id"] == 1
    assert u1["pp_raw"] == 50
  end

  test "daily snapshots" do
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-12-30 05:00:00",
      "updated_at" => "2015-12-30 05:00:00",
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-12-30 06:00:00",
      "updated_at" => "2015-12-30 06:00:00",
    }
    insert_generation! %{
      "id" => 3,
      "inserted_at" => "2015-12-31 05:00:00",
      "updated_at" => "2015-12-31 05:00:00",
    }
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user! %{
      "id" => 2,
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
    insert_user_snapshot! %{
      "user_id" => 2,
      "generation_id" => 3,
    }

    conn = get conn, "/api/daily-snapshots"
    resp = json_response(conn, 200)

    [u1, u2] = resp

    assert u1["id"] == 1
    [u1_g1, u1_g2] = u1["generations"]
    %{
      "id" => 1,
      "snapshots" => [%{
        "user_id" => 1,
        "generation_id" => 1,
      }]
    } = u1_g1
    %{
      "id" => 3,
      "snapshots" => [%{
        "user_id" => 1,
        "generation_id" => 3,
      }]
    } = u1_g2

    [u2_g1, u2_g2] = u2["generations"]
    %{
      "id" => 1,
      "snapshots" => [nil],
    } = u2_g1
    %{
      "id" => 3,
      "snapshots" => [%{
        "user_id" => 2,
        "generation_id" => 3,
      }]
    } = u2_g2
  end
end
