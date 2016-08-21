defmodule UwOsu.Mixfile do
  use Mix.Project

  def project do
    [app: :uw_osu,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases,
     deps: deps]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {UwOsu, []},
     applications: [:phoenix, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :quantum, :httpoison, :timex,
                    :exirc, :ecto, :cachex]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.1.1"},
     {:phoenix_ecto, "~> 3.0.0-beta.2"},
     {:ecto, "~> 2.0.0-beta.1"},
     {:postgrex, ">= 0.11.1"},
     {:phoenix_html, "~> 2.5"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:exirc, "~> 0.10.0"},
     {:gettext, "~> 0.9"},
     {:cowboy, "~> 1.0"},
     {:quantum, "~> 1.6.1"},
     {:httpoison, "~> 0.8.0"},
     {:cachex, "~> 1.2"},
     {:poison, "~> 1.5"},
     {:mock, "~> 0.1.1", only: :test},
     {:mix_test_watch, "~> 0.2", only: :dev},
     {:timex, "~> 1.0.1"},
     {:edown, github: "uwiger/edown", tag: "0.7", override: true}]
  end

  # Aliases are shortcut or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "phoenix.digest": "my_app.digest"]
  end
end
