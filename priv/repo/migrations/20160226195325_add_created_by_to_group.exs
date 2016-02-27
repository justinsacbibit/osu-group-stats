defmodule UwOsu.Repo.Migrations.AddCreatedByToGroup do
  use Ecto.Migration

  def change do
    alter table(:group) do
      add :created_by, :integer
    end

    execute """
    UPDATE "group" SET created_by = 1579374
    """

    alter table(:group) do
      modify :created_by, references(:user), null: false
    end
  end
end
