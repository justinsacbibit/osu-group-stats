defmodule UwOsu.DataView do
  use UwOsu.Web, :view

  def render("weekly_snapshots.json", %{snapshots: snapshots}) do
    render_many(snapshots, UwOsu.DataView, "weekly_snapshots.json")
  end
end

