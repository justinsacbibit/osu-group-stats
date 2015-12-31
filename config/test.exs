use Mix.Config

config :logger, level: :warn

config :uw_osu_stat, UwOsuStat.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  database: "uw_osu_stat_test",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :uw_osu_stat, user_ids: [
  "testuser",
]

