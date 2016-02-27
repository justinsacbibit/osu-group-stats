defmodule UwOsu.Repo.Migrations.AddTitleToGroup do
  use Ecto.Migration

  def change do
    alter table(:group) do
      add :title, :string, size: 30
      add :verified, :boolean, default: false
    end

    execute """
    UPDATE "group" SET verified = true
    """

    create table(:token) do
      add :user_id, references(:user)
      add :token, :string, size: 20

      timestamps
    end

    create unique_index(:token, [:user_id])
  end
end
