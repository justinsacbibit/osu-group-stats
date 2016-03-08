defmodule UwOsu.GroupView do
  use UwOsu.Web, :view

  def render("groups.json", %{groups: groups}) do
    render_many(groups, UwOsu.GroupView, "group.json", as: :group)
  end

  def render("group.json", %{group: group}) do
    group = group
    |> Map.from_struct
    |> Map.drop([:__meta__, :__struct__, :user_groups, :created_by])
    |> Map.update(:creator, %{}, fn(creator) ->
      case creator do
        %Ecto.Association.NotLoaded{} ->
          nil

        _ ->
          creator
          |> Map.from_struct
          |> Map.take([
            :id,
            :username,
          ])
          end
    end)

    group = case group[:creator] do
      nil ->
        group
        |> Map.drop([:creator])
      _ ->
        group
    end

    group = case group[:users] do
      %Ecto.Association.NotLoaded{} ->
        group
        |> Map.drop([:users])
      _users ->
        group
        |> Map.update(:users, [], fn(users) ->
          Enum.map(users, fn(user) ->
            user
            |> Map.from_struct
            |> Map.drop([
              :__meta__,
              :__struct__,
              :events,
              :generations,
              :scores,
              :user_groups,
              :groups,
              :snapshots,
            ])
          end)
        end)
    end

    group
  end
end
