defmodule UwOsu.Caches.DailySnapshotsCache do
  require Logger
  alias UwOsu.{
    Repo,
    DataView,
  }
  alias UwOsu.Data.Query

  @cache_name :daily_snapshots_cache

  def cache_name, do: @cache_name

  defp cache_key(group_id), do: "daily_snapshots?g=#{group_id}"

  def hydrate() do
    # TODO: Hydrate all groups with a request time > 5 seconds

    # Group 1 takes more than 20 seconds
    get_gzipped(1)
  end

  def get_gzipped(group_id) do
    {status, raw} = Cachex.get(@cache_name, cache_key(group_id), fallback: fn(_key) ->
      users = Repo.all(Query.get_users_with_snapshots(group_id), timeout: :timer.seconds(40))
      DataView.render("daily_snapshots.json", %{users: users})
      |> Poison.encode!
      |> :zlib.gzip
    end)

    case status do
      :loaded -> Logger.info("Daily snapshots cache miss")
      :ok -> Logger.info("Daily snapshots cache hit")
      _ -> :ok
    end

    raw
  end

  def clear() do
    Cachex.clear(@cache_name)
  end
end
