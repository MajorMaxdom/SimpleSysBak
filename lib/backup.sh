#!/bin/bash

run_backup() {
  local CONFIG_FILE="$1"
  local RUN_PREFIX="$2"

  local MOUNTPOINT
  local HOSTNAME
  local SOURCES
  local TS_LOG
  local TS_ARCHIVE
  local ARCHIVE
  local TMPDIR
  local STAGING
  local TARGET
  local LOGFILE
  local TOTAL_FILES
  local PROCESSED
  local TAR_OK

  # ------------------ Config laden ------------------
  MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
  mapfile -t SOURCES < <(jq -r '.sources[]' "$CONFIG_FILE")
  HOSTNAME="$(hostname -s)"

  TS_LOG="$(date '+%F %T')"
  TS_ARCHIVE="$(date '+%F_%H-%M-%S')"
  ARCHIVE="${RUN_PREFIX}${TS_ARCHIVE}.tar.gz"

  TMPDIR="$(mktemp -d /tmp/simplesysbak.XXXXXX)"
  STAGING="$TMPDIR/data"
  TARGET="$MOUNTPOINT/$HOSTNAME/$ARCHIVE"
  LOGFILE="$MOUNTPOINT/$HOSTNAME/backup.log"

  # TMPDIR für Cleanup exportieren
  export SYSBAK_TMPDIR="$TMPDIR"

  mkdir -p "$STAGING" "$MOUNTPOINT/$HOSTNAME"

  # ------------------ Daten sammeln ------------------
  for SRC in "${SOURCES[@]}"; do
    [ -d "$SRC" ] || continue

    REL="${SRC#/}"
    mkdir -p "$STAGING/$(dirname "$REL")"
    rsync -a "$SRC" "$STAGING/$(dirname "$REL")/"
  done

  # ------------------ Config immer mitsichern --------
  REL_CFG="${CONFIG_FILE#/}"
  mkdir -p "$STAGING/$(dirname "$REL_CFG")"
  cp -a "$CONFIG_FILE" "$STAGING/$REL_CFG"

  # ------------------ Fortschritt vorbereiten --------
  TOTAL_FILES="$(find "$STAGING" -type f | wc -l)"
  PROCESSED=0
  TAR_OK=0

  # ------------------ Archiv erstellen ----------------
  if [ -t 1 ]; then
    # -------- Interaktiv: mit Fortschritt --------
    if (
      cd "$STAGING" &&
      tar \
        --checkpoint=1 \
        --checkpoint-action=exec='
          PROCESSED=$((PROCESSED+1))
          printf "\r[PROGRESS] %d / %d Dateien verarbeitet" "$PROCESSED" "'"$TOTAL_FILES"'"
        ' \
        -czf "$TMPDIR/$ARCHIVE" . \
        2> "$TMPDIR/tar.error"
    ); then
      echo
      TAR_OK=1
    fi
  else
    # -------- Nicht interaktiv: ohne Fortschritt -----
    if (
      cd "$STAGING" &&
      tar -czf "$TMPDIR/$ARCHIVE" . \
        2> "$TMPDIR/tar.error"
    ); then
      TAR_OK=1
    fi
  fi

  # ------------------ Ergebnis auswerten --------------
  if [ "$TAR_OK" -eq 1 ]; then
    mv "$TMPDIR/$ARCHIVE" "$TARGET"

    SIZE_BYTES="$(stat -c %s "$TARGET")"
    SIZE_HUMAN="$(du -h "$TARGET" | awk '{print $1}')"

    echo "[$TS_LOG] OK    $ARCHIVE  ${SIZE_HUMAN} (${SIZE_BYTES} bytes)" \
      >> "$LOGFILE"
  else
    ERROR_MSG="$(tr '\n' ' ' < "$TMPDIR/tar.error")"

    echo "[$TS_LOG] ERROR $ARCHIVE  tar failed: $ERROR_MSG" \
      >> "$LOGFILE"

    return 1
  fi
}

cleanup_tmp() {
  [ -n "$SYSBAK_TMPDIR" ] && rm -rf "$SYSBAK_TMPDIR"
}
