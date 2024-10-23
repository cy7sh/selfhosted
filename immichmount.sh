#!/usr/bin/env bash

export PASSWORD_STORE_DIR=~/lab/vault/password-store
export RCLONE_CONFIG_PASS=$(pass show rclone/crashtan)

sudo -E rclone mount --config /home/crash/.config/rclone/rclone.conf --daemon --vfs-cache-mode full photos: /mnt/photos
