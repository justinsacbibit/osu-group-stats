defmodule UwOsuStat.Models.Types.IntString do
  @behaviour Ecto.Type
  def type, do: :integer

  # Provide our own casting rules.
  def cast(string) when is_binary(string) do
    case Integer.parse(string) do
      {int, _} -> {:ok, int}
      :error   -> :error
    end
  end

  # We should still accept integers
  def cast(integer) when is_integer(integer), do: {:ok, integer}

  # Everything else is a failure though
  def cast(_), do: :error

  # When loading data from the database, we are guaranteed to
  # receive an integer (as databases are strict) and we will
  # just return it to be stored in the model struct.
  def load(integer) when is_integer(integer), do: {:ok, integer}

  # When dumping data to the database, we *expect* an integer
  # but any value could be inserted into the struct, so we need
  # guard against them.
  def dump(integer) when is_integer(integer), do: {:ok, integer}
  def dump(_), do: :error
end

