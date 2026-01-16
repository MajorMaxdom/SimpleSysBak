#!/bin/bash
set -e

BASE_DIR="/usr/local/simplesysbak"
LIB_DIR="$BASE_DIR/lib"
CONFIG_FILE="$BASE_DIR/simplesysbak_config.json"

RUN_PREFIX="M-"
[ "$1" = "-automatic" ] && RUN_PREFIX="A-"

# Config MUSS existieren
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Config fehlt: $CONFIG_FILE"
  echo "Bitte zuerst das Install-Skript ausführen."
  exit 1
fi

# Module laden
source "$LIB_DIR/mount.sh"
source "$LIB_DIR/backup.sh"
source "$LIB_DIR/retention.sh"

cleanup() {
  unmount_share "$CONFIG_FILE"
  cleanup_tmp
}
trap cleanup EXIT

# Ablauf
mount_share "$CONFIG_FILE"
run_backup "$CONFIG_FILE" "$RUN_PREFIX"
apply_retention "$CONFIG_FILE"
