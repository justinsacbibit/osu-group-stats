defmodule UwOsu.DataController do
  use UwOsu.Web, :controller
  alias UwOsu.Data
  alias UwOsu.Repo

  def weekly_snapshots(conn, _params) do
    snapshots = Repo.all Data.get_weekly_snapshots
    render conn, "weekly_snapshots.json", snapshots: snapshots
  end

  def farmed_beatmaps(conn, _params) do
    beatmaps = Repo.all Data.get_farmed_beatmaps
    render conn, "farmed_beatmaps.json", beatmaps: beatmaps
  end

  def players(conn, _params) do
    players = Repo.all Data.get_users
    render conn, "players.json", players: players
  end

  def daily_snapshots(conn, params) do
    users = Repo.all Data.get_users_with_snapshots
    render conn, "daily_snapshots.json", users: users
  end

  def latest_scores(conn, _params) do
    users = Repo.all Data.get_latest_scores
    render conn, "latest_scores.json", users: users
  end
end
