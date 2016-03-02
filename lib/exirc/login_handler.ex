defmodule IrcLoginHandler do
  require Logger

  def start_link(client, channels) do
    GenServer.start_link(__MODULE__, [client, channels])
  end

  def init([client, channels]) do
    ExIrc.Client.add_handler client, self
    {:ok, {client, channels}}
  end

  def handle_info(:logged_in, state = {client, channels}) do
    debug "Logged into server"
    channels |> Enum.map(&ExIrc.Client.join client, &1)
    {:noreply, state}
  end

  def handle_info({:received, message, from}, {client, _} = state) when message == "!token\n" do
    case UwOsu.Data.Group.get_token(from) do
      {:ok, token} ->
        # send token
        Logger.debug "Sending token #{token} to #{from}"
        # TODO: send a link in the future instead of the raw token
        # (text)[url]
        if Mix.env == :prod do
          message = "https://ogs.sacbibit.com/g/new?t=#{token}"
          Logger.debug message
          ExIrc.Client.msg(client, :privmsg, from, message)
        end
        {:noreply, state}
      {:error, error} ->
        # log error
        Logger.error "Failed to get a token for #{from}: #{inspect error}"
        if Mix.env == :prod do
          message = "Sorry, there was an issue getting your user information from the osu! servers. Try again later. If this keeps occurring, send a PM to influxd."
          ExIrc.Client.msg(client, :privmsg, from, message)
        end
        {:noreply, state}
    end
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp debug(msg) do
    IO.puts IO.ANSI.yellow() <> msg <> IO.ANSI.reset()
  end
end

