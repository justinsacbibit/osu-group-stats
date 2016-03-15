defmodule UwOsu.DataController do
  use UwOsu.Web, :controller
  alias UwOsu.Models.{Generation, Score}
  alias UwOsu.Data.Query
  alias UwOsu.Repo

  def weekly_snapshots(conn, _params) do
    snapshots = Repo.all(Query.get_weekly_snapshots)
    render conn, "weekly_snapshots.json", snapshots: snapshots
  end

  def farmed_beatmaps(conn, %{"g" => group_id}) do
    beatmaps = Repo.all(Query.get_farmed_beatmaps(group_id))
    render conn, "farmed_beatmaps.json", beatmaps: beatmaps
  end

  def players(conn, %{"g" => group_id} = params) do
    query = case params do
      %{"d" => days_delta} ->
        {days_delta, _} = Integer.parse(days_delta)
        Query.get_users(group_id, days_delta)
      _ ->
        Query.get_users(group_id)
    end
    players = Repo.all(query)
    render conn, "players.json", players: players
  end

  def show_player(conn, %{"id" => id, "d" => days_delta}) do
    {days_delta, _} = Integer.parse(days_delta)
    player = Repo.first!(Query.get_user(id, 0, days_delta))
    render conn, "player.json", player: player
  end

  def daily_snapshots(conn, %{"g" => group_id}) do
    users = Repo.all(Query.get_users_with_snapshots(group_id))
    render conn, "daily_snapshots.json", users: users
  end

  def latest_scores(conn, %{"g" => group_id, "before" => before, "since" => since}) do
    users = Repo.all(Query.get_latest_scores(group_id, before, since))
    render conn, "latest_scores.json", users: users
  end

  def generations(conn, _params) do
    generations = Repo.all from g in Generation,
      order_by: [desc: g.id]
    render conn, "generations.json", generations: generations
  end
end
