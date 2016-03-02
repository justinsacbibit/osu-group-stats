defmodule UwOsu.Repo.Migrations.AddUwGroupsAllModes do
  use Ecto.Migration

  def change do
    modes = [1, 2, 3]
    Enum.each modes, fn(mode) ->
      execute """
      INSERT INTO "group" (mode, inserted_at, updated_at)
      VALUES (#{mode}, '2016-01-01 05:00:00', '2016-01-01 05:00:00')
      RETURNING id
      """
      execute """
      INSERT INTO user_group (user_id, group_id)
      SELECT u.id, #{mode + 1} FROM "user" u
      JOIN user_group ug
        ON u.id = ug.user_id
      WHERE ug.group_id = 1
      """
    end
  end
end
