#!/usr/bin/env bash

# export RCLONE_CONFIG_PASS=$(pass show rclone/crashtan)
config=/home/yt/.config/rclone/rclone.conf

sudo -E rclone mount --config $config --daemon --dir-cache-time 720h --poll-interval 0 --vfs-cache-mode writes photos: /mnt/photos
