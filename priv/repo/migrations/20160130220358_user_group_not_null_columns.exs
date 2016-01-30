defmodule UwOsu.Repo.Migrations.UserGroupNotNullColumns do
  use Ecto.Migration

  def change do
    execute """
    ALTER TABLE user_group
    DROP CONSTRAINT user_group_user_id_fkey
    """
    execute """
    ALTER TABLE user_group
    DROP CONSTRAINT user_group_group_id_fkey
    """
    alter table(:user_group) do
      modify :user_id, references(:user), null: false
      modify :group_id, references(:group), null: false
    end
  end
end
