#!/bin/bash
set -e

clear
cat <<'EOF'
  ░██████   ░██                           ░██              ░██████                         ░████████              ░██       
 ░██   ░██                                ░██             ░██   ░██                        ░██    ░██             ░██       
░██         ░██░█████████████  ░████████  ░██  ░███████  ░██         ░██    ░██  ░███████  ░██    ░██   ░██████   ░██    ░██
 ░████████  ░██░██   ░██   ░██ ░██    ░██ ░██ ░██    ░██  ░████████  ░██    ░██ ░██        ░████████         ░██  ░██   ░██ 
        ░██ ░██░██   ░██   ░██ ░██    ░██ ░██ ░█████████         ░██ ░██    ░██  ░███████  ░██     ░██  ░███████  ░███████  
 ░██   ░██  ░██░██   ░██   ░██ ░███   ░██ ░██ ░██         ░██   ░██  ░██   ░███        ░██ ░██     ░██ ░██   ░██  ░██   ░██ 
  ░██████   ░██░██   ░██   ░██ ░██░█████  ░██  ░███████    ░██████    ░█████░██  ░███████  ░█████████   ░█████░██ ░██    ░██
                               ░██                                          ░██                                             
                               ░██                                    ░███████                                              
EOF

BASE_DIR="/usr/local/systembackup"
LIB_DIR="$BASE_DIR/lib"
CONFIG_FILE="$BASE_DIR/systembackup.json"

mkdir -p "$LIB_DIR"

echo "=== sysbak Installation ==="

# ---------------- Dependencies ----------------
source "$LIB_DIR/deps.sh" 2>/dev/null || true

REQUIRED_CMDS=(rsync zip mount.cifs jq)

for CMD in "${REQUIRED_CMDS[@]}"; do
  if ! command -v "$CMD" >/dev/null; then
    echo "Installiere Abhängigkeiten..."
    if command -v apt-get >/dev/null; then
      apt-get update
      apt-get install -y rsync zip cifs-utils jq
    elif command -v dnf >/dev/null; then
      dnf install -y rsync zip cifs-utils jq
    else
      echo "Kein unterstützter Paketmanager"
      exit 1
    fi
    break
  fi
done

# ---------------- Config ----------------------
if [ -f "$CONFIG_FILE" ]; then
  echo "Config existiert bereits: $CONFIG_FILE"
  exit 0
fi

read -rp "Mountpoint [/mnt]: " MOUNTPOINT
MOUNTPOINT="${MOUNTPOINT:-/mnt}"

read -rp "SMB Share (//host/share): " SHARE

read -rp "Credential-Datei [/root/.smbcred]: " CRED_FILE
CRED_FILE="${CRED_FILE:-/root/.smbcred}"

read -rp "Retention (Tage) [14]: " RETENTION_DAYS
RETENTION_DAYS="${RETENTION_DAYS:-14}"

echo "Backup-Pfade (leer beendet Eingabe)"
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
  '{
    mountpoint: $mount,
    share: $share,
    credential_file: $cred,
    retention_days: $retention,
    sources: $sources
  }' > "$CONFIG_FILE"

chmod 600 "$CONFIG_FILE"

echo "Installation abgeschlossen."
echo "Starte Backups mit: sysbak oder sysbak -automatic"
