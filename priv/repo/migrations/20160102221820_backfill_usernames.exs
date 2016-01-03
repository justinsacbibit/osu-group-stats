defmodule UwOsuStat.Repo.Migrations.BackfillUsernames do
  use Ecto.Migration

  def change do
    execute("""
    UPDATE "user" u
    SET username = s.username
    FROM user_snapshot s
    INNER JOIN
      (SELECT user_id, MAX(inserted_at) FROM user_snapshot GROUP BY user_id) i
      ON i.MAX = s.inserted_at
      AND i.user_id = s.user_id
    WHERE
      i.user_id = u.id
    """)
  end
end
