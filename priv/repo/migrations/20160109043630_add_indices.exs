defmodule UwOsu.Repo.Migrations.AddIndices do
  use Ecto.Migration

  def change do
    create index(:score, [:beatmap_id])
    create index(:score, [:user_id])
    create index(:score, [:inserted_at])
  end
end
