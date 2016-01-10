defmodule :"Elixir.UwOsu.Repo.Migrations.RemoveFlandre-Chronotrig" do
  use Ecto.Migration

  def change do
    execute """
    ALTER TABLE event
    DROP CONSTRAINT event_user_id_fkey,
    ADD CONSTRAINT event_user_id_fkey
      FOREIGN KEY (user_id)
      REFERENCES "user"(id)
      ON DELETE CASCADE
    """
    execute """
    ALTER TABLE score
    DROP CONSTRAINT score_user_id_fkey,
    ADD CONSTRAINT score_user_id_fkey
      FOREIGN KEY (user_id)
      REFERENCES "user"(id)
      ON DELETE CASCADE
    """
    execute """
    ALTER TABLE user_snapshot
    DROP CONSTRAINT user_snapshot_user_id_fkey,
    ADD CONSTRAINT user_snapshot_user_id_fkey
      FOREIGN KEY (user_id)
      REFERENCES "user"(id)
      ON DELETE CASCADE
    """

    execute """
    DELETE FROM "user" WHERE id = 3687489 OR id = 2624025
    """
  end
end
