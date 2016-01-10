# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# Configures the endpoint
config :uw_osu, UwOsu.Endpoint,
  url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "44wBBPYrQSanX8X0qyUCDrYArlLydcc4aLzKfhyPrTTaj/ciGERVR9dbMuHhHA/i",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: UwOsu.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :quantum, cron: [
  # Daily at midnight EST
  "0 5 * * *": {UwOsu.Data, :collect},

  # Daily 1:00 AM EST
  "0 6 * * *": {UwOsu.Data, :collect_beatmaps},
]

config :uw_osu, osu_api_key: System.get_env("OSU_API_KEY")

import_config "exometer.exs"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"

# Configure phoenix generators
config :phoenix, :generators,
  migration: true,
  binary_id: false
