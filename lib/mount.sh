mount_share() {
  local CONFIG_FILE="$1"

  local MOUNTPOINT
  local SHARE
  local CRED_FILE

  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
  SHARE="$(jq -r '.share' "$CONFIG_FILE")"
  CRED_FILE="$(jq -r '.credential_file' "$CONFIG_FILE")"

  mkdir -p "$MOUNTPOINT"

  if ! mountpoint -q "$MOUNTPOINT"; then
    mount -t cifs "$SHARE" "$MOUNTPOINT" \
      -o credentials="$CRED_FILE",vers=3.1.1,serverino
  fi
}

unmount_share() {
  local CONFIG_FILE="$1"

  local MOUNTPOINT
  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"

  if mountpoint -q "$MOUNTPOINT"; then
    umount "$MOUNTPOINT"
  fi
}
