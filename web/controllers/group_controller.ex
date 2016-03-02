defmodule UwOsu.GroupController do
  use UwOsu.Web, :controller
  alias UwOsu.Data
  alias UwOsu.Data.Query
  alias UwOsu.Repo

  def index(conn, _params) do
    groups = Repo.all(Query.get_groups)
    render(conn, "groups.json", groups: groups)
  end

  def create(conn, %{"group" => group_params}) do
    result = Data.Group.create(
      group_params["token"],
      group_params["players"],
      group_params["mode"],
      group_params["title"]
    )
    case result do
      {:ok, group} ->
        render(conn, "group.json", group: group)
      {:error, error} ->
        raise error
    end
  end
end
