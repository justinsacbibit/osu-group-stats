defmodule UserCollectionTest do
  use UwOsu.ModelCase
  import Ecto.Query, only: [from: 2]
  alias UwOsu.ApiData
  alias UwOsu.Data.UserCollection
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Group
  alias UwOsu.Models.Score
  alias UwOsu.Models.User
  alias UwOsu.Models.UserGroup
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Osu
  alias UwOsu.Repo
  import Mock
  doctest UwOsu.Data.UserCollection

  test_with_mock "user's username is set", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) ->
      %HTTPoison.Response{body: [ApiData.user(%{"username" => "testuser"})]}
    end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [ ]} end,
  ] do
    # create a group with a single user (who has a nil username)
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    # should update user's username
    user = Repo.get!(User, 123)
    assert user.username == "testuser"
  end

  test_with_mock "user snapshot is saved", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) ->
      %HTTPoison.Response{body: [ApiData.user]}
    end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [ ]} end,
  ] do
    # create a group with a single user
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    # should create user_snapshot
    snapshot = Repo.one!(UserSnapshot)
    assert snapshot.user_id == 123
    assert snapshot.username == "testuser"
    assert snapshot.count300 == 8260346
    assert snapshot.count100 == 639175
    assert snapshot.count50 == 63029
    assert snapshot.playcount == 45432
    assert snapshot.ranked_score == 13352117327
    assert snapshot.total_score == 70088502830
    assert snapshot.pp_rank == 2815
    assert snapshot.level == 100.432
    assert snapshot.pp_raw == 5033.02
    assert snapshot.accuracy == 99.01136779785156
    assert snapshot.count_rank_ss == 81
    assert snapshot.count_rank_s == 632
    assert snapshot.count_rank_a == 650
    assert snapshot.country == "CA"
    assert snapshot.pp_country_rank == 103
  end

  test_with_mock "events are saved", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) -> %HTTPoison.Response{body: [
        ApiData.user %{"events" => [ApiData.event]}
      ]} end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    # create a group with a single user
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    # should create event
    event = Repo.get_by!(Event, user_id: 123)
    assert event.display_html == "<img src='/images/S_small.png'/> <b><a href='/u/1579374'>influxd</a></b> achieved rank #998 on <a href='/b/696783?m=0'>AKINO from bless4 - MIIRO [Hime]</a> (osu!)"
    assert event.beatmap_id == 696783
    assert event.beatmapset_id == 312042
    assert event.date == Ecto.DateTime.cast("2015-12-31 14:31:35") |> elem(1)
    assert event.epicfactor == 1
  end

  test_with_mock "should not create duplicate event", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) ->
      %HTTPoison.Response{body: [
        ApiData.user %{"events" => [ApiData.event, ApiData.event]}
      ]} end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [ ]} end,
  ] do
    # create a group with a single user
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    query = from e in Event, select: count(e.id)
    assert Repo.one!(query) == 1
  end

  test_with_mock "top 100 scores are saved", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) ->
      %HTTPoison.Response{body: [
        ApiData.user
      ]} end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [
        ApiData.score
      ]} end,
  ] do
    # create a group with a single user
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    # should create score
    score = Repo.get_by!(Score, user_id: 123)
    assert score.beatmap_id == 759192
    assert score.score == 69954590
    assert score.maxcombo == 1768
    assert score.count50 == 0
    assert score.count100 == 16
    assert score.count300 == 1263
    assert score.countmiss == 1
    assert score.countkatu == 9
    assert score.countgeki == 203
    assert score.perfect == 0
    assert score.enabled_mods == 0
    assert score.date == Ecto.DateTime.cast("2015-12-28 04:25:55") |> elem(1)
    assert score.rank == "A"
    assert score.pp == 281.856
  end

  test_with_mock "should not save duplicate scores", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, 123, m: 0) ->
      %HTTPoison.Response{body: [
        ApiData.user
      ]} end,
    get_user_best!: fn(_, _, _) -> %HTTPoison.Response{body: [
        ApiData.score,
        ApiData.score
      ]} end,
  ] do
    # create a group with a single user
    Repo.insert!(User.changeset(%User{}, %{id: 123}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    query = from s in Score, select: count(s.id)
    assert Repo.one!(query) == 1
  end

  test_with_mock "only one generation is created per run", Osu, [
    start: fn -> end,
    get_user!: fn(%Osu.Client{api_key: "abc"}, id, m: 0) ->
      %HTTPoison.Response{body: [
        ApiData.user %{"user_id" => "#{id}"}
      ]} end,
    get_user_best!: fn(_, _, _) ->
      %HTTPoison.Response{body: [ ]} end,
  ] do
    # create a group with two users
    Repo.insert!(User.changeset(%User{}, %{id: 123}))
    Repo.insert!(User.changeset(%User{}, %{id: 456}))

    %Group{
      id: group_id,
    } = Repo.insert!(Group.changeset(%Group{}, %{mode: 0}))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 123,
    }))

    Repo.insert!(UserGroup.changeset(%UserGroup{}, %{
      group_id: group_id,
      user_id: 456,
    }))

    UserCollection.collect(%Osu.Client{api_key: "abc"})

    query = from g in Generation,
      where: g.mode == 0,
      select: count(g.id)
    assert Repo.one!(query) == 1
  end
end

