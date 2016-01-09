defmodule UwOsu.DataView do
  use UwOsu.Web, :view

  def render("weekly_snapshots.json", %{snapshots: snapshots}) do
    %{
      rankings: %{
        playcount: snapshots
        |> Enum.sort_by(fn({_, _, %{"playcount" => playcount}}) -> playcount end, &>/2)
        |> Enum.map(fn({s1, _, _}) -> s1.user_id end),
        pp_raw: snapshots
        |> Enum.sort_by(fn({_, _, %{"pp_raw" => pp_raw}}) -> pp_raw end, &>/2)
        |> Enum.map fn({s1, _, _}) -> s1.user_id end
      },
      snapshots: render_many(snapshots, UwOsu.DataView, "weekly_snapshot.json", as: :snapshot)
    }
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

  def render("farmed_beatmaps.json", %{beatmaps: beatmaps}) do
    render_many(beatmaps, UwOsu.DataView, "beatmap.json", as: :beatmap)
  end

  def render("beatmap.json", %{beatmap: {beatmap, count}}) do
    beatmap
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__, :scores])
    |> Map.put :score_count, count
  end
end

