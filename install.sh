#!/usr/bin/env bash

set -a
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
set +a
echo "STARTING INSTALLATION"

(bash $SCRIPT_DIR/scripts/0-preinstall.sh) |& tee 0-preinstall.log
