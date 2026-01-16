#!/bin/bash
set -e

BASE_DIR="/usr/local/simplesysbak"
LIB_DIR="$BASE_DIR/lib"
CONFIG_FILE="$BASE_DIR/simplesysbak_config.json"

RUN_PREFIX="M-"
[ "$1" = "-automatic" ] && RUN_PREFIX="A-"

export CONFIG_FILE RUN_PREFIX

source "$LIB_DIR/deps.sh"
source "$LIB_DIR/config.sh"
source "$LIB_DIR/creds.sh"
source "$LIB_DIR/mount.sh"
source "$LIB_DIR/backup.sh"
source "$LIB_DIR/retention.sh"

cleanup() {
  unmount_share
  cleanup_tmp
}
trap cleanup EXIT

mount_share
run_backup
apply_retention
