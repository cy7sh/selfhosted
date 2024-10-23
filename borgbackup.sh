#!/usr/bin/env bash

export PASSWORD_STORE_DIR=$PWD/vault/password-store
export BORG_PASSPHRASE=$(pass show borg/crash)
export BORG_REMOTE_PATH=borg1

sudo -E borg create --progress -sx --exclude-from borgback_exclude --exclude-caches rsync:borg/crash::{hostname}-{now:%Y-%m-%dT%H:%M} \
                              /vw-data \
                              /home \
                              /opt \
                              /root \
                              /etc
