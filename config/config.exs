use Mix.Config

config :quantum, cron: [
  # Daily at midnight EST
  "0 5 * * *": {UwOsuStat.Data, :collect},

  # Daily 1:00 AM EST
  "0 6 * * *": {UwOsuStat.Data, :collect_beatmaps},
]

config :uw_osu_stat, osu_api_key: System.get_env("OSU_API_KEY")

config :logger, level: :info

import_config "#{Mix.env}.exs"

