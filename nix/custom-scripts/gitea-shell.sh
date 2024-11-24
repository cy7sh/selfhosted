#!/bin/sh
/usr/bin/docker exec -i --env SSH_ORIGINAL_COMMAND="$SSH_ORIGINAL_COMMAND" forgejo sh "$@"
