use Mix.Config

config :quantum, cron: [
  # Daily at midnight EST
  "0 5 * * *": {UwOsuStat.Data, :collect},
]

config :logger, level: :info

import_config "#{Mix.env}.exs"

