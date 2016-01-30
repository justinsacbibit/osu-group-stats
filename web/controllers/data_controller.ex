defmodule UwOsu.DataController do
  use UwOsu.Web, :controller
  alias UwOsu.Data
  alias UwOsu.Repo

  def weekly_snapshots(conn, _params) do
    snapshots = Repo.all Data.get_weekly_snapshots
    render conn, "weekly_snapshots.json", snapshots: snapshots
  end

  def farmed_beatmaps(conn, %{"g" => group_id}) do
    beatmaps = Repo.all Data.get_farmed_beatmaps(group_id)
    render conn, "farmed_beatmaps.json", beatmaps: beatmaps
  end

  def players(conn, %{"g" => group_id}) do
    players = Repo.all Data.get_users(group_id)
    render conn, "players.json", players: players
  end

  def daily_snapshots(conn, %{"g" => group_id}) do
    users = Repo.all Data.get_users_with_snapshots(group_id)
    render conn, "daily_snapshots.json", users: users
  end

  def latest_scores(conn, %{"g" => group_id}) do
    users = Repo.all Data.get_latest_scores(group_id)
    render conn, "latest_scores.json", users: users
  end
end
