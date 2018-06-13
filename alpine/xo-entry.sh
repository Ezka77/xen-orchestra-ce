#!/bin/bash
set -e

# Start rpcbind (used for NFS mount)
rpcbind

exec su-exec ${USER} "$@"
