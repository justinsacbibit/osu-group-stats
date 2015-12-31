defmodule UwOsuStat.Models.UserSnapshot do
  use Ecto.Schema
  alias UwOsuStat.Models.User
  alias UwOsuStat.Models.Generation

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
end

