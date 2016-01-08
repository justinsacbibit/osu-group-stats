defmodule UwOsu.Models.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User

  schema "event" do
    belongs_to :user, User
    field :display_html, :string
    field :beatmap_id, :integer
    field :beatmapset_id, :integer
    field :date, Ecto.DateTime
    field :epicfactor, :integer

    timestamps
  end

  @required_fields ~w(user_id display_html beatmap_id beatmapset_id date epicfactor)
  @optional_fields ~w()

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id, name: :event_user_id_beatmap_id_date_index)
  end
end

