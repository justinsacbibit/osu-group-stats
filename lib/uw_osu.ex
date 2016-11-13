defmodule UwOsu do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    {:ok, client} = ExIrc.start_client!

    children = [
      # Start the endpoint when the application starts
      supervisor(UwOsu.Endpoint, []),
      # Start the Ecto repository
      supervisor(UwOsu.Repo, []),
      worker(IrcConnectionHandler, [client]),
      worker(IrcLoginHandler, [client, []]),
      # Here you could define other workers and supervisors as children
      # worker(UwOsu.Worker, [arg1, arg2, arg3]),
      worker(Cachex, [UwOsu.Caches.DailySnapshotsCache.cache_name(), []]),
      worker(UwOsu.ScoreNotifier.DataStore, []),
      worker(UwOsu.ScoreNotifier.Worker, []),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: UwOsu.Supervisor]
    supervisor = Supervisor.start_link(children, opts)

    Task.start(&bootstrap/0)

    supervisor
  end

  def bootstrap() do
    UwOsu.Caches.DailySnapshotsCache.hydrate()
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    UwOsu.Endpoint.config_change(changed, removed)
    :ok
  end
end
