defmodule UwOsu.GroupViewTest do
  use UwOsu.ConnCase
  import UwOsu.RepoHelper
  alias UwOsu.Models.UserGroup
  alias UwOsu.Repo

  test "get groups" do
    insert_user! %{
      "id" => 1,
      "username" => "a",
    }
    insert_user! %{
      "id" => 2,
      "username" => "b",
    }

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: 1,
      user_id: 1,
    }))

    conn = get conn, "/api/groups"
    resp = json_response(conn, 200)

    [_g1, _g2, _g3, _g4] = resp
  end
end
