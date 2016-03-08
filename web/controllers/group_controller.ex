defmodule UwOsu.GroupController do
  import Ecto.Query, only: [from: 2]
  use UwOsu.Web, :controller
  alias UwOsu.Data
  alias UwOsu.Data.Query
  alias UwOsu.Models.Group
  alias UwOsu.Repo

  def index(conn, _params) do
    groups = Repo.all(Query.get_groups)
    render(conn, "groups.json", groups: groups)
  end

  def show(conn, %{"id" => id}) do
    query = from g in Group,
      where: g.id == ^id,
      preload: [:users]
    group = Repo.first!(query)
    render(conn, "group.json", group: group)
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
