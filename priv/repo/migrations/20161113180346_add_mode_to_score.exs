defmodule UwOsu.Repo.Migrations.AddModeToScore do
  use Ecto.Migration
  import Ecto.Query, only: [from: 2]
  alias UwOsu.Models.Score
  alias UwOsu.Repo

  def up do
    alter table(:score) do
      add :mode, :integer
    end

    flush()

    scores = Repo.all from s in Score,
      where: is_nil(s.mode)
    IO.inspect(length scores)

    execute "
    UPDATE score s
    SET mode = b.mode
    FROM beatmap b
    WHERE s.beatmap_id = b.id
    "

    flush()

    scores = Repo.all from s in Score,
      where: is_nil(s.mode)
    IO.inspect(length scores)

    alter table(:score) do
      modify :mode, :integer, null: false
    end
  end

  def down do
    alter table(:score) do
      remove :mode
    end
  end
end
