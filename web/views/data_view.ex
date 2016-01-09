defmodule UwOsu.DataView do
  use UwOsu.Web, :view

  def render("weekly_snapshots.json", %{snapshots: snapshots}) do
    render_many snapshots, UwOsu.DataView, "weekly_snapshot.json", as: :snapshot
  end

  def render("weekly_snapshot.json", %{snapshot: {s1, s2, diffs}}) do
    s1 = s1
    |> Map.from_struct
    |> Map.drop [:__struct__, :__meta__, :generation, :user]
    s2 = s2
    |> Map.from_struct
    |> Map.drop [:__struct__, :__meta__, :generation, :user]

    %{
      current: s1,
      past: s2,
      diffs: diffs,
    }
  end
end

