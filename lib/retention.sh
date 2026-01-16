apply_retention() {
  local CONFIG_FILE="$1"

  local MOUNTPOINT
  local RETENTION_DAYS
  local HOSTNAME
  local NOW

  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
  RETENTION_DAYS="$(jq -r '.retention_days' "$CONFIG_FILE")"
  HOSTNAME="$(hostname -s)"

  NOW="$(date +%s)"

  for FILE in "$MOUNTPOINT/$HOSTNAME"/[AM]-20*-*-*.zip; do
    [ -f "$FILE" ] || continue

    local BASENAME
    local DATE_PART
    local FILE_EPOCH
    local AGE_DAYS

    BASENAME="$(basename "$FILE")"
    DATE_PART="${BASENAME#*-}"
    DATE_PART="${DATE_PART%%_*}"

    date -d "$DATE_PART" >/dev/null 2>&1 || continue

    FILE_EPOCH="$(date -d "$DATE_PART" +%s)"
    AGE_DAYS="$(( (NOW - FILE_EPOCH) / 86400 ))"

    if [ "$AGE_DAYS" -gt "$RETENTION_DAYS" ]; then
      rm -f "$FILE"
    fi
  done
}
