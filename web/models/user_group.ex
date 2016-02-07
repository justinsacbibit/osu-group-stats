defmodule UwOsu.Models.UserGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User
  alias UwOsu.Models.Group

  schema "user_group" do
    belongs_to :group, Group
    belongs_to :user, User
  end

  @required_fields ~w(user_id group_id)
  @optional_fields ~w(id)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

