defmodule UwOsu.ApiData do
  def user(overrides \\ %{}) do
    default = %{
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
    }
    Dict.merge(default, overrides)
  end

  def event(overrides \\ %{}) do
    default = %{
      "display_html" => "<img src='/images/S_small.png'/> <b><a href='/u/1579374'>influxd</a></b> achieved rank #998 on <a href='/b/696783?m=0'>AKINO from bless4 - MIIRO [Hime]</a> (osu!)",
      "beatmap_id" => "696783",
      "beatmapset_id" => "312042",
      "date" => "2015-12-31 14:31:35",
      "epicfactor" => "1",
    }
    Dict.merge(default, overrides)
  end

  def score(overrides \\ %{}) do
    default = %{
      "beatmap_id" => "759192",
      "score" => "69954590",
      "maxcombo" => "1768",
      "count50" => "0",
      "count100" => "16",
      "count300" => "1263",
      "countmiss" => "1",
      "countkatu" => "9",
      "countgeki" => "203",
      "perfect" => "0",
      "enabled_mods" => "0",
      "user_id" => "1579374",
      "date" => "2015-12-28 04:25:55",
      "rank" => "A",
      "pp" => "281.856",
    }
    Dict.merge(default, overrides)
  end

  def beatmap(overrides) do
    default = %{
      "approved" => "1",
      "approved_date" => "2013-07-02 01:01:12",
      "last_update" => "2013-07-06 16:51:22",
      "artist" => "Luxion",
      "beatmap_id" => "252002",
      "beatmapset_id" => "93398",
      "bpm" => "196.5",
      "creator" => "RikiH",
      "difficultyrating" => "5.59516",
      "diff_size" => "3.8",
      "diff_overall" => "6.01",
      "diff_approach" => "9.2",
      "diff_drain" => "6.7",
      "hit_length" => "113",
      "source" => "BMS",
      "genre_id" => "1",
      "language_id" => "5",
      "title" => "High-Priestess",
      "total_length" => "145",
      "version" => "Overkill",
      "file_md5" => "c8f08438204abfcdd1a748ebfae67421",
      "mode" => "0",
      "tags" => "melodious long",
      "favourite_count" => "121",
      "playcount" => "9001",
      "passcount" => "1337",
      "max_combo" => "2101",
    }
    Dict.merge default, overrides
  end
end
