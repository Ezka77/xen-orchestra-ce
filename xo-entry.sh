#!/bin/bash
set -e

exec su-exec ${USER} "$@"

