defmodule UwOsuStat.Models.User do
  use Ecto.Schema
  alias UwOsuStat.Models.UserSnapshot
  alias UwOsuStat.Models.Event

  schema "user" do
    has_many :snapshots, UserSnapshot
    has_many :events, Event

    timestamps
  end
end

