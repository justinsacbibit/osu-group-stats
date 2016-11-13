defmodule UwOsu.ScoreNotifier.DataStore do
  def start_link do
    Agent.start_link(fn -> %{scores: %{}, user_dicts: %{}} end, name: __MODULE__)
  end

  def get_and_update_scores(id, new_scores) do
    Agent.get_and_update(__MODULE__, fn(%{scores: old_scores} = state) ->
      {old_scores[id], %{state | scores: Map.put(old_scores, id, new_scores)}}
    end)
  end

  def get_and_update_user_dict(id, new_user_dict) do
    Agent.get_and_update(__MODULE__, fn(%{user_dicts: old_user_dicts} = state) ->
      {old_user_dicts[id], %{state | user_dicts: Map.put(old_user_dicts, id, new_user_dict)}}
    end)
  end
end
