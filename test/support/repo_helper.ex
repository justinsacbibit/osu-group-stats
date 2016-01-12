defmodule UwOsu.RepoHelper do
  alias UwOsu.ApiData
  alias UwOsu.Repo
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Event
  alias UwOsu.Models.User
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Models.Score

  def insert_score!(overrides \\ %{}) do
    changeset = Score.changeset %Score{}, ApiData.score overrides
    Repo.insert! changeset
  end

  def insert_scores!(scores \\ []) do
    Enum.each scores, &insert_score!/1
  end

  def insert_beatmap!(overrides \\ %{}) do
    changeset = Beatmap.changeset %Beatmap{}, ApiData.beatmap overrides
    Repo.insert! changeset
  end

  def insert_generation!(overrides \\ %{}) do
    changeset = Generation.changeset %Generation{}, overrides
    Repo.insert! changeset
  end

  def insert_user!(overrides \\ %{}) do
    changeset = User.changeset %User{}, overrides
    Repo.insert! changeset
  end

  def insert_user_snapshot!(overrides \\ %{}) do
    changeset = UserSnapshot.changeset %UserSnapshot{}, mock_snapshot_dict overrides
    Repo.insert! changeset
  end

  defp mock_snapshot_dict(overrides) do
    default = %{
      "user_id" => 1,
      "generation_id" => 1,
      "username" => "a",
      "count300" => 1,
      "count100" => 1,
      "count50" => 1,
      "playcount" => 1,
      "ranked_score" => 1,
      "total_score" => 1,
      "pp_rank" => 1,
      "level" => 1,
      "pp_raw" => 1,
      "accuracy" => 1,
      "count_rank_ss" => 1,
      "count_rank_s" => 1,
      "count_rank_a" => 1,
      "country" => "CA",
      "pp_country_rank" => 1,
    }
    Dict.merge default, overrides
  end
end
