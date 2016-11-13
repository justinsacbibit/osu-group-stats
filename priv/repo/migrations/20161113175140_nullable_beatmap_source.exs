defmodule UwOsu.Repo.Migrations.NullableBeatmapSource do
  use Ecto.Migration

  def change do
    alter table(:beatmap) do
      modify :source, :string, null: true
    end
  end
end
