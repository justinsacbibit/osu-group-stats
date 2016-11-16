defmodule UwOsu.OsuUtils do
  @moduledoc """
  Provides a set of utility functions related to osu!.
  """

  use Bitwise

  @doc """
  Converts a set of mods (in integer format) to a list of abbreviated mod strings.
  """
  def mods_to_strings(mods) when is_integer(mods) do
    mod_map = [
      {"NF", 1},
      {"EZ", 2},
      {"HD", 8},
      {"HR", 16},
      {"SD", 32},
      {"DT", 64},
      {"RX", 128},
      {"HT", 256},
      {"NC", 512},
      {"FL", 1024},
      {"AU", 2048},
      {"SO", 4096},
      {"AP", 8192},
      {"PF", 16384},
    ]

    mod_strs = for {mod_str, mod_val} <- mod_map, (mods &&& mod_val) > 0 do
      mod_str
    end

    mod_strs
  end
end
