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

  @required_fields ~w(mode created_by)
  @optional_fields ~w(id inserted_at updated_at title)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> validate_length(:title, max: 30)
  end
end

