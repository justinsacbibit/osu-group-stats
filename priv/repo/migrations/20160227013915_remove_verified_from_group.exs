defmodule UwOsu.Repo.Migrations.RemoveVerifiedFromGroup do
  use Ecto.Migration

  def change do
    alter table(:group) do
      remove :verified
    end
  end
end
