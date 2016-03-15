defmodule UwOsu.ScoreView do
  use UwOsu.Web, :view

  def render("scores.json", %{scores: scores}) do
    render_many(scores, UwOsu.ScoreView, "score.json", as: :score)
  end

  def render("score.json", %{score: score}) do
    score
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__])
    |> Map.update(:beatmap, %{}, fn(beatmap) ->
      beatmap
      |> Map.from_struct
      |> Map.drop([:__meta__, :__struct__, :scores])
    end)
    |> Map.update(:user, %{}, fn(user) ->
      user
      |> Map.from_struct
      |> Map.drop([
        :__meta__,
        :__struct__,
        :events,
        :generations,
        :groups,
        :scores,
        :snapshots,
        :user_groups,
        :__owner__,
        :__field__,
        :__cardinality__,
      ])
    end)
  end

  def render("400.json", %{message: message}) do
    %{message: message}
  end
end
