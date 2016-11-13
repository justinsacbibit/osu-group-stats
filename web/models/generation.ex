defmodule UwOsu.Models.Generation do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.UserSnapshot

  schema "generation" do
    has_many :snapshots, UserSnapshot
    field :mode, :integer

    timestamps
  end

  @required_fields ~w(mode)
  @optional_fields ~w(id inserted_at updated_at)

  def changeset(event, params \\ %{}) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end


