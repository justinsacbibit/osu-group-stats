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

  def handle_info({:received, message, from}, {client, _} = state) do
    case UwOsu.Data.Group.handle_irc(message, from) do
      {:ok, token} ->
        # send token
        Logger.debug "Sending token #{token} to #{from}"
        # TODO: send a link in the future instead of the raw token
        # (text)[url]
        if Mix.env == :prod do
          ExIrc.Client.msg(client, :privmsg, from, token)
        end
        {:noreply, state}
      _ ->
        # log error
        Logger.error "Failed to get a token for #{from}"
        if Mix.env == :prod do
          message = "Sorry, there was an issue getting your user information from the osu! servers. Try again later."
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

