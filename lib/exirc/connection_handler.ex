defmodule IrcConnectionHandler do
  defmodule State do
    defstruct host: "irc.ppy.sh",
              port: 6667,
              pass: System.get_env("OSU_IRC_PASSWORD"),
              nick: System.get_env("OSU_IRC_USERNAME"),
              user: System.get_env("OSU_IRC_USERNAME"),
              name: System.get_env("OSU_IRC_USERNAME"),
              client: nil
  end

  def start_link(client, state \\ %State{}) do
    GenServer.start_link(__MODULE__, [%{state | client: client}])
  end

  def init([state]) do
    ExIrc.Client.add_handler state.client, self
    ExIrc.Client.connect! state.client, state.host, state.port
    {:ok, state}
  end

  def handle_info({:connected, server, port}, state) do
    debug "Connected to the osu!Bancho at #{server}:#{port}"
    ExIrc.Client.logon state.client, state.pass, state.nick, state.user, state.name
    {:noreply, state}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end

