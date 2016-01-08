ExUnit.start

Mix.Task.run "ecto.create", ~w(-r UwOsu.Repo --quiet)
Mix.Task.run "ecto.migrate", ~w(-r UwOsu.Repo --quiet)
Ecto.Adapters.SQL.begin_test_transaction(UwOsu.Repo)

