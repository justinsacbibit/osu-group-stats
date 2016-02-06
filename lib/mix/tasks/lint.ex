defmodule Mix.Tasks.UwOsu.Lint do
  use Mix.Task

  def run(_args) do
    Mix.Shell.IO.cmd "eslint ./web/static/js"
  end
end
