defmodule UwOsuStat.Repo.Migrations.AlterBeatmapTagsSize do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :tags, :string, size: 1000
    end
  end
end
