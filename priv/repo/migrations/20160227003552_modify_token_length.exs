defmodule UwOsu.Repo.Migrations.ModifyTokenLength do
  use Ecto.Migration

  def change do
    alter table(:token) do
      modify :token, :string, size: 8
    end
  end
end
