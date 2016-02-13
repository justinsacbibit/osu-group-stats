defmodule UwOsu.Models.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.Event
  alias UwOsu.Models.Score
  alias UwOsu.Models.UserGroup
  alias UwOsu.Models.UserSnapshot

  schema "user" do
    has_many :events, Event
    has_many :snapshots, UserSnapshot
    has_many :generations, through: [:snapshots, :generation]
    has_many :scores, Score
    has_many :user_groups, UserGroup
    field :username, :string

    timestamps
  end

  @required_fields ~w(id)
  @optional_fields ~w(username inserted_at updated_at)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

