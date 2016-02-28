defmodule UwOsu.Repo.Migrations.IncreaseEventDisplayHtmlLength do
  use Ecto.Migration

  def change do
    alter table(:event) do
      modify :display_html, :string, null: false, size: 400
    end
  end
end
