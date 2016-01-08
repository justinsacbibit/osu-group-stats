defmodule UwOsu.Repo.Migrations.AlterBeatmapDiffsToFloats do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :diff_size, :float
      modify :diff_overall, :float
      modify :diff_approach, :float
      modify :diff_drain, :float
    end
  end
end
