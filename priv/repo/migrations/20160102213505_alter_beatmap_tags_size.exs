defmodule UwOsuStat.Repo.Migrations.AlterBeatmapTagsSize do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :tags, :string, size: 500
    end
  end
end
