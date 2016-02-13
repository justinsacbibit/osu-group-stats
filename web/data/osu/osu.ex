defmodule UwOsu.Osu do
  use HTTPoison.Base

  defp process_url(url) do
    "https://osu.ppy.sh/api" <> url
  end

  defp process_request_body(body) do
    Poison.encode!(body)
  end

  defp process_response_body(body) do
    Poison.decode!(body)
  end

  @doc ~S"""
  Issues an HTTP request to the osu! API to the /get_user endpoint.

  Args:
    * `client` - Instance of the Osu.Client struct.
    * `user` - The username or user id of the user.
    * `params` - Keyword list of optional parameters.

  Params:
    * `:m` - mode (0 = osu!, 1 = Taiko, 2 = CtB, 3 = osu!mania). Default is 0.
  """
  def get_user!(client, user, params \\ []) do
    params = Keyword.put(params, :u, user)

    _get!("/get_user", client, params)
  end

  @doc ~S"""
  Issues an HTTP request to the osu! API to the /get_user_best endpoint.

  Args:
    * `client` - Instance of the Osu.Client struct.
    * `user` - The username or user id of the user.
    * `params` - Keyword list of optional parameters.

  Params:
    * `:m` - mode (0 = osu!, 1 = Taiko, 2 = CtB, 3 = osu!mania). Default is 0.
  """
  def get_user_best!(client, user, params \\ []) do
    params = params
    |> Keyword.put(:u, user)
    |> Keyword.put(:limit, 100)

    _get!("/get_user_best", client, params)
  end

  @doc ~S"""
  Issues an HTTP request to the osu! API to the /get_beatmaps endpoint.

  Args:
    * `client` - Instance of the Osu.Client struct.
    * `params` - Keyword list of optional parameters.

  Params:
    * `:b` - The beatmap id of a single beatmap.
  """
  def get_beatmaps!(client, params \\ []) do
    _get!("/get_beatmaps", client, params)
  end

  defp _get!(path, client, params) do
    params = Keyword.put(params, :k, client.api_key)
    one_minute = 60000
    get!(path, [], params: params, timeout: one_minute, recv_timeout: one_minute)
  end
end

