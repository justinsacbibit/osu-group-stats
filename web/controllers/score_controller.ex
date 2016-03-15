defmodule UwOsu.ScoreController do
  use UwOsu.Web, :controller
  alias UwOsu.Models.Score
  alias UwOsu.Repo

  def index(conn, params) do
    query = case params do
      %{"u" => user_id} ->
        from s in Score,
          where: s.user_id == ^user_id,
          preload: [:beatmap, :user]
      %{"g" => group_id} ->
        from s in Score,
          join: b in assoc(s, :beatmap),
          join: u in assoc(s, :user),
          join: g in assoc(u, :groups),
          where: g.id == ^group_id and b.mode == g.mode,
          order_by: [desc: s.date],
          limit: 50,
          preload: [:beatmap, :user]
      _ ->
        nil
    end

    if query do
      scores = Repo.all(query)
      render conn, "scores.json", scores: scores
    else
      render conn, "400.json", message: "You must specify a u (user ID) or g (group ID) query parameter."
    end
  end
end
