defmodule UwOsu.ScoreNotifier.Notify do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsu.Osu
  alias UwOsu.Repo
  alias UwOsu.Data.BeatmapCollection
  alias UwOsu.Models.{
    DiscordChannelGroupSubscription,
    Beatmap,
    User,
  }
  alias UwOsu.ScoreNotifier.DataStore

  @doc """
  Sends notifications for new scores.
  """
  def notify() do
    user_ids_and_modes = get_user_ids_and_modes()
    Logger.debug "Going to get scores for user ids and modes:"
    Logger.debug inspect user_ids_and_modes
    ids_and_scores = get_new_scores_for_users(user_ids_and_modes)
    Logger.info "Got new scores: #{inspect ids_and_scores}"
    send_notifications(ids_and_scores)
  end

  # gets users who are currently being subscribed to for score updates
  defp get_user_ids_and_modes() do
    query = from u in User,
      join: ugr in assoc(u, :user_groups),
      join: gr in assoc(ugr, :group),
      join: gs in DiscordChannelGroupSubscription,
        on: gr.id == gs.group_id,
      distinct: [u.id, gr.mode],
      select: {u.id, gr.mode}

    Repo.all query
  end

  # gets scores that were previously not seen for the given users
  defp get_new_scores_for_users(user_ids_and_modes) do
    Enum.reduce(user_ids_and_modes, MapSet.new(), fn(id, acc) ->
      MapSet.union(acc, get_new_scores_for_user(id))
    end)
  end

  # returns a MapSet containing {{user_id, mode}, score, personal best ranking, user, old_user_dict, new_user_dict} tuples
  defp get_new_scores_for_user({user_id, mode} = id) do
    Logger.debug "Getting scores for #{inspect id}"
    # Get user scores
    client = %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
    get_user_best_fn = fn() ->
      {get_user(user_id, mode), Osu.get_user_best!(client, user_id, m: mode, limit: 50)}
    end
    {
      {user, old_user_dict, new_user_dict},
      %HTTPoison.Response{
        body: scores,
      }
    } = try do
      get_user_best_fn.()
    rescue
      e ->
        :timer.sleep :timer.seconds(5)
        get_user_best_fn.()
    end

    {new_scores_mapset, best_map, _idx} = Enum.reduce(scores, {MapSet.new(), %{}, 0}, fn(score_dict, {new_scores_mapset, best_map, idx}) ->
      # %{
      #   "beatmap_id" => beatmap_id,
      #   "score" => score,
      #   "maxcombo" => maxcombo,
      #   "count50" => count50,
      #   "count100" => count100,
      #   "count300" => count300,
      #   "countmiss" => countmiss,
      #   "countkatu" => countkatu,
      #   "countgeki" => countgeki,
      #   "perfect" => perfect,
      #   "enabled_mods" => enabled_mods,
      #   "user_id" => user_id,
      #   "date" => date,
      #   "rank" => rank,
      #   "pp" => pp,
      # } = score_dict
      {MapSet.put(new_scores_mapset, score_dict), Map.put(best_map, score_dict, idx + 1), idx + 1}
    end)

    old_scores_mapset = DataStore.get_and_update_scores(id, new_scores_mapset)

    if is_nil(user) or is_nil(old_scores_mapset) do
      MapSet.new()
    else
      unseen_scores_mapset = MapSet.difference(new_scores_mapset, old_scores_mapset)
      # add on {user_id, mode} tuples
      unseen_scores_mapset
      |> Enum.map(fn(unseen_score) ->
        {id, unseen_score, best_map[unseen_score], user, old_user_dict, new_user_dict}
      end)
      |> MapSet.new
    end
  end

  # sends notifications for the given scores
  defp send_notifications(ids_and_scores) do
    Enum.each(ids_and_scores, fn({{user_id, mode} = id, score, personal_best_rank, user, old_user_dict, new_user_dict}) ->
      # find Discord channels subscribed to this ID
      subscriptions = subscriptions_for_id(id)

      Logger.info "Subscriptions for id #{inspect id}"
      Logger.info inspect subscriptions

      beatmap = get_beatmap(score["beatmap_id"])
      message = build_message(user, old_user_dict, new_user_dict, mode, beatmap, score, personal_best_rank)

      Enum.each(subscriptions, fn(subscription) ->
        send_discord_message(subscription.guild_id, subscription.channel_id, message)
      end)
    end)
  end

  defp get_user(user_id, mode) do
    client = %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
    %HTTPoison.Response{
      body: body,
    } = Osu.get_user!(client, user_id, m: mode)

    case body do
      [user_dict | _] ->
        old_user_dict = DataStore.get_and_update_user_dict({user_id, mode}, user_dict)
        username = user_dict["username"]
        case Repo.get User, user_id do
          nil ->
            changeset = User.changeset(%User{}, %{
              id: user_id,
              username: username,
            })
            user = Repo.insert!(changeset)
            {user, old_user_dict, user_dict}

          user ->
            # Update username
            user = Repo.update! Ecto.Changeset.change(user, username: username)
            {user, old_user_dict, user_dict}
        end
      _ ->
        {nil, nil, nil}
    end
  end

  defp get_beatmap(beatmap_id) do
    # Note: beatmap_id may be a string
    case Repo.get Beatmap, beatmap_id do
      nil ->
        client = %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
        {:ok, beatmap} = BeatmapCollection.fetch_and_process_beatmap(client, beatmap_id)
        beatmap
      beatmap ->
        beatmap
    end
  end

  defp subscriptions_for_id({user_id, mode}) do
    # find Discord channels subscribed to this ID
    subscriptions = Repo.all from gs in DiscordChannelGroupSubscription,
      join: g in assoc(gs, :group),
      join: ug in assoc(g, :user_groups),
      where: g.mode == ^mode and ug.user_id == ^user_id,
      distinct: [gs.guild_id, gs.channel_id]
    subscriptions
  end

  def build_message(user, old_user_dict, new_user_dict, mode, beatmap, score, personal_best_rank) do
    acc = calculate_acc(score)
    {pp, _} = Float.parse(score["pp"])
    "__New score by **#{user.username}**! • **#{format_pp(pp)}** • ##{personal_best_rank} personal best__"
    <> "\n⬥ #{format_mode(mode)} • #{format_global_rank(old_user_dict, new_user_dict)} • #{format_country_rank(old_user_dict, new_user_dict)} • #{format_user_pp(old_user_dict, new_user_dict)}"
    <> "\n⬥ x#{score["maxcombo"]}/#{beatmap.max_combo} • #{score["rank"]} • #{format_score(score["score"])} • #{format_acc(acc, old_user_dict, new_user_dict)} • #{format_mods(score["enabled_mods"])}"
    <> "\n#{beatmap.artist} - #{beatmap.title} [#{beatmap.version}]"
    <> "\n⬥ #{format_length(beatmap.total_length)} • #{format_bpm(beatmap.bpm)} • **#{format_stars(beatmap.difficultyrating)}** • <https://osu.ppy.sh/b/#{beatmap.id}>"
  end

  defp formatted_length(length) do
    "#{div(length, 60)}:#{formatted_seconds(rem(length, 60))}"
  end

  defp formatted_seconds(s) when s < 10, do: "0#{s}"
  defp formatted_seconds(s), do: "#{s}"

  defp calculate_acc(score) do
    {count50, _} = Integer.parse(score["count50"])
    {count100, _} = Integer.parse(score["count100"])
    {count300, _} = Integer.parse(score["count300"])
    {countmiss, _} = Integer.parse(score["countmiss"])
    total_points_of_hits = count50 * 50 + count100 * 100 + count300 * 300
    total_number_of_hits = countmiss + count50 + count100 + count300
    total_points_of_hits / (total_number_of_hits * 300)
  end

  defp format_global_rank(old_user_dict, new_user_dict) do
    change = if old_user_dict["pp_rank"] != new_user_dict["pp_rank"] do
      {old_pp_rank, _} = Integer.parse(old_user_dict["pp_rank"])
      {new_pp_rank, _} = Integer.parse(new_user_dict["pp_rank"])
      sign = if new_pp_rank < old_pp_rank do
        "+"
      else
        ""
      end
      " (#{sign}#{old_pp_rank - new_pp_rank})"
    else
      ""
    end
    "##{new_user_dict["pp_rank"]}#{change}"
  end

  defp format_country_rank(old_user_dict, new_user_dict) do
    change = if old_user_dict["pp_country_rank"] != new_user_dict["pp_country_rank"] do
      {old_pp_country_rank, _} = Integer.parse(old_user_dict["pp_country_rank"])
      {new_pp_country_rank, _} = Integer.parse(new_user_dict["pp_country_rank"])
      sign = if new_pp_country_rank < old_pp_country_rank do
        "+"
      else
        ""
      end
      " (#{sign}#{old_pp_country_rank - new_pp_country_rank})"
    else
      ""
    end
    "#{new_user_dict["country"]}##{new_user_dict["pp_country_rank"]}#{change}"
  end

  defp format_user_pp(old_user_dict, new_user_dict) do
    change = if old_user_dict["pp_raw"] != new_user_dict["pp_raw"] do
      {old_pp_raw, _} = Float.parse(old_user_dict["pp_raw"])
      {new_pp_raw, _} = Float.parse(new_user_dict["pp_raw"])
      sign = if new_pp_raw > old_pp_raw do
        "+"
      else
        ""
      end
      " (#{sign}#{format_float(new_pp_raw - old_pp_raw)})"
    else
      ""
    end
    "#{new_user_dict["pp_raw"]}pp#{change}"
  end

  defp format_stars(stars) do
    "★ #{format_float(stars)}"
  end

  defp format_length(beatmap_length) do
    # TODO
    "#{formatted_length(beatmap_length)}"
  end

  defp format_bpm(bpm) do
    # TODO
    "#{bpm} BPM"
  end

  defp format_mods(mods) do
    # TODO
    "#{mods}"
  end

  defp format_float(float) do
    Float.round(float, 2)
  end

  defp format_acc(acc, old_user_dict, new_user_dict) do
    change = if old_user_dict["accuracy"] != new_user_dict["accuracy"] do
      {old_accuracy, _} = Float.parse(old_user_dict["accuracy"])
      {new_accuracy, _} = Float.parse(new_user_dict["accuracy"])
      sign = if new_accuracy > old_accuracy do
        "+"
      else
        ""
      end
      " (#{sign}#{format_float(new_accuracy - old_accuracy)}%)"
    else
      ""
    end
    "#{format_float(acc * 100)}%#{change}"
  end

  defp format_score(score) do
    # TODO
    "#{score}"
  end

  defp format_pp(pp) do
    "#{format_float(pp)}pp"
  end

  defp format_mode(0) do
    "osu!"
  end
  defp format_mode(1) do
    "Taiko"
  end
  defp format_mode(2) do
    "CatchTheBeat"
  end
  defp format_mode(3) do
    "osu!mania"
  end

  def send_discord_message(guild_id, channel_id, message) do
    Logger.info "Sending to guild_id=#{guild_id} channel_id=#{channel_id}: \n#{message}"
    bot_url = Application.get_env(:uw_osu, :truckbot_url)
    cookie = Application.get_env(:uw_osu, :truckbot_cookie)
    data = %{"guild_id" => guild_id, "channel_id" => channel_id, "message" => message, "cookie" => cookie}
    json = Poison.encode!(data)
    result = HTTPoison.post bot_url <> "/ogs-score", json, [{"Content-Type", "application/json"}], timeout: 20000, recv_timeout: 20000
    Logger.info inspect result
  end
end
