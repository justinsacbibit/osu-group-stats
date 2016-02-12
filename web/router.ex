defmodule UwOsu.Router do
  use UwOsu.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug PlugExometer
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug PlugExometer
  end

  scope "/api", UwOsu do
    pipe_through :api

    get "/weekly-snapshots", DataController, :weekly_snapshots
    get "/farmed-beatmaps", DataController, :farmed_beatmaps
    get "/players", DataController, :players
    get "/daily-snapshots", DataController, :daily_snapshots
    get "/latest-scores", DataController, :latest_scores
    get "/groups", DataController, :groups
    get "/generations", DataController, :generations
  end

  scope "/", UwOsu do
    pipe_through :browser # Use the default browser stack

    get "*path", PageController, :index
  end
end
