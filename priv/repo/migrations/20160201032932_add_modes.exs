defmodule UwOsu.Repo.Migrations.AddModes do
  use Ecto.Migration

  def change do
    alter table(:generation) do
      add :mode, :integer, null: false, default: 0
    end

    alter table(:group) do
      add :mode, :integer, null: false, default: 0
    end
  end
end
