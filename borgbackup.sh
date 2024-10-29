#!/usr/bin/env bash

export BORG_PASSPHRASE=$(pass borg/crash)
export BORG_REMOTE_PATH=borg1
export BORG_BASE_DIR=/root

borg=/opt/borg/borg
rsync=de3911@de3911.rsync.net

echo "backing up immich_db"
docker exec -t immich_db pg_dumpall --clean --if-exists --username=postgres | gzip > /home/cy/immich_dump.sql.gz
echo "backing up miniflux_db"
docker exec -t miniflux_db pg_dumpall --clean --if-exists --username=miniflux | gzip > /home/cy/miniflux_dump.sql.gz
echo "backing up forgejo_db"
docker exec -t forgejo_db pg_dumpall --clean --if-exists --username=forgejo | gzip > /home/cy/forgejo_dump.sql.gz

echo "uploading to borg"
sudo -E $borg create --progress -sx --exclude-from borgback_exclude --exclude-caches $rsync:borg/crash::{hostname}-{now:%Y-%m-%dT%H:%M} \
                              /vw-data \
                              /home \
                              /opt \
                              /root \
                              /etc

sudo -E $borg prune --keep-within 2d --keep-daily 7 --keep-weekly 52 --keep-yearly 10 --stats $rsync:borg/crash

echo "uploading imich to borg"
export BORG_PASSPHRASE=$(pass borg/immich)
sudo -E $borg create --noxattrs --noacls --progress -sx $rsync:borg/immich::immich-{now:%Y-%m-%dT%H:%M} /mnt/photos/immich
sudo -E $borg prune --keep-within 2d --keep-daily 7 --keep-weekly 52 --keep-yearly 10 --stats $rsync:borg/immich
