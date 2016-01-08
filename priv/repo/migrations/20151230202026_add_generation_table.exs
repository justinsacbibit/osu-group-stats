defmodule UwOsu.Repo.Migrations.AddGenerationTable do
  use Ecto.Migration

  def change do
    create table(:generation) do
      timestamps
    end

    execute("insert into generation select generation as id, max(inserted_at) as inserted_at, max(updated_at) as updated_at from user_snapshot group by generation")

    alter table(:user_snapshot) do
      add :generation_id, :integer
    end

    create unique_index(:user_snapshot, [:user_id, :generation_id])

    execute("update user_snapshot set generation_id = generation")

    drop unique_index(:user_snapshot, [:user_id, :generation])

    alter table(:user_snapshot) do
      modify :generation_id, references(:generation), null: false
      remove :generation
    end

    execute("select setval('generation_id_seq', (select max(id) from generation)+1)")
  end
end
