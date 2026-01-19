#!/bin/bash

run_backup() {
  local CONFIG_FILE="$1"
  local RUN_PREFIX="$2"

  local MOUNTPOINT
  local SOURCES
  local HOSTNAME
  local TS_LOG
  local TS_ARCHIVE
  local ARCHIVE
  local TMPDIR
  local STAGING
  local ARCHIVE_TMP
  local TARGET
  local LOGFILE
  local TOTAL_BYTES
  local TOTAL_HUMAN
  local ARCH_BYTES
  local ARCH_HUMAN
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
  ARCHIVE_TMP="$TMPDIR/$ARCHIVE"
  TARGET="$MOUNTPOINT/$HOSTNAME/$ARCHIVE"
  LOGFILE="$MOUNTPOINT/$HOSTNAME/backup.log"

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

  # ------------------ Originalgröße ------------------
  TOTAL_BYTES="$(du -sb "$STAGING" | awk '{print $1}')"
  TOTAL_HUMAN="$(du -sh "$STAGING" | awk '{print $1}')"
  TAR_OK=0

  # ------------------ Archiv erstellen ----------------
  if [ -t 1 ]; then
    if (
      cd "$STAGING" &&
      tar -cf - . 2> "$TMPDIR/tar.error" \
        | pv -N archive -s "$TOTAL_BYTES" \
        | gzip > "$ARCHIVE_TMP"
    ); then
      TAR_OK=1
    fi
  else
    if (
      cd "$STAGING" &&
      tar -czf "$ARCHIVE_TMP" . \
        2> "$TMPDIR/tar.error"
    ); then
      TAR_OK=1
    fi
  fi

  # ------------------ Fehler beim Tar -----------------
  if [ "$TAR_OK" -ne 1 ]; then
    ERROR_MSG="$(tr '\n' ' ' < "$TMPDIR/tar.error")"
    echo "[$TS_LOG] ERROR $ARCHIVE  SRC_SIZE=${TOTAL_HUMAN} (${TOTAL_BYTES} bytes)  tar failed: $ERROR_MSG" \
      >> "$LOGFILE"
    return 1
  fi

  # ------------------ Archivgröße ---------------------
  ARCH_BYTES="$(stat -c %s "$ARCHIVE_TMP")"
  ARCH_HUMAN="$(du -h "$ARCHIVE_TMP" | awk '{print $1}')"

  # ------------------ Transfer auf Share --------------
  if [ -t 1 ]; then
    pv -N transfer -s "$ARCH_BYTES" "$ARCHIVE_TMP" > "$TARGET"
    rm -f "$ARCHIVE_TMP"
  else
    mv "$ARCHIVE_TMP" "$TARGET"
  fi

  # ------------------ Logging -------------------------
  echo "[$TS_LOG] OK    $ARCHIVE  SRC_SIZE=${TOTAL_HUMAN} (${TOTAL_BYTES} bytes)  ARCHIVE_SIZE=${ARCH_HUMAN} (${ARCH_BYTES} bytes)" \
    >> "$LOGFILE"
}

cleanup_tmp() {
  [ -n "$SYSBAK_TMPDIR" ] && rm -rf "$SYSBAK_TMPDIR"
}
