use Mix.Config

config :uw_osu_stat, UwOsuStat.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL")

