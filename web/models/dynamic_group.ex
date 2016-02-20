defmodule UwOsu.Models.DynamicGroup do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.Group

  schema "dynamic_group" do
    belongs_to :group, Group
  end

  @required_fields ~w(id group_id)
  @optional_fields ~w()

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end

