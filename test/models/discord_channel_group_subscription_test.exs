defmodule UwOsu.DiscordChannelGroupSubscriptionTest do
  use UwOsu.ModelCase

  alias UwOsu.Models.DiscordChannelGroupSubscription

  @valid_attrs %{channel_id: "some content", guild_id: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = DiscordChannelGroupSubscription.changeset(%DiscordChannelGroupSubscription{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = DiscordChannelGroupSubscription.changeset(%DiscordChannelGroupSubscription{}, @invalid_attrs)
    refute changeset.valid?
  end
end
