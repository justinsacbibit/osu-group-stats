defmodule UwOsu.Repo.Migrations.AlterBeatmapBpmToFloat do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :bpm, :float
    end
  end
end
