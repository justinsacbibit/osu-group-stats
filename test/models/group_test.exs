defmodule UwOsu.GroupTest do
  use UwOsu.ModelCase
  alias UwOsu.Models.Group
  alias UwOsu.Models.User
  alias UwOsu.Repo
  doctest UwOsu.Models.Group

  @user_id 1
  @valid_attrs %{mode: 0, created_by: @user_id, title: "Test Group"}
  @invalid_attrs %{}

  test "valid group" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, @valid_attrs)
    assert changeset.valid?
  end

  test "missing parameters" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, @invalid_attrs)
    assert not changeset.valid?
  end

  test "invalid mode" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, %{mode: 4, created_by: @user_id, title: "Test Group"})
    assert not changeset.valid?
  end

  test "negative mode" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, %{mode: -1, created_by: @user_id, title: "Test Group"})
    assert not changeset.valid?
  end

  test "short title" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, %{mode: 0, created_by: @user_id, title: "Te"})
    assert not changeset.valid?
  end

  test "long title" do
    Repo.insert! User.changeset(%User{}, %{id: @user_id})

    changeset = Group.changeset(%Group{}, %{mode: 0, created_by: @user_id, title: "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"})
    assert not changeset.valid?
  end

  test "existing user" do
    changeset = Group.changeset(%Group{}, %{mode: 0, created_by: @user_id, title: "Test Group"})
    {result, _} = Repo.insert(changeset)
    assert result == :error
  end
end
