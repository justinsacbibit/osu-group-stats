defmodule UwOsu.Repo do
  use Ecto.Repo, otp_app: :uw_osu

  def log(log_entry) do
    #:ok = :exometer.update ~w(uw_osu ecto query_exec_time)a, (log_entry.query_time + (log_entry.queue_time || 0)) / 1_000
    #:ok = :exometer.update ~w(uw_osu ecto query_queue_time)a, (log_entry.queue_time || 0) / 1_000
    #:ok = :exometer.update ~w(uw_osu ecto query_count)a, 1

    super log_entry
  end
end
