use Mix.Config

# For production, we configure the host to read the PORT
# from the system environment. Therefore, you will need
# to set PORT=80 before running your server.
#
# You should also configure the url host to something
# meaningful, we use this information when generating URLs.
#
# Finally, we also include the path to a manifest
# containing the digested version of static files. This
# manifest is generated by the mix phoenix.digest task
# which you typically run after static files are built.
config :uw_osu, UwOsu.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [host: "uw_osu.sacbibit.com", port: 80],
  cache_static_manifest: "priv/static/manifest.json"

# Do not print debug messages in production
config :logger, level: :info

# ## SSL Support
#
# To get SSL working, you will need to add the `https` key
# to the previous section and set your `:url` port to 443:
#
#     config :uw_osu, UwOsu.Endpoint,
#       ...
#       url: [host: "example.com", port: 443],
#       https: [port: 443,
#               keyfile: System.get_env("SOME_APP_SSL_KEY_PATH"),
#               certfile: System.get_env("SOME_APP_SSL_CERT_PATH")]
#
# Where those two env variables return an absolute path to
# the key and cert in disk or a relative path inside priv,
# for example "priv/ssl/server.key".
#
# We also recommend setting `force_ssl`, ensuring no data is
# ever sent via http, always redirecting to https:
#
#     config :uw_osu, UwOsu.Endpoint,
#       force_ssl: [hsts: true]
#
# Check `Plug.SSL` for all available options in `force_ssl`.

# ## Using releases
#
# If you are doing OTP releases, you need to instruct Phoenix
# to start the server for all endpoints:
#
#     config :phoenix, :serve_endpoints, true
#
# Alternatively, you can configure exactly which server to
# start per endpoint:
#
#     config :uw_osu, UwOsu.Endpoint, server: true
#
# You will also need to set the application root to `.` in order
# for the new static assets to be served after a hot upgrade:
#
#     config :uw_osu, UwOsu.Endpoint, root: "."


config :uw_osu, UwOsu.Endpoint,
  secret_key_base: System.get_env("SECRET_KEY_BASE")

# Configure your database
config :uw_osu, UwOsu.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: System.get_env("DATABASE_URL"),
  pool_size: 20

# missing aronyoo
config :uw_osu, user_ids: [
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
  5063503,
  "Arneshie-",
]

config :uw_osu, excluded_user_ids: [
  "ChronoTrig",
  "Flandre-",
]

