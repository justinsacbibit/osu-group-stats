defmodule UwOsu.Repo.Migrations.AlterBeatmapMaxComboToNull do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :max_combo, :integer, null: true
    end
  end
end
