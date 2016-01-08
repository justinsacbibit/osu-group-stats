defmodule UwOsu.DataView do
  use UwOsu.Web, :view

  def render("weekly_snapshots.json", %{snapshots: snapshots}) do
    snapshots
  end
end

