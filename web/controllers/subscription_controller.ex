defmodule UwOsu.SubscriptionController do
  use UwOsu.Web, :controller
  alias UwOsu.Models.DiscordChannelGroupSubscription

  plug :check_cookie

  defp check_cookie(conn, _) do
    cookie = conn.params["cookie"]
    if cookie != Application.get_env(:uw_osu, :ogs_discord_cookie) do
      conn
      |> put_status(403)
      |> json(%{"detail" => "invalid_cookie"})
      |> halt
    else
      conn
    end
  end

  defp get_subscription(%{"guild_id" => guild_id, "channel_id" => channel_id, "group_id" => group_id}) do
    subscription = Repo.one from s in DiscordChannelGroupSubscription,
      where: s.guild_id == ^guild_id
        and s.channel_id == ^channel_id
        and s.group_id == ^group_id
    subscription
  end

  def create(conn, %{"guild_id" => _guild_id, "channel_id" => _channel_id, "group_id" => _group_id} = params) do
    if get_subscription(params) do
      conn
      |> json(%{})
    else
      changeset = DiscordChannelGroupSubscription.changeset(%DiscordChannelGroupSubscription{}, params)
      Repo.insert! changeset
      conn
      |> json(%{})
    end
  end

  def delete(conn, %{"guild_id" => _guild_id, "channel_id" => _channel_id, "group_id" => _group_id} = params) do
    subscription = get_subscription(params)

    if subscription do
      Repo.delete! subscription
    end

    conn
    |> json(%{})
  end
end
