#!/bin/bash
set -e

# fix perms
chown -R app:app /storage

# start App
cd /app/xo-server
exec "$@"

