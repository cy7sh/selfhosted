#!/usr/bin/env bash

export RCLONE_CONFIG_PASS=$(pass show rclone/crashtan)
config=/home/cy/.config/rclone/rclone.conf

sudo -E rclone mount --config $config --daemon --vfs-cache-mode writes photos: /mnt/photos
