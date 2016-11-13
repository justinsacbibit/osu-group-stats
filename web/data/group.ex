defmodule UwOsu.Data.Group do
  require Logger
  import Ecto.Query, only: [from: 2]
  alias UwOsu.Osu
  alias UwOsu.Models.{Group, User, UserGroup, Token}
  alias UwOsu.Repo

  @max_group_size Application.get_env(:uw_osu, :max_group_size)
  @max_groups Application.get_env(:uw_osu, :max_groups)

  defmodule Error do
    defexception reason: nil, status_code: nil

    def message(%__MODULE__{reason: reason, status_code: status_code}) do
      "[Status code: #{status_code}] #{inspect reason}"
    end
  end

  defimpl Plug.Exception, for: Error do
    def status(%Error{status_code: status_code}), do: status_code
  end

  @doc ~S"""
  Creates or retrieves a token when a user messages us with "!token" through the
  osu! IRC.
  """
  def get_token(username) do
    with {:ok, user_id} <- find_user_id(username),
         {:ok, _} <- create_user_if_necessary(user_id, username),
         do: get_token_for_user_id(user_id)
  end

  defp create_user_if_necessary(user_id, username) do
    case Repo.get(User, user_id) do
      nil ->
        changeset = User.changeset(%User{}, %{
          id: user_id,
          username: username,
        })

        case Repo.insert(changeset) do
          {:error, _error} ->
            # TODO: Include changeset errors in error reason.
            {:error, %Error{reason: "Failed to create user", status_code: 500}}
          {:ok, user} ->
            {:ok, user}
        end
      user ->
        {:ok, user}
    end
  end

  defp get_token_for_user_id(user_id) do
    case Repo.get_by(Token, user_id: user_id) do
      nil ->
        token = Token.new(user_id)
        case Repo.insert(token) do
          {:ok, token} ->
            {:ok, token}
          {:error, _changeset} ->
            # TODO: Include changeset errors in error reason.
            {:error, %Error{reason: "Failed to generate token", status_code: 500}}
        end
      token ->
        {:ok, token}
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
    {:error, %Error{reason: "Failed to get user id for #{username}", status_code: 502}}
  end

  def create(_token, user_ids_or_usernames, _mode, _title)
  when not is_list(user_ids_or_usernames) do
    {:error, %Error{reason: "user ids or usernames must be an array", status_code: 400}}
  end

  def create(_token, user_ids_or_usernames, _title, _mode)
  when length(user_ids_or_usernames) == 0 do
    {:error, %Error{reason: "must specify at least one user id/username", status_code: 400}}
  end

  @doc ~S"""
  Attempts to create an group with the given user ids/usernames and title.

  If the token or any of the given user ids/usernames are found to be invalid, an error is raised.

  Otherwise, the created group is returned.

  The group creator should acquire a token through the osu! IRC by sending "!token" to
  a designated user (currently influxd)
  """
  def create(token_str, user_ids_or_usernames, mode, title) do
    with {:ok, token} <- validate_token(token_str),
         {:ok} <- validate_max_groups(token),
         {:ok, user_ids} <- validate_user_ids_or_usernames(user_ids_or_usernames),
         do: create_group(token, user_ids, mode, title)
  end

  def validate_token(token_str) do
    case Repo.get_by(Token, token: token_str) do
      nil ->
        {:error, %Error{reason: "Invalid token: #{token_str}", status_code: 400}}
      token ->
        {:ok, token}
    end
  end

  def add_to_group(token_str, user_ids_or_usernames, group_id) do
    with {:ok, token} <- validate_token(token_str),
         {:ok, group} <- get_group(token, group_id),
         {:ok, user_ids} <- validate_user_ids_or_usernames(user_ids_or_usernames),
         {:ok, _} <- add_user_groups(user_ids, group, token),
         do: {:ok, group}
  end

  defp add_user_groups(user_ids, group, token) do
    transaction_result = Repo.transaction(fn ->
      Repo.delete!(token)

      Enum.map(user_ids, fn(user_id) ->
        changeset = UserGroup.changeset(%UserGroup{}, %{
          user_id: user_id,
          group_id: group.id,
          })
        Repo.insert!(changeset)
      end)
    end)

    case transaction_result do
      {:ok, user_groups} ->
        {:ok, user_groups}
      _error ->
        # TODO: Use error
        {:error, %Error{status_code: 400, reason: "Error trying to add users to group"}}
    end
  end

  defp get_group(token, group_id) do
    query = from g in Group,
      where: g.id == ^group_id and ^token.user_id == g.created_by

    case Repo.one(query) do
      nil ->
        {:error, %Error{reason: "That group does not exist", status_code: 404}}
      group ->
        {:ok, group}
    end
  end

  defp create_group(token, user_ids, mode, title) do
    Repo.transaction(fn ->
      changeset = Group.changeset(%Group{}, %{
        created_by: token.user_id,
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
          %{"user_id" => user_id, "username" => username} = user
          {:ok, _} = create_user_if_necessary(user_id, username)
          {:cont, [user_id | acc]}
        _ ->
          {:halt, user_id_or_username}
      end
    end)

    if is_list(valid_user_ids) do
      {:ok, valid_user_ids}
    else
      {:error, %Error{status_code: 502, reason: "failed to get user #{valid_user_ids}, make sure user exists or try again later"}}
    end
  end

  defp validate_max_groups(%Token{user_id: user_id})
  when user_id == 1579374 do
    # hardcoded exception for now.
    # TODO: in the future, the database should store
    # permissions so that certain users can create unlimited/more groups
    {:ok}
  end

  defp validate_max_groups(%Token{user_id: user_id}) do
    query = from g in Group,
      join: u in assoc(g, :creator),
      where: u.id == ^user_id,
      select: count(g.id)
    [groups_created] = Repo.all(query)

    if groups_created < @max_groups do
      {:ok}
    else
      {:error, %Error{status_code: 400, reason: "You are not allowed to create more than #{@max_groups} groups"}}
    end
  end
end
