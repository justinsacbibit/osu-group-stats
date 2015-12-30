# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
use Mix.Config

# This configuration is loaded before any dependency and is restricted
# to this project. If another project depends on this project, this
# file won't be loaded nor affect the parent project. For this reason,
# if you want to provide default values for your application for
# 3rd-party users, it should be done in your "mix.exs" file.

# You can configure for your application as:
#
#     config :uw_osu_stat, key: :value
#
# And access this configuration in your application as:
#
#     Application.get_env(:uw_osu_stat, :key)
#
# Or configure a 3rd-party app:
#
#     config :logger, level: :info
#
config :uw_osu_stat, UwOsuStat.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "uw_osu_stat",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :uw_osu_stat, osu_api_key: System.get_env("OSU_API_KEY")

# missing aronyoo
config :uw_osu_stat, user_ids: [
  2674642,
  4228684,
  2808490,
  2088002,
  3327171,
  2652543,
  2652396,
  3340651,
  1041913,
  3330914,
  634507,
  1612531,
  2480551,
  2540301,
  3374058,
  320840,
  3323120,
  2241406,
  4702207,
  2099102,
  4036304,
  3060856,
  3652010,
  2364968,
  3474962,
  2285338,
  4944565,
  3530842,
  1749093,
  1327000,
  3270303,
  1227415,
  1948780,
  3524845,
  2501611,
  1671487,
  4384210,
  5071315,
  3160913,
  3607046,
  55761,
  3522811,
  3499910,
  3230571,
  183830,
  1844801,
  3392917,
  1579374,
  2624025,
  2200307,
  3905113,
  3327052,
  3465394,
  3687489,
  3993851,
  4383481,
  2593681,
  1826949,
  2594079,
  1377458,
  2015506,
  3780350,
  6425166,
  3764793,
  4782895,
  4995101,
  5895597,
  2446880,
  2130039,
]

config :quantum, cron: [
  "@daily": {UwOsuStat.Data, :collect},
  #"* * * * *": {UwOsuStat.Data, :collect},
]

# It is also possible to import configuration files, relative to this
# directory. For example, you can emulate configuration per environment
# by uncommenting the line below and defining dev.exs, test.exs and such.
# Configuration from the imported file will override the ones defined
# here (which is why it is important to import them last).
#
import_config "#{Mix.env}.exs"
