defmodule UwOsuStat.Mixfile do
  use Mix.Project

  def project do
    [app: :uw_osu_stat,
     version: "0.0.1",
     elixir: "~> 1.1",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {UwOsuStat.App, []},
     env: [
       osu_api_key: System.get_env("OSU_API_KEY"),
     ],
     applications: [
       :logger,
       :postgrex,
       :ecto,
       :quantum,
       :httpoison,
     ]]
  end

  defp description do
    """
    Use the osu! API to store data for a set of players.
    """
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "LICENSE*"],
     maintainers: ["Justin Sacbibit"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/justinsacbibit/uw-osu-stat"}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:postgrex, "~> 0.10.0"},
     {:ecto, "~> 1.1.1"},
     {:quantum, "~> 1.6.1"},
     {:httpoison, "~> 0.8.0"},
     {:poison, "~> 1.5"},
     {:mock, "~> 0.1.1", only: :test},
     {:mix_test_watch, "~> 0.2", only: :dev}]
  end
end
