defmodule UwOsuStat.Models.Score do
  use Ecto.Schema

  schema "score" do
    belongs_to :user, User
    field :beatmap_id, :integer
    field :score, :integer
    field :maxcombo, :integer
    field :count50, :integer
    field :count100, :integer
    field :count300, :integer
    field :countmiss, :integer
    field :countkatu, :integer
    field :countgeki, :integer
    field :perfect, :integer
    field :enabled_mods, :integer
    field :date, Ecto.DateTime
    field :rank, :string
    field :pp, :float

    timestamps
  end
end

