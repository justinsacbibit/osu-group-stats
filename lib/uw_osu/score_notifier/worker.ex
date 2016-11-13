defmodule UwOsu.ScoreNotifier.Worker do
  def start_link do
    Task.start_link(&work/0)
  end

  def work do
    :timer.sleep :timer.minutes(3)

    UwOsu.ScoreNotifier.Notify.notify()
  end
end
