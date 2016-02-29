defmodule UwOsu.Data.Group do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsu.Osu
  alias UwOsu.Models.{Group, User, UserGroup, Token}
  alias UwOsu.Repo

  @max_group_size Application.get_env(:uw_osu, :max_group_size)
  @max_groups Application.get_env(:uw_osu, :max_groups)

  defmodule ForbiddenError do
    defexception [:message]

    def exception(opts) do
      message = Keyword.fetch!(opts, :message)
      %__MODULE__{message: message}
    end
  end

  defimpl Plug.Exception, for: ForbiddenError do
    def status(_), do: 403
  end

  defimpl Plug.Exception, for: InvalidGroupParametersError do
    def status(_), do: 400
  end

  defmodule InvalidGroupParametersError do
    defexception [:message]

    def exception(opts) do
      message = Keyword.fetch!(opts, :message)
      %__MODULE__{message: message}
    end
  end

  defimpl Plug.Exception, for: InvalidGroupParametersError do
    def status(_), do: 400
  end

  defmodule DataFetchingError do
    defexception [:message]

    def exception(opts) do
      message = case Keyword.fetch(opts, :message) do
        {:ok, value} ->
          value
        _ ->
          "Error fetching data from the osu! API. Please try again later"
      end
      %__MODULE__{message: message}
    end
  end

  defimpl Plug.Exception, for: DataFetchingError do
    def status(_), do: 500
  end

  defmodule InvalidTokenError do
    defexception [:message]

    def exception(opts) do
      token = Keyword.fetch!(opts, :token)

      %__MODULE__{message: "Invalid token: #{token}"}
    end
  end

  defimpl Plug.Exception, for: InvalidTokenError do
    def status(_), do: 400
  end

  @doc ~S"""
  Creates or retrieves a token when a user messages us with "!token" through the
  osu! IRC.
  """
  def get_token(from) do
    case find_user_id(from) do
      {:ok, user_id} ->
        case Repo.get_by(Token, user_id: user_id) do
          nil ->
            token = Token.new(user_id) |> Repo.insert!
            {:ok, token.token}
          token ->
            {:ok, token.token}
        end
      error ->
        error
    end
  end

  defp find_user_id(username, attempts_remaining \\ 5)

  # Attempts to retrieve the user id for the user with the given username. Retries
  # up to 5 times.
  defp find_user_id(username, attempts_remaining) when attempts_remaining > 0 do
    client = Osu.Client.new()
    %HTTPoison.Response{
      body: body,
    } = Osu.get_user!(client, username, m: 0)

    case body do
      [user] ->
        {:ok, user["user_id"]}
      _ ->
        find_user_id(username, attempts_remaining - 1)
    end
  end

  defp find_user_id(username, _attempts_remaining) do
    {:error, "Failed to get user id for #{username}"}
  end

  def create(_token, user_ids_or_usernames, _mode, _title)
  when not is_list(user_ids_or_usernames) do
    raise InvalidGroupParametersError, message: "user ids or usernames must be an array"
  end

  def create(_token, _user_ids_or_usernames, mode, _title)
  when not is_number(mode) do
    raise InvalidGroupParametersError, message: "mode must be a number"
  end

  def create(_token, _user_ids_or_usernames, mode, _title)
  when mode < 0 or mode > 3 do
    raise InvalidGroupParametersError, message: "must specify a mode between 0 and 3"
  end

  def create(_token, user_ids_or_usernames, _title, _mode)
  when length(user_ids_or_usernames) == 0 do
    raise InvalidGroupParametersError, message: "must specify at least one user id/username"
  end

  @doc ~S"""
  Attempts to create an group with the given user ids/usernames and title.

  If the token or any of the given user ids/usernames are found to be invalid, an error is raised.

  Otherwise, the created group is returned.

  The group creator should acquire a token through the osu! IRC by sending "!token" to
  a designated user (currently influxd)
  """
  def create(token_str, user_ids_or_usernames, mode, title) do
    token = Repo.get_by(Token, token: token_str)
    unless token do
      raise InvalidTokenError, token: token_str
    end
    creator_id = token.user_id
    # validate that this creator has not exceeded the number of allowed groups
    validate_max_groups(creator_id)

    user_ids = validate_user_ids_or_usernames(user_ids_or_usernames)

    create_group(creator_id, user_ids, mode, title, token)
  end

  def add_to_group(token_str, user_ids_or_usernames, group_id) do
    token = Repo.get_by(Token, token: token_str)
    unless token do
      raise InvalidTokenError, token: token_str
    end
    creator_id = token.user_id

    group = Repo.get!(Group, group_id)

    unless group.created_by == creator_id do
      raise ForbiddenError, message: "You are not allowed to edit that group"
    end

    user_ids = validate_user_ids_or_usernames(user_ids_or_usernames)

    {:ok, group} = Repo.transaction(fn ->
      Enum.each(user_ids, fn(user_id) ->
        changeset = UserGroup.changeset(%UserGroup{}, %{
          user_id: user_id,
          group_id: group.id,
        })
        Repo.insert!(changeset)
      end)
      Repo.delete!(token)
      group
    end)

    group
  end

  defp create_group(creator_id, user_ids, mode, title, token) do
    {:ok, group} = Repo.transaction(fn ->
      changeset = Group.changeset(%Group{}, %{
        created_by: creator_id,
        mode: mode,
        title: title
      })
      group = Repo.insert!(changeset)

      Enum.each(user_ids, fn(user_id) ->
        changeset = UserGroup.changeset(%UserGroup{}, %{
          user_id: user_id,
          group_id: group.id,
        })
        Repo.insert!(changeset)
      end)
      Repo.delete!(token)
      group
    end)

    group
  end

  defp validate_user_ids_or_usernames(user_ids_or_usernames) do
    # validate using osu! API
    client = Osu.Client.new()
    valid_user_ids = Enum.reduce_while(user_ids_or_usernames, [], fn(user_id_or_username, acc) ->
      %HTTPoison.Response{
        body: body,
      } = Osu.get_user!(client, user_id_or_username, m: 0)

      case body do
        [user] ->
          # insert into DB if necessary
          id = user["user_id"]
          if Repo.get(User, id) |> is_nil do
            changeset = User.changeset(%User{}, %{
              id: id,
              username: user["username"],
            })
            Repo.insert!(changeset)
          end
          {:cont, [id | acc]}
        _ ->
          {:halt, user_id_or_username}
      end
    end)

    unless is_list(valid_user_ids) do
      raise DataFetchingError, message: "failed to get user #{valid_user_ids}, make sure user exists or try again later"
    else
      valid_user_ids
    end
  end

  defp validate_max_groups(creator_id) when creator_id == 1579374 do
    # hardcoded exception for now.
    # TODO: in the future, the database should store
    # permissions so that certain users can create unlimited/more groups
    :ok
  end

  defp validate_max_groups(creator_id) do
    query = from g in Group,
      join: u in assoc(g, :creator),
      where: u.id == ^creator_id,
      select: count(g.id)
    groups_created = Repo.first!(query)

    unless groups_created < @max_groups do
      raise InvalidGroupParametersError, message: "you are not allowed to create more than #{@max_groups} groups"
    end
  end
end

