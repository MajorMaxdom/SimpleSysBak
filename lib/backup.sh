run_backup() {
  local CONFIG_FILE="$1"
  local RUN_PREFIX="$2"

  local MOUNTPOINT
  local HOSTNAME
  local SOURCES
  local TS
  local ARCHIVE
  local TMPDIR
  local STAGING
  local TARGET

  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
  mapfile -t SOURCES < <(jq -r '.sources[]' "$CONFIG_FILE")
  HOSTNAME="$(hostname -s)"

  TS="$(date +%F_%H-%M-%S)"
  ARCHIVE="${RUN_PREFIX}${TS}.zip"

  TMPDIR="$(mktemp -d /tmp/systembackup.XXXXXX)"
  STAGING="$TMPDIR/data"
  TARGET="$MOUNTPOINT/$HOSTNAME/$ARCHIVE"

  # TMPDIR für cleanup merken
  export SYSBAK_TMPDIR="$TMPDIR"

  mkdir -p "$STAGING" "$MOUNTPOINT/$HOSTNAME"

  for SRC in "${SOURCES[@]}"; do
    [ -d "$SRC" ] || continue

    REL="${SRC#/}"
    mkdir -p "$STAGING/$(dirname "$REL")"
    rsync -a "$SRC" "$STAGING/$(dirname "$REL")/"
  done

  # systembackup.json immer mitsichern
  local REL_CFG="${CONFIG_FILE#/}"
  mkdir -p "$STAGING/$(dirname "$REL_CFG")"
  cp -a "$CONFIG_FILE" "$STAGING/$REL_CFG"

  (
    cd "$STAGING"
    zip -r "$TMPDIR/$ARCHIVE" .
  )

  mv "$TMPDIR/$ARCHIVE" "$TARGET"
}

cleanup_tmp() {
  [ -n "$SYSBAK_TMPDIR" ] && rm -rf "$SYSBAK_TMPDIR"
}
