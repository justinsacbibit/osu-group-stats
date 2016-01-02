defmodule UwOsuStat.Osu do
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

  def get_user!(user, client) do
    _get!("/get_user", client, %{u: user})
  end

  def get_user_best!(user, client) do
    _get!("/get_user_best", client, %{u: user})
  end

  def get_beatmaps!(params, client) do
    _get!("/get_beatmaps", client, params)
  end

  defp _get!(path, client, params \\ %{}) do
    params = Dict.merge(params, %{k: client.api_key})
    get!(path, [], params: params)
  end
end

