defmodule UwOsu.Commands do
  alias UwOsu.Data

  def create_group(title, mode, players) do
    {:ok, token_str} = Data.Group.get_token("influxd")

    Data.Group.create(token_str, players, mode, title)
  end

  def add_to_group(group_id, players) do
    {:ok, token_str} = Data.Group.get_token("influxd")

    Data.Group.add_to_group(token_str, players, group_id)
  end
end
