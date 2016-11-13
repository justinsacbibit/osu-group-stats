defmodule UwOsu.Models.Score do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User
  alias UwOsu.Models.Beatmap

  schema "score" do
    belongs_to :user, User
    belongs_to :beatmap, Beatmap
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

  @required_fields ~w(user_id beatmap_id score maxcombo count50 count100 count300 countmiss countkatu countgeki perfect enabled_mods date rank pp)
  @optional_fields ~w()

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id, name: :score_user_id_date_index)
  end
end

