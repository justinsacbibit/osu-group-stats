defmodule UwOsu.Repo.Migrations.AddUwGroupsAllModes do
  use Ecto.Migration
  alias UwOsu.Models.Group
  alias UwOsu.Repo

  def change do
    modes = [1, 2, 3]
    Enum.each modes, fn(mode) ->
      group = Repo.insert! Group.changeset(%Group{}, %{mode: mode})
      execute """
      INSERT INTO user_group (user_id, group_id)
      SELECT u.id, #{group.id} FROM "user" u
      JOIN user_group ug
        ON u.id = ug.user_id
      WHERE ug.group_id = 1
      """
    end
  end
end
