defmodule UwOsu.Router do
  use UwOsu.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UwOsu do
    pipe_through :api

    get "/weekly-snapshots", DataController, :weekly_snapshots
    get "/farmed-beatmaps", DataController, :farmed_beatmaps
    get "/players", DataController, :players
    get "/players/:id", DataController, :show_player
    get "/daily-snapshots", DataController, :daily_snapshots
    get "/latest-scores", DataController, :latest_scores
    get "/generations", DataController, :generations

    get "/groups", GroupController, :index
    get "/groups/:id", GroupController, :show
    post "/groups", GroupController, :create
  end

  scope "/", UwOsu do
    pipe_through :browser # Use the default browser stack

    get "*path", PageController, :index
  end
end
