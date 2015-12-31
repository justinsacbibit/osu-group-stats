use Mix.Config

config :uw_osu_stat, UwOsuStat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "uw_osu_stat",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :uw_osu_stat, user_ids: [
  "influxd",
]

