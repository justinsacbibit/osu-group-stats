defmodule UwOsu.Osu do
  use HTTPoison.Base

  defp process_url(url) do
    "https://osu.ppy.sh/api" <> url
  end

  defp process_request_body(body) do
    body
    |> Poison.encode!
  end

  defp process_response_body(body) do
    body
    |> Poison.decode!
  end

  def get_user!(user, mode, client) do
    _get!("/get_user", client, %{u: user, m: mode})
  end

  def get_user_best!(user, mode, client) do
    _get!("/get_user_best", client, %{u: user, limit: 100, m: mode})
  end

  def get_beatmaps!(params, client) do
    _get!("/get_beatmaps", client, params)
  end

  defp _get!(path, client, params \\ %{}) do
    params = Dict.merge(params, %{k: client.api_key})
    one_minute = 60000
    get!(path, [], params: params, timeout: one_minute, recv_timeout: one_minute)
  end
end

