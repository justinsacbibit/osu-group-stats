defmodule UwOsu.Models.Token do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User

  schema "token" do
    belongs_to :user, User
    field :token, :string

    timestamps
  end

  @required_fields ~w(user_id token)
  @optional_fields ~w()
  @token_length 8

  def changeset(token, params \\ :empty) do
    token
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id)
    |> validate_length(:token, is: @token_length)
    |> foreign_key_constraint(:user_id)
  end

  def new(user_id) do
    changeset(%__MODULE__{}, %{
      token: random_string(@token_length),
      user_id: user_id,
    })
  end

  defp random_string(len) do
    :crypto.strong_rand_bytes(len)
    |> Base.url_encode64
    |> binary_part(0, len)
  end
end

