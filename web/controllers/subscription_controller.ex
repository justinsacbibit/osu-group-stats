defmodule UwOsu.SubscriptionController do
  use UwOsu.Web, :controller
  alias UwOsu.Models.DiscordChannelGroupSubscription

  plug :check_cookie

  defp check_cookie(conn, _) do
    cookie = conn.params["cookie"]
    if cookie == Application.get_env(:uw_osu, :ogs_discord_cookie) do
      conn
      |> put_status(403)
      |> json(%{"detail" => "invalid_cookie"})
      |> halt
    else
      conn
    end
  end

  def create(conn, %{"guild_id" => _guild_id, "channel_id" => _channel_id, "group_id" => _group_id} = params) do
    changeset = DiscordChannelGroupSubscription.changeset(%DiscordChannelGroupSubscription{}, params)
    IO.inspect changeset
    Repo.insert! changeset
    conn
    |> json(%{})
  end

  def delete(conn, %{"guild_id" => guild_id, "channel_id" => channel_id, "group_id" => group_id}) do
    subscription = Repo.one from s in DiscordChannelGroupSubscription,
      where: s.guild_id == ^guild_id
        and s.channel_id == ^channel_id
        and s.group_id == ^group_id

    if subscription do
      Repo.delete! subscription
    end

    conn
    |> json(%{})
  end
end
