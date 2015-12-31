defmodule UwOsuStat.Models.Score do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsuStat.Models.Types.IntString

  schema "score" do
    belongs_to :user, User
    field :beatmap_id, IntString
    field :score, IntString
    field :maxcombo, IntString
    field :count50, IntString
    field :count100, IntString
    field :count300, IntString
    field :countmiss, IntString
    field :countkatu, IntString
    field :countgeki, IntString
    field :perfect, IntString
    field :enabled_mods, IntString
    field :date, Ecto.DateTime
    field :rank, :string
    field :pp, :float

    timestamps
  end

  @required_fields ~w(user_id beatmap_id score maxcombo count50 count100 count300 countmiss countkatu countgeki perfect enabled_mods date rank pp)
  @optional_fields ~w()

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id, name: :score_user_id_date_index)
  end
end

