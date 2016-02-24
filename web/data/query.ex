defmodule UwOsu.Data.Query do
  import Ecto.Query, only: [from: 2]
  use Timex
  alias UwOsu.Models.Beatmap
  alias UwOsu.Models.Event
  alias UwOsu.Models.Generation
  alias UwOsu.Models.Group
  alias UwOsu.Models.Score
  alias UwOsu.Models.User
  alias UwOsu.Models.UserGroup
  alias UwOsu.Models.UserSnapshot
  alias UwOsu.Repo

  def get_groups do
    from g in Group,
      preload: [:users]
  end

  def get_users(group_id, days_delta \\ 0) do
    date = Date.now("America/Toronto")
    |> Date.subtract({0, days_delta * 86400, 0})
    from u in User,
      join: s in assoc(u, :snapshots),
      join: g in assoc(s, :generation),
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: gr.id == ugr.group_id and gr.mode == g.mode,
      # TODO: Use window function to find the snapshot that is closest to midnight EST?
      where: fragment("(?)::date", s.inserted_at) == type(^date, Ecto.Date),
      distinct: [u.id],
      preload: [snapshots: s]
  end

  def get_users_with_snapshots(group_id) do
    from u in User,
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id,
      join: s in UserSnapshot,
        on: s.user_id == u.id,
      join: g in Generation,
        on: s.generation_id == g.id and g.mode == gr.mode,
      join: i in fragment("
      SELECT MIN(s.inserted_at), s.user_id, g.mode
      FROM user_snapshot s
      JOIN generation g
      ON s.generation_id = g.id
      WHERE s.inserted_at::time >= '5:00'
      GROUP BY s.inserted_at::date, s.user_id, g.mode
      "),
        on: s.inserted_at == i.min
        and s.user_id == i.user_id
        and i.mode == gr.mode,
      order_by: [asc: s.inserted_at],
      preload: [snapshots: s]
  end

  #def get_weekly_snapshots do
    #from s1 in UserSnapshot,
      #join: g1 in assoc(s1, :generation),
      #join: s2 in UserSnapshot,
      #join: g2 in assoc(s2, :generation),
      #where: s1.user_id == s2.user_id and fragment("(?)::date = '2016-01-06'", g1.inserted_at) and
        #g2.inserted_at == fragment("
        #(SELECT MIN(g.inserted_at)
        #FROM generation g
        #JOIN user_snapshot s
        #ON s.user_id = (?) AND s.generation_id = g.id
        #WHERE g.inserted_at::date >= '2015-12-30')
          #", s1.user_id),
      #select: {
        #s1,
        #s2,
        #%{
          #"playcount" => fragment("(?) - (?)", s1.playcount, s2.playcount),
          #"pp_rank" => fragment("(?) - (?)", s1.pp_rank, s2.pp_rank),
          #"level" => fragment("(?) - (?)", s1.level, s2.level),
          #"pp_raw" => fragment("(?) - (?)", s1.pp_raw, s2.pp_raw),
          #"accuracy" => fragment("(?) - (?)", s1.accuracy, s2.accuracy),
          #"pp_country_rank" => fragment("(?) - (?)", s1.pp_country_rank, s2.pp_country_rank),
        #},
      #}
  #end

  def get_farmed_beatmaps(group_id) do
    from b in Beatmap,
      join: sc_ in fragment(
      """
      (
      SELECT *
      FROM (
        SELECT *,
          dense_rank()
          OVER (PARTITION BY group_id ORDER BY score_count DESC) AS score_ranking
        FROM (
          SELECT x.mode, beatmap_id, x.id, group_id,
            count(*)
            OVER (PARTITION BY beatmap_id) AS score_count
          FROM (
            SELECT sc.*,
              b.mode,
              row_number()
              OVER (PARTITION BY sc.user_id, b.mode
                ORDER BY sc.pp DESC) AS ranking
            FROM (
              SELECT DISTINCT ON (sc.user_id, sc.beatmap_id) sc.*
              FROM score sc
              ORDER BY sc.user_id, sc.beatmap_id, sc.score DESC
            ) sc
            JOIN beatmap b
              ON sc.beatmap_id = b.id
          ) x
          JOIN user_group ugr
            ON ugr.user_id = x.user_id
          JOIN "group" g
            ON ugr.group_id = g.id
          WHERE ranking <= 100
        ) x
      ) x
      WHERE score_ranking <= 10
      )
      """),
        on: sc_.beatmap_id == b.id,
      join: sc in Score,
        on: sc.id == sc_.id,
      join: u in User,
        on: u.id == sc.user_id,
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id and gr.mode == b.mode,
      order_by: [desc: sc_.score_ranking],
      preload: [scores: {sc, user: u}],
      select: b
  end

  def get_latest_scores(group_id, before, since) do
    {:ok, before} = Ecto.DateTime.cast before
    {:ok, since} = Ecto.DateTime.cast since
    from u in User,
      join: s in assoc(u, :scores),
      join: b in assoc(s, :beatmap),
      join: ugr in UserGroup,
        on: ugr.group_id == ^group_id and ugr.user_id == u.id,
      join: gr in Group,
        on: ugr.group_id == gr.id and b.mode == gr.mode,
      where: fragment("(?) >= (?)", s.date, type(^since, Ecto.DateTime)) and fragment("(?) < (?)", s.date, type(^before, Ecto.DateTime)),
      order_by: [desc: s.score],
      distinct: [u.id, s.beatmap_id],
      preload: [scores: {s, beatmap: b}]
  end
end

