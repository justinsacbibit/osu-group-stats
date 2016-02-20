defmodule UwOsu.Data.UserCollection do
  import Ecto.Query, only: [from: 2]
  require Logger
  alias UwOsu.Osu
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.DynamicGroup
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Group
  alias UwOsu.Models.Score
  alias UwOsu.Models.User
  alias UwOsu.Models.UserGroup
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Repo

  """
  Get the user ids of the top 1,000 players in osu! by performance points.
  """
  def find_top do
    HTTPoison.start
    pages = 1..200
    pages = 1..20 # TODO: Remove when we want to increase to 10,000
    pages
    |> Enum.map(fn(page) ->
      url = "https://osu.ppy.sh/p/pp/?m=0&s=3&o=1&page=#{page}"
      %HTTPoison.Response{body: body} = HTTPoison.get!(url)

      ids = Regex.scan(~r/a href=("|')\/u\/(?<id>\d+)("|')/, body)
      |> Enum.map(fn([_, _, string_id, _]) ->
        {int, _} = Integer.parse(string_id)
        int
      end)
    end)
    |> List.flatten
  end
  
  def update_10k do
    Repo.transaction &update_10k_dynamic_group/0
  end

  # need to get top 10,000 players into a dynamic group
  # once the group is created, the users in them should be dynamically updated
  defp update_10k_dynamic_group do
    dynamic_group_id = 1 # this should probably be a constant somewhere
    
    # look for the dynamic group. if it doesn't exist:
    #   create the group and the dynamic group and return the group id
    # otherwise:
    #   get the group id
    group_id = case Repo.get(DynamicGroup, dynamic_group_id) do
      nil ->
        group = Group.changeset(%Group{}, %{mode: 0})
        |> Repo.insert!
        
        DynamicGroup.changeset(%DynamicGroup{}, %{id: dynamic_group_id, group_id: group.id})
        |> Repo.insert!
        
        Logger.info "Created 10k group with id #{group.id}"
        
        group.id
      d_group ->
        %DynamicGroup{group: group} = Repo.preload(d_group, :group)
        Logger.info "Using 10k group with id #{group.id}"
        group.id
    end
  
    from(ug in UserGroup, where: ug.group_id == ^group_id)
    |> Repo.delete_all
    
    user_ids = find_top()
    
    user_ids
    |> Enum.each(fn(user_id) ->
      if Repo.get(User, user_id) == nil do
        Repo.insert!(User.changeset(%User{}, %{id: user_id}))
      end
      
      UserGroup.changeset(%UserGroup{}, %{
        user_id: user_id,
        group_id: group_id,
      })
      |> Repo.insert!
    end)
  end

  def collect(
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
  ) do
    modes = [0, 1, 2, 3]
    Enum.each(modes, fn(mode) ->
      collect_mode mode, client
    end)
  end

  def collect_dynamic(
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)}
  ) do
    modes = [0]
    Enum.each(modes, fn(mode) ->
      collect_mode mode, client, true
    end)
  end

  def collect_mode(
    mode,
    client \\ %Osu.Client{api_key: Application.get_env(:uw_osu, :osu_api_key)},
    is_dynamic \\ false,
    attempts_remaining \\ 5
  ) do
    if attempts_remaining > 0 do
      attempt_number = 5 - attempts_remaining + 1
      Logger.info "Beginning collection of mode #{mode} on try ##{attempt_number}"
      Osu.start

      try do
        query = case is_dynamic do
          true ->
            from u in User,
              join: ugr in assoc(u, :user_groups),
              join: gr in assoc(ugr, :group),
              join: dgr in assoc(gr, :dynamic_group), # only get dynamic groups
              where: gr.mode == ^mode,
              distinct: [u.id],
              select: u.id
          false ->
            from u in User,
              join: ugr in assoc(u, :user_groups),
              join: gr in assoc(ugr, :group),
              where: gr.mode == ^mode and is_nil(gr.dynamic_group),
              distinct: [u.id],
              select: u.id
        end
        user_ids = Repo.all query

        Repo.transaction fn ->
          changeset = Generation.changeset(%Generation{}, %{
            mode: mode,
          })
          generation = Repo.insert!(changeset)
          generation_id = generation.id
          Logger.info "Generation #{generation_id}"

          Enum.each user_ids, fn(user_id) ->
            # why is there a transaction in my transaction
            Repo.transaction fn ->
              process_user(user_id, generation, client)
              if is_dynamic do
                # since there are a lot of players in our dynamic group,
                # space out the requests
                :timer.sleep 1000
              end
            end
          end
        end
        Logger.info "Successfully collected mode #{mode} on try ##{attempt_number}"
      rescue
        e ->
          # TODO: Pass error through logger
          IO.inspect e
          Logger.error "Failed to collect mode #{mode} on try ##{attempt_number}"
          :timer.sleep 10000
          collect_mode mode, client, is_dynamic, attempts_remaining - 1
      end
    end
  end

  defp process_user(user_id, generation, client) do
    # Get user
    %HTTPoison.Response{
      body: body,
    } = Osu.get_user!(client, user_id, m: generation.mode)

    case body do
      [user_dict | _] ->
        case user_dict["count300"] do
          nil ->
            Logger.warn "Skipping user with id #{user_id} for mode #{generation.mode}"
          _ ->
            process_user_dict user_dict, generation, client
        end
      _ ->
        Logger.warn "Skipping user with id #{user_id} - get_user returned empty array"
    end
  end

  defp process_user_dict(user_dict, generation, client) do
    username = user_dict["username"]
    id = user_dict["user_id"]
    Logger.debug "Processing for user #{username} (#{id}) with generation #{generation.id}"

    # Update username
    user = Repo.get!(User, id)
    Repo.update! Ecto.Changeset.change(user, username: username)

    # Create snapshot
    snapshot_dict = Dict.merge user_dict, %{
      "user_id" => id,
      "generation_id" => generation.id
    }
    snapshot = UserSnapshot.changeset(%UserSnapshot{}, snapshot_dict)
    Repo.insert!(snapshot)

    Enum.each(user_dict["events"], fn(event_dict) ->
      beatmap_id = event_dict["beatmap_id"]
      date = event_dict["date"]

      query = from e in Event,
        where: e.user_id == ^id
          and e.beatmap_id == ^beatmap_id
          and e.date == ^date

      case Repo.one(query) do
        nil ->
          event = Event.changeset(%Event{}, %{
            user_id: id,
            display_html: event_dict["display_html"],
            beatmap_id: beatmap_id,
            beatmapset_id: event_dict["beatmapset_id"],
            date: date,
            epicfactor: event_dict["epicfactor"],
          })
          Repo.insert(event)
        _ ->
          :ok
      end
    end)

    # Get user scores
    %HTTPoison.Response{
      body: scores,
    } = Osu.get_user_best!(client, id, m: generation.mode)

    Enum.each(scores, fn(score_dict) ->
      {:ok, date} = Ecto.DateTime.cast(score_dict["date"])

      query = from s in Score,
        where: s.user_id == ^id
          and s.date == ^date

      case Repo.one(query) do
        nil ->
          score_dict = Dict.merge score_dict, %{
            "user_id" => id,
          }
          score = Score.changeset(%Score{}, score_dict)
          Repo.insert(score)
        _ ->
          :ok
      end
    end)
  end
end
