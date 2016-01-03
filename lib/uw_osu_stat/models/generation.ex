defmodule UwOsuStat.Models.Generation do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsuStat.Models.UserSnapshot

  schema "generation" do
    has_many :snapshots, UserSnapshot

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w(id inserted_at updated_at)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
  end
end


