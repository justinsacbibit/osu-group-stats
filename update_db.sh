ssh uw dokku postgres:export uw_osu_stat > uw_osu_dump
scp uw:/root/uw_osu_dump .
mix do ecto.drop, ecto.create
pg_restore -d uw_osu_dev uw_osu_dump
rm -f uw_osu_dump

