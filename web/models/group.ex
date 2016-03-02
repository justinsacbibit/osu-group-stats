defmodule UwOsu.Models.Group do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User
  alias UwOsu.Models.UserGroup

  schema "group" do
    has_many :user_groups, UserGroup
    has_many :users, through: [:user_groups, :user]
    belongs_to :creator, User, foreign_key: :created_by
    field :mode, :integer
    field :title, :string

    timestamps
  end

  @required_fields ~w(mode created_by title)
  @optional_fields ~w(id inserted_at updated_at)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> validate_number(:mode, greater_than_or_equal_to: 0, less_than_or_equal_to: 3)
    |> validate_length(:title, min: 3, max: 30)
    |> foreign_key_constraint(:created_by)
  end
end
