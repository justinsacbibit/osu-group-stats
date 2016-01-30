defmodule UwOsu.Repo.Migrations.AddInitialGroup do
  use Ecto.Migration

  def change do
    create table(:group) do
      timestamps
    end

    create table(:user_group) do
      add :user_id, references(:user)
      add :group_id, references(:group)
    end

    create unique_index(:user_group, [:user_id, :group_id])

    execute("""
    insert into "group" (inserted_at, updated_at) values ('2016-01-01 05:00:00', '2016-01-01 05:00:00')
    """)

    execute("""
    insert into user_group (user_id, group_id)
    select u.id, 1
    from "user" u
    """)
  end
end
