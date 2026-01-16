run_backup() {
  local CONFIG_FILE="$1"
  local RUN_PREFIX="$2"

  local MOUNTPOINT
  local HOSTNAME
  local TS
  local ARCHIVE
  local TMPDIR
  local STAGING
  local TARGET
  local SOURCES

  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
  mapfile -t SOURCES < <(jq -r '.sources[]' "$CONFIG_FILE")
  HOSTNAME="$(hostname -s)"

  TS="$(date +%F_%H-%M-%S)"
  ARCHIVE="${RUN_PREFIX}${TS}.tar.gz"

  TMPDIR="$(mktemp -d /tmp/simplesysbak.XXXXXX)"
  STAGING="$TMPDIR/data"
  TARGET="$MOUNTPOINT/$HOSTNAME/$ARCHIVE"

  export SYSBAK_TMPDIR="$TMPDIR"

  mkdir -p "$STAGING" "$MOUNTPOINT/$HOSTNAME"

  # Daten sammeln
  for SRC in "${SOURCES[@]}"; do
    [ -d "$SRC" ] || continue

    REL="${SRC#/}"
    mkdir -p "$STAGING/$(dirname "$REL")"
    rsync -a "$SRC" "$STAGING/$(dirname "$REL")/"
  done

  # Config immer mitsichern
  REL_CFG="${CONFIG_FILE#/}"
  mkdir -p "$STAGING/$(dirname "$REL_CFG")"
  cp -a "$CONFIG_FILE" "$STAGING/$REL_CFG"

  # Archiv erstellen
  (
    cd "$STAGING"
    tar -czf "$TMPDIR/$ARCHIVE" .
  )

  mv "$TMPDIR/$ARCHIVE" "$TARGET"
}

cleanup_tmp() {
  [ -n "$SYSBAK_TMPDIR" ] && rm -rf "$SYSBAK_TMPDIR"
}
