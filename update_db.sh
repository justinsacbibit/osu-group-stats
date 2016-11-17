# If the BACKUP_DIR env var is not set, use a default.
: ${BACKUP_DIR:=~/dev/uw_osu_bak}

# Get the filename of the latest backup
BACKUP_FILE=`ls $BACKUP_DIR | tail -n 1`

if ! mix do ecto.drop, ecto.create; then
    exit 1
fi

if ! pg_restore -d uw_osu_dev $BACKUP_DIR/$BACKUP_FILE; then
    exit 1
fi

