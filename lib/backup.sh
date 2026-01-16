TS="$(date +%F_%H-%M-%S)"
ARCHIVE="${RUN_PREFIX}${TS}.zip"

TMPDIR="$(mktemp -d /tmp/systembackup.XXXXXX)"
STAGING="$TMPDIR/data"
TARGET="$MOUNTPOINT/$HOSTNAME/$ARCHIVE"

cleanup_tmp() {
  rm -rf "$TMPDIR"
}

run_backup() {
  mkdir -p "$STAGING" "$MOUNTPOINT/$HOSTNAME"

  for SRC in "${SOURCES[@]}"; do
    [ -d "$SRC" ] || continue
    REL="${SRC#/}"
    mkdir -p "$STAGING/$(dirname "$REL")"
    rsync -a "$SRC" "$STAGING/$(dirname "$REL")/"
  done

  # systembackup.json immer mitsichern
  REL_CFG="${CONFIG_FILE#/}"
  mkdir -p "$STAGING/$(dirname "$REL_CFG")"
  cp -a "$CONFIG_FILE" "$STAGING/$REL_CFG"

  ( cd "$STAGING" && zip -r "$TMPDIR/$ARCHIVE" . )
  mv "$TMPDIR/$ARCHIVE" "$TARGET"
}
