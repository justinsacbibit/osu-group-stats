defmodule UwOsu.Repo.Migrations.CreateDiscordChannelGroupSubscription do
  use Ecto.Migration

  def change do
    create table(:discord_channel_group_subscription, primary_key: false) do
      add :guild_id, :string, primary_key: true
      add :channel_id, :string, primary_key: true
      add :group_id, references(:group, on_delete: :nothing), primary_key: true

      timestamps()
    end
    create index(:discord_channel_group_subscription, [:group_id])

  end
end
