defmodule UwOsu.DataView do
  use UwOsu.Web, :view
  alias UwOsu.Models.User
  alias UwOsu.Models.Generation

  def render("weekly_snapshots.json", %{snapshots: snapshots}) do
    %{
      rankings: %{
        playcount: snapshots
        |> Enum.sort_by(fn({_, _, %{"playcount" => playcount}}) -> playcount end, &>/2)
        |> Enum.map(fn({s1, _, _}) -> s1.user_id end),
        pp_raw: snapshots
        |> Enum.sort_by(fn({_, _, %{"pp_raw" => pp_raw}}) -> pp_raw end, &>/2)
        |> Enum.map(fn({s1, _, _}) -> s1.user_id end)
      },
      snapshots: render_many(snapshots, UwOsu.DataView, "weekly_snapshot.json", as: :snapshot)
    }
  end

  def render("weekly_snapshot.json", %{snapshot: {s1, s2, diffs}}) do
    s1 = s1
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__, :generation, :user])
    s2 = s2
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__, :generation, :user])

    %{
      current: s1,
      past: s2,
      diffs: diffs,
    }
  end

  def render("daily_snapshots.json", %{users: users}) do
    users = users
    |> Enum.group_by(fn({%User{id: id}, _, _}) -> id end)
    |> Enum.map(fn({_, tuples}) ->
      [{u, _, _} | _] = tuples
      %{ u | generations:
         Enum.map(tuples, fn({_, g, s}) -> %{ g | snapshots: [s] } end)
       }
    end)
    render_many(users, UwOsu.DataView, "daily_snapshot.json", as: :user)
  end

  def render("daily_snapshot.json", %{user: user}) do
    user
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__, :events, :snapshots])
    |> Map.update(:generations, [], fn(generations) ->
      generations
      |> Enum.map(fn(generation) ->
        generation
        |> Map.from_struct
        |> Map.update(:snapshots, [], fn(snapshots) ->
          case snapshots do
            [nil] ->
              [nil]
            [snapshot] ->
              snapshot = snapshot
              |> Map.from_struct
              |> Map.drop([:__struct__, :__meta__, :generation, :user])

              [snapshot]
          end
        end)
        |> Map.drop([:__struct__, :__meta__])
      end)
    end)
  end

  def render("farmed_beatmaps.json", %{beatmaps: beatmaps}) do
    render_many(beatmaps, UwOsu.DataView, "beatmap.json", as: :beatmap)
  end

  def render("beatmap.json", %{beatmap: beatmap}) do
    beatmap
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__])
    |> Map.update(:scores, [], fn(scores) ->
      scores
      |> Enum.map(fn(score) ->
        score
        |> Map.from_struct
        |> Map.drop([:__struct__, :__meta__])
        |> Map.update(:user, nil, fn(user) ->
          user
          |> Map.from_struct
          |> Map.drop([:__struct__, :__meta__, :events, :snapshots, :generations])
        end)
      end)
      |> Enum.sort_by(fn(%{pp: pp}) -> pp end, &>/2)
    end)
  end

  def render("players.json", %{players: players}) do
    render_many players, UwOsu.DataView, "player.json", as: :player
  end

  def render("player.json", %{player: player}) do
    player
    |> Map.from_struct
    |> Map.drop([:__struct__, :__meta__, :snapshots, :events, :generations])
    |> Map.merge(
      Enum.at(player.snapshots, 0)
      |> Map.from_struct
      |> Map.drop([:__struct__, :__meta__, :generation, :user])
    )
  end
end

