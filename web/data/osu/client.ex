defmodule UwOsu.Osu.Client do
  @moduledoc """
  The osu! API client struct. Used for authentication when making requests to
  the osu! API.
  """

  defstruct api_key: nil

  def new(api_key) do
    %__MODULE__{api_key: api_key}
  end

  def new do
    new(Application.get_env(:uw_osu, :osu_api_key))
  end
end

