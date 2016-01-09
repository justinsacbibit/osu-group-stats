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
end
