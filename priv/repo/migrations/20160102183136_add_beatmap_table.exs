defmodule UwOsu.Repo.Migrations.AddBeatmapTable do
  use Ecto.Migration

  def change do
    create table(:beatmap, primary_key: false) do
      add :id, :integer, primary_key: true

      add :approved, :integer, null: false
      add :approved_date, :datetime, null: false
      add :last_update, :datetime, null: false
      add :artist, :string, null: false
      add :beatmapset_id, :integer, null: false
      add :bpm, :integer, null: false
      add :creator, :string, null: false
      add :difficultyrating, :float, null: false
      add :diff_size, :integer, null: false
      add :diff_overall, :integer, null: false
      add :diff_approach, :integer, null: false
      add :diff_drain, :integer, null: false
      add :hit_length, :integer, null: false
      add :source, :string, null: false
      add :genre_id, :integer, null: false
      add :language_id, :integer, null: false
      add :title, :string, null: false
      add :total_length, :integer, null: false
      add :version, :string, null: false
      add :file_md5, :string, null: false
      add :mode, :integer, null: false
      add :tags, :string, null: false
      add :favourite_count, :integer, null: false
      add :playcount, :integer, null: false
      add :passcount, :integer, null: false
      add :max_combo, :integer, null: false

      timestamps
    end
  end
end
