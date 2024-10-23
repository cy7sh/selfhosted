#!/usr/bin/env bash

export PASSWORD_STORE_DIR=$PWD/vault/password-store
export AWS_ACCESS_KEY_ID=$(pass show b2/s3_crashtan | sed '1q;d')
export AWS_SECRET_ACCESS_KEY=$(pass show b2/s3_crashtan | sed '2q;d')
export RESTIC_REPOSITORY=s3:s3.us-east-005.backblazeb2.com/crashtan/lab
export RESTIC_PASSWORD_COMMAND="su -c 'pass show b2/crashtan' crashtan"

sudo -E restic --verbose backup --files-from ./resticback_include --exclude-file ./resticback_exclude --exclude-caches
