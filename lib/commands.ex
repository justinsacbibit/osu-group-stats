defmodule UwOsu.Commands do
  alias UwOsu.Data

  def create_group(title, mode, players) do
    {:ok, token_str} = Data.Group.get_token("influxd")

    Data.Group.create(token_str, players, mode, title)
  end
end
