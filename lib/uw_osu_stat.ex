defmodule UwOsuStat.App do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec
    tree = [
      supervisor(UwOsuStat.Repo, []),
    ]
    opts = [name: UwOsuStat.Sup, strategy: :one_for_one]
    Supervisor.start_link(tree, opts)
  end
end

