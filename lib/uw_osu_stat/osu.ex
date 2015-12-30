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
end

