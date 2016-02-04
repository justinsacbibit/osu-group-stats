defmodule UwOsu.Models.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.UserGroup

  schema "group" do
    has_many :user_groups, UserGroup
    has_many :users, through: [:user_groups, :user]
    field :mode, :integer

    timestamps
  end

  @required_fields ~w(mode)
  @optional_fields ~w(id inserted_at updated_at)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

