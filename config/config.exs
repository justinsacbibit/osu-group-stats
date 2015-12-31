use Mix.Config

config :quantum, cron: [
  # Daily at midnight EST
  "0 5 * * *": {UwOsuStat.Data, :collect},
]

config :logger, level: :info

config :uw_osu_stat, UwOsuStat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "uw_osu_stat",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :uw_osu_stat, osu_api_key: System.get_env("OSU_API_KEY")

import_config "#{Mix.env}.exs"

