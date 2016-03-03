defmodule DataGroupTest do
  use UwOsu.ModelCase
  import Ecto.Query, only: [from: 2]
  alias UwOsu.ApiData
  alias UwOsu.Data
  alias UwOsu.Models.{Group, Token, User}
  alias UwOsu.Osu
  alias UwOsu.Repo
  import Mock
  doctest UwOsu.Data.Group

  test_with_mock "get token for a username", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{"user_id" => "123"})],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    {:ok, token} = Data.Group.get_token("testuser")

    assert token.user_id == user_id
  end

  test_with_mock "get token returns an error when the username does not exist", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [],
      }
    end
  ] do
    {:error, _} = Data.Group.get_token("testuser")
  end

  test_with_mock "get token reuses an existing token", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{"user_id" => "123"})],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    {:ok, token} = Data.Group.get_token("testuser")
    {:ok, second_token} = Data.Group.get_token("testuser")

    assert token.id == second_token.id
  end

  test_with_mock "get token for user not yet in db creates a user", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{"user_id" => "123"})],
      }
    end
  ] do
    {:ok, token} = Data.Group.get_token("testuser")

    user_id = 123
    Repo.get!(User, user_id)
    assert token.user_id == user_id
  end

  test_with_mock "group creation with invalid token", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{})],
      }
    end
  ] do
    {:error, error} = Data.Group.create("", [], 0, "Test Group")

    assert error.status_code == 400
  end

  test_with_mock "group creation when osu! api returns not found", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))
    token = Repo.insert!(Token.new(user_id))

    {:error, error} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")

    assert error.status_code == 502
  end

  test_with_mock "group creation deletes token", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{})],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    token = Repo.insert!(Token.new(user_id))
    {:ok, _group} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")

    assert is_nil(Repo.get(Token, token.id))
  end

  test_with_mock "group creation creates group", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{})],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    token = Repo.insert!(Token.new(user_id))
    {:ok, group} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")

    Repo.get!(Group, group.id)
  end

  test_with_mock "group creation with too many groups", Osu, [
    get_user!: fn(_client, _username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{})],
      }
    end
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    token = Repo.insert!(Token.new(user_id))
    {:ok, _} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")

    token = Repo.insert!(Token.new(user_id))
    {:ok, _} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")

    token = Repo.insert!(Token.new(user_id))
    {:error, error} = Data.Group.create(token.token, ["testuser"], 0, "Test Group")
    assert error.status_code == 400
  end

  test_with_mock "add a player to an existing group", Osu, [
    get_user!: fn(_client, username, _opts) ->
      %HTTPoison.Response{
        body: [ApiData.user(%{
          "username" => username,
          "user_id" => case username do
            "testuser1" ->
              123
            "testuser2" ->
              456
            _ ->
              -1
          end,
        })],
      }
    end,
  ] do
    user_id = 123
    Repo.insert!(User.changeset(%User{}, %{id: user_id}))

    token = Repo.insert!(Token.new(user_id))
    {:ok, group} = Data.Group.create(token.token, ["testuser1"], 0, "Test Group")

    query = from u in User,
      join: g in assoc(u, :groups),
      where: g.id == ^group.id,
      select: count(u.id)
    [count] = Repo.all(query)

    assert count == 1

    token = Repo.insert!(Token.new(user_id))
    {:ok, _} = Data.Group.add_to_group(token.token, ["testuser2"], group.id)

    [count] = Repo.all(query)

    assert count == 2
  end
end
