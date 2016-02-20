defmodule UwOsu.Repo.Migrations.AddDynamicGroupTable do
  use Ecto.Migration

  def change do
    create table(:dynamic_group, primary_key: false) do
      add :id, :integer, primary_key: true
      add :group_id, references(:group), null: false
    end

    create unique_index(:dynamic_group, [:group_id])
  end
end
