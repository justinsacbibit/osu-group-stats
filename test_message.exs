beatmap = %{
  max_combo: 645,
  id: 996108,
  artist: "fhana",
  title: "little secret magic",
  version: "Linada's Insane",
}

old_user_dict =
  Poison.decode! """
  {"user_id":"1579374","username":"influxd","count300":"12884729","count100":"784156","count50":"71457","playcount":"69456","ranked_score":"20270389999","total_score":"130492242187","pp_rank":"1779","level":"101.036","pp_raw":"6262.98","accuracy":"99.20572662353516","count_rank_ss":"94","count_rank_s":"849","count_rank_a":"922","country":"CA","pp_country_rank":"76","events":[{"display_html":"<img src='\/images\/A_small.png'\/> <b><a href='\/u\/1579374'>influxd<\/a><\/b> achieved rank #937 on <a href='\/b\/1005016?m=0'>petit milady - Hakone Hakoiri Musume [Anais' Extra]<\/a> (osu!)","beatmap_id":"1005016","beatmapset_id":"470000","date":"2016-11-18 00:26:47","epicfactor":"1"}]}
  """

new_user_dict =
  Poison.decode! """
  {"user_id":"1579374","username":"influxd","count300":"12884729","count100":"784156","count50":"71457","playcount":"69456","ranked_score":"20270389999","total_score":"130492242187","pp_rank":"1773","level":"101.036","pp_raw":"6264.98","accuracy":"99.22572662353533","count_rank_ss":"94","count_rank_s":"849","count_rank_a":"922","country":"CA","pp_country_rank":"74","events":[{"display_html":"<img src='\/images\/A_small.png'\/> <b><a href='\/u\/1579374'>influxd<\/a><\/b> achieved rank #937 on <a href='\/b\/1005016?m=0'>petit milady - Hakone Hakoiri Musume [Anais' Extra]<\/a> (osu!)","beatmap_id":"1005016","beatmapset_id":"470000","date":"2016-11-18 00:26:47","epicfactor":"1"}]}
  """

user = %{
  username: "floorrip",
}

score = Poison.decode! """
{"beatmap_id":"799913","score":"13121834","maxcombo":"742","count50":"0","count100":"1","count300":"549","countmiss":"1","countkatu":"1","countgeki":"149","perfect":"0","enabled_mods":"16","user_id":"1579374","date":"2016-10-02 05:20:42","rank":"A","pp":"332.681"}
"""

IO.puts UwOsu.ScoreNotifier.Notify.build_message(user, old_user_dict, new_user_dict, 0, beatmap, score, 2)
