defmodule QueryTest do
  use UwOsu.ModelCase
  import UwOsu.RepoHelper
  alias UwOsu.Data.Query
  alias UwOsu.Models.Group
  alias UwOsu.Models.UserGroup
  alias UwOsu.Repo
  doctest UwOsu.Data.Query

  test "get users" do
    insert_generation! %{
      "id" => 1,
      "inserted_at" => "2015-01-01 05:00:00",
      "updated_at" => "2015-01-01 05:00:00",
      "mode" => 0,
    }
    insert_generation! %{
      "id" => 2,
      "inserted_at" => "2015-01-01 06:00:00",
      "updated_at" => "2015-01-01 06:00:00",
      "mode" => 0,
    }
    insert_generation! %{
      "id" => 3,
      "inserted_at" => "2015-01-02 05:00:00",
      "updated_at" => "2015-01-02 05:00:00",
      "mode" => 0,
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

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 1,
    }))
    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 2,
    }))

    [u1, u2] = Repo.all(Query.get_users(group_id))

    [u1_snapshot] = u1.snapshots
    assert u1_snapshot.generation_id == 3

    [u2_snapshot] = u2.snapshots
    assert u2_snapshot.generation_id == 3
  end

  #test "get weekly snapshots" do
    #insert_generation! %{
      #"id" => 1,
      #"inserted_at" => "2015-12-30 05:00:00",
      #"updated_at" => "2015-12-30 05:00:00",
    #}
    #insert_generation! %{
      #"id" => 2,
      #"inserted_at" => "2015-12-31 06:00:00",
      #"updated_at" => "2015-12-31 06:00:00",
    #}
    #insert_generation! %{
      #"id" => 3,
      #"inserted_at" => "2016-01-06 05:00:00",
      #"updated_at" => "2016-01-06 05:00:00",
    #}

    #insert_user! %{
      #"id" => 1,
    #}

    #insert_user_snapshot! %{
      #"user_id" => 1,
      #"generation_id" => 1,
      #"playcount" => 5,
      #"pp_rank" => 1380,
      #"level" => 100,
      #"pp_raw" => 3000,
      #"accuracy" => 98.98,
      #"pp_country_rank" => 50,
    #}

    #insert_user_snapshot! %{
      #"user_id" => 1,
      #"generation_id" => 2,
    #}

    #insert_user_snapshot! %{
      #"user_id" => 1,
      #"generation_id" => 3,
      #"playcount" => 11,
      #"pp_rank" => 1360,
      #"level" => 101,
      #"pp_raw" => 3050,
      #"accuracy" => 98.99,
      #"pp_country_rank" => 49,
    #}

    #snapshot_tuples = Repo.all Query.get_weekly_snapshots

    #assert length(snapshot_tuples) == 1

    #[snapshot_tuple | _] = snapshot_tuples
    #{s1, s2, %{
        #"playcount" => playcount,
        #"pp_rank" => pp_rank,
        #"level" => level,
        #"pp_raw" => pp_raw,
        #"accuracy" => accuracy,
        #"pp_country_rank" => pp_country_rank,
      #}
    #} = snapshot_tuple
    #assert s1.generation_id == 3
    #assert s2.generation_id == 1
    #assert playcount == 6
    #assert pp_rank == -20
    #assert level == 1
    #assert pp_raw == 50
    #assert Float.round(accuracy, 2) == 0.01
    #assert pp_country_rank == -1
  #end

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

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 1,
    }))
    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 2,
    }))
    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 3,
    }))
    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 4,
    }))

    [b1, b2] = Repo.all(Query.get_farmed_beatmaps(group_id))

    # TODO: The returned beatmaps should be ordered by the length of scores,
    #       descending. For some reason, ordering on a joined table does not
    #       correctly sort the results.

    assert b1.id == 2
    assert length(b1.scores) == 1

    assert b2.id == 1
    assert length(b2.scores) == 2
  end

  test "get latest scores" do
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user! %{
      "id" => 2,
      "username" => "b",
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
      "date" => "2016-01-14 05:00:00",
    }
    insert_score! %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2016-01-14 06:00:00",
    }
    insert_score! %{
      "beatmap_id" => 2,
      "user_id" => 1,
      "date" => "2016-01-13 05:00:00",
    }
    insert_score! %{
      "beatmap_id" => 1,
      "user_id" => 2,
      "date" => "2016-01-13 05:00:00",
    }

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 1,
    }))
    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 2,
    }))

    before = "2016-02-01 05:00:00"
    since = "2016-01-01 05:00:00"
    [u1, u2] = Repo.all(Query.get_latest_scores(group_id, before, since))

    assert u1.id == 1
    assert length(u1.scores) == 2

    assert u2.id == 2
    assert length(u2.scores) == 1
  end
end

