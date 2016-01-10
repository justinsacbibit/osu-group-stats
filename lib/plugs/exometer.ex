defmodule PlugExometer do
  @behaviour Plug
  import Plug.Conn, only: [register_before_send: 2]
  alias :exometer, as: Exometer

  def init(opts), do: opts

  def call(conn, _config) do
    before_time = :os.timestamp

    register_before_send conn, fn conn ->
      after_time = :os.timestamp
      diff       = :timer.now_diff after_time, before_time

      Exometer.update [:uw_osu, :webapp, :resp_time], diff / 1_000
      Exometer.update [:uw_osu, :webapp, :resp_count], 1
      conn
    end
  end
end

