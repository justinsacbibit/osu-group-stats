defmodule UwOsuStat.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    create table(:user, primary_key: false) do
      add :id, :integer, primary_key: true

      timestamps
    end

    create table(:user_snapshot) do
      add :user_id, references(:user), null: false
      add :generation, :integer, null: false
      add :username, :string, null: false
      add :count300, :integer, null: false
      add :count100, :integer, null: false
      add :count50, :integer, null: false
      add :playcount, :integer, null: false
      add :ranked_score, :bigint, null: false
      add :total_score, :bigint, null: false
      add :pp_rank, :integer, null: false
      add :level, :float, null: false
      add :pp_raw, :float, null: false
      add :accuracy, :float, null: false
      add :count_rank_ss, :integer, null: false
      add :count_rank_s, :integer, null: false
      add :count_rank_a, :integer, null: false
      add :country, :string, null: false
      add :pp_country_rank, :integer, null: false

      timestamps
    end

    create unique_index(:user_snapshot, [:user_id, :generation])

    create table(:event) do
      add :user_id, references(:user), null: false
      add :display_html, :string, null: false
      add :beatmap_id, :integer, null: false
      add :beatmapset_id, :integer, null: false
      add :date, :datetime, null: false
      add :epicfactor, :integer, null: false

      timestamps
    end

    create unique_index(:event, [:user_id, :beatmap_id, :date])

    create table(:score) do
      add :user_id, references(:user), null: false
      add :beatmap_id, :integer, null: false
      add :score, :bigint, null: false
      add :maxcombo, :integer, null: false
      add :count50, :integer, null: false
      add :count100, :integer, null: false
      add :count300, :integer, null: false
      add :countmiss, :integer, null: false
      add :countkatu, :integer, null: false
      add :countgeki, :integer, null: false
      add :perfect, :integer, null: false
      add :enabled_mods, :integer, null: false
      add :date, :datetime, null: false
      add :rank, :string, null: false
      add :pp, :float, null: false

      timestamps
    end

    create unique_index(:score, [:user_id, :date])
  end
end
