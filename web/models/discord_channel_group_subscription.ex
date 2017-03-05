defmodule UwOsu.Models.DiscordChannelGroupSubscription do
  use UwOsu.Web, :model

  @primary_key false
  schema "discord_channel_group_subscription" do
    field :guild_id, :string, primary_key: true
    field :channel_id, :string, primary_key: true
    belongs_to :group, UwOsu.Models.Group, primary_key: true

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:guild_id, :channel_id, :group_id])
    |> validate_required([:guild_id, :channel_id, :group_id])
  end
end
