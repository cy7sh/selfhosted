#!/usr/bin/env bash

crash_passwd=$(pass borg/crash)
immich_passwd=$(pass borg/immich)

export BORG_PASSPHRASE=$crash_passwd
export BORG_REMOTE_PATH=borg1
export BORG_BASE_DIR=/root

borg=/opt/borg/borg
rsync=de3911@de3911.rsync.net

echo "backing up immich_db"
docker exec -t immich_db pg_dumpall --clean --if-exists --username=postgres | gzip > /home/cy/immich_dump.sql.gz
echo "backing up forgejo_db"
docker exec -t forgejo_db pg_dumpall --clean --if-exists --username=forgejo | gzip > /home/cy/forgejo_dump.sql.gz
echo "backing up freshrss"
docker exec -t freshrss "./cli/db-backup.php"
echo "backing up vaultwarden"
sudo sqlite3 /vw-data/db.sqlite3 ".backup '/home/cy/vaultwarden_db-$(date '+%Y%m%d-%H%M').sqlite3'"

echo "uploading to borg"
sudo -E $borg create --progress -sx --exclude-from borgback_exclude --exclude-caches $rsync:borg/crash::{hostname}-{now:%Y-%m-%dT%H:%M} \
                              /vw-data \
                              /home \
                              /opt \
                              /root \
                              /etc

sudo -E $borg prune --keep-within 2d --keep-daily 7 --keep-weekly 52 --keep-yearly 10 --stats $rsync:borg/crash

#echo "uploading imich to borg"
#export BORG_PASSPHRASE=$immich_passwd
#sudo -E $borg create --noxattrs --noacls --progress -sx $rsync:borg/immich::immich-{now:%Y-%m-%dT%H:%M} /mnt/photos/immich
#sudo -E $borg prune --keep-within 2d --keep-daily 7 --keep-weekly 52 --keep-yearly 10 --stats $rsync:borg/immich
