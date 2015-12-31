defmodule DataTest do
  use ExUnit.Case
  import Ecto.Query, only: [from: 2]
  alias UwOsuStat.Repo
  alias UwOsuStat.Data
  alias UwOsuStat.Osu
  alias UwOsuStat.Models.Generation
  alias UwOsuStat.Models.User
  alias UwOsuStat.Models.UserSnapshot
  alias Ecto.Adapters.SQL
  import Mock
  doctest UwOsuStat.Data

  setup do
    SQL.begin_test_transaction(Repo)

    on_exit fn ->
      SQL.rollback_test_transaction(Repo)
    end
  end

  defp get_next_generation_id do
    %{rows: [[next_generation_id]]} = SQL.query!(Repo, "select nextval('generation_id_seq')", [])
    next_generation_id + 1
  end

  defp invariant_check(next_generation_id, user_ids) do
    assert called Osu.start

    # should create generation
    Repo.get!(Generation, next_generation_id)

    Enum.map user_ids, fn(user_id) ->
      # should create user
      Repo.get!(User, user_id)
    end
  end

  test_with_mock "snapshot", Osu, [
    start: fn -> end,
    get_user!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [%{
          "user_id" => "123",
          "username" => "testuser",
          "count300" => "8260346",
          "count100" => "639175",
          "count50" => "63029",
          "playcount" => "45432",
          "ranked_score" => "13352117327",
          "total_score" => "70088502830",
          "pp_rank" => "2815",
          "level" => "100.432",
          "pp_raw" => "5033.02",
          "accuracy" => "99.01136779785156",
          "count_rank_ss" => "81",
          "count_rank_s" => "632",
          "count_rank_a" => "650",
          "country" => "CA",
          "pp_country_rank" => "103",
          "events" => [],
        }]} end,
    get_user_best!: fn(123, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123]

    # should create user_snapshot
    snapshot = Repo.get_by!(UserSnapshot, user_id: 123, generation_id: next_generation_id)
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

  test_with_mock "only one generation is created per run", Osu, [
    start: fn -> end,
    get_user!: fn(id, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [%{
          "user_id" => "#{id}",
          "username" => "testuser",
          "count300" => "8260346",
          "count100" => "639175",
          "count50" => "63029",
          "playcount" => "45432",
          "ranked_score" => "13352117327",
          "total_score" => "70088502830",
          "pp_rank" => "2815",
          "level" => "100.432",
          "pp_raw" => "5033.02",
          "accuracy" => "99.01136779785156",
          "count_rank_ss" => "81",
          "count_rank_s" => "632",
          "count_rank_a" => "650",
          "country" => "CA",
          "pp_country_rank" => "103",
          "events" => [],
        }]} end,
    get_user_best!: fn(_id, %Osu.Client{api_key: "abc"}) -> %HTTPoison.Response{body: [
      ]} end,
  ] do
    next_generation_id = get_next_generation_id

    Data.collect [123, 456], %Osu.Client{api_key: "abc"}

    invariant_check next_generation_id, [123, 456]

    query = from g in Generation, select: count(g.id)
    assert Repo.one!(query) == 1
  end
end
