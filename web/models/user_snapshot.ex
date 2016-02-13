defmodule UwOsu.Models.UserSnapshot do
  use Ecto.Schema
  import Ecto.Changeset
  alias UwOsu.Models.User
  alias UwOsu.Models.Generation

  schema "user_snapshot" do
    belongs_to :user, User
    belongs_to :generation, Generation
    field :username, :string
    field :count300, :integer
    field :count100, :integer
    field :count50, :integer
    field :playcount, :integer
    field :ranked_score, :integer
    field :total_score, :integer
    field :pp_rank, :integer
    field :level, :float
    field :pp_raw, :float
    field :accuracy, :float
    field :count_rank_ss, :integer
    field :count_rank_s, :integer
    field :count_rank_a, :integer
    field :country, :string
    field :pp_country_rank, :integer

    timestamps
  end

  @required_fields ~w(user_id generation_id username count300 count100 count50 playcount ranked_score total_score pp_rank level pp_raw accuracy count_rank_ss count_rank_s count_rank_a country pp_country_rank)
  @optional_fields ~w(inserted_at updated_at)

  def changeset(event, params \\ :empty) do
    event
    |> cast(params, @required_fields, @optional_fields)
    |> unique_constraint(:user_id, name: :user_snapshot_user_id_generation_id_index)
  end
end

