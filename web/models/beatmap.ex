defmodule UwOsu.Models.Beatmap do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.Score

  schema "beatmap" do
    has_many :scores, Score
    field :approved, :integer
    field :approved_date, Ecto.DateTime
    field :last_update, Ecto.DateTime
    field :artist, :string
    field :beatmapset_id, :integer
    field :bpm, :float
    field :creator, :string
    field :difficultyrating, :float
    field :diff_size, :float
    field :diff_overall, :float
    field :diff_approach, :float
    field :diff_drain, :float
    field :hit_length, :integer
    field :source, :string
    field :genre_id, :integer
    field :language_id, :integer
    field :title, :string
    field :total_length, :integer
    field :version, :string
    field :file_md5, :string
    field :mode, :integer
    field :tags, :string
    field :favourite_count, :integer
    field :playcount, :integer
    field :passcount, :integer
    field :max_combo, :integer

    timestamps
  end

  @required_fields ~w(id approved approved_date last_update artist beatmapset_id bpm creator difficultyrating diff_size diff_overall diff_approach diff_drain hit_length genre_id language_id title total_length version file_md5 mode tags favourite_count playcount passcount)
  @optional_fields ~w(max_combo source)

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

