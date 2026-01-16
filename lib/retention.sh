apply_retention() {
  NOW=$(date +%s)

  for FILE in "$MOUNTPOINT/$HOSTNAME"/[AM]-20*-*-*.zip; do
    [ -f "$FILE" ] || continue
    DATE="${FILE##*/}"
    DATE="${DATE#*-}"
    DATE="${DATE%%_*}"

    date -d "$DATE" >/dev/null 2>&1 || continue
    AGE=$(( (NOW - $(date -d "$DATE" +%s)) / 86400 ))

    [ "$AGE" -gt "$RETENTION_DAYS" ] && rm -f "$FILE"
  done
}
