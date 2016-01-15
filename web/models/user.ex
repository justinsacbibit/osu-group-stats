defmodule UwOsu.Models.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation

  schema "user" do
    has_many :snapshots, UserSnapshot
    has_many :generations, through: [:snapshots, :generation]
    has_many :events, Event
    field :username, :string

    timestamps
  end

  @required_fields ~w(id)
  @optional_fields ~w(username)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

