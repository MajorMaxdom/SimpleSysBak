if [ ! -f "$CONFIG_FILE" ]; then
  echo "Ersteinrichtung systembackup.json"

  read -rp "Mountpoint [/mnt]: " MOUNTPOINT
  MOUNTPOINT="${MOUNTPOINT:-/mnt}"

  read -rp "SMB Share: " SHARE
  read -rp "Credential-Datei [/usr/local/simplesysbak/.smbcreds]: " CRED_FILE
  CRED_FILE="${CRED_FILE:-/usr/local/simplesysbak/.smbcreds}"

  read -rp "Retention (Tage) [14]: " RETENTION_DAYS
  RETENTION_DAYS="${RETENTION_DAYS:-14}"

  echo "Backup-Pfade (leer beendet):"
  SOURCES=()
  while read -rp "Pfad: " P && [ -n "$P" ]; do
    SOURCES+=("$P")
  done

  jq -n \
    --arg mount "$MOUNTPOINT" \
    --arg share "$SHARE" \
    --arg cred "$CRED_FILE" \
    --argjson retention "$RETENTION_DAYS" \
    --argjson sources "$(printf '%s\n' "${SOURCES[@]}" | jq -R . | jq -s .)" \
    '{mountpoint:$mount,share:$share,credential_file:$cred,retention_days:$retention,sources:$sources}' \
    > "$CONFIG_FILE"

  chmod 600 "$CONFIG_FILE"
fi

MOUNTPOINT="$(jq -r '.mountpoint' "$CONFIG_FILE")"
SHARE="$(jq -r '.share' "$CONFIG_FILE")"
CRED_FILE="$(jq -r '.credential_file' "$CONFIG_FILE")"
RETENTION_DAYS="$(jq -r '.retention_days' "$CONFIG_FILE")"
mapfile -t SOURCES < <(jq -r '.sources[]' "$CONFIG_FILE")
HOSTNAME="$(hostname -s)"
