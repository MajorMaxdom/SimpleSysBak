#!/bin/bash
set -e

echo "=== simplesysbak Installation ==="

BASE_DIR="/usr/local/simplesysbak"
LIB_DIR="$BASE_DIR/lib"
CONFIG_FILE="$BASE_DIR/simplesysbak_config.json"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Installiere simplesysbak nach $BASE_DIR"

mkdir -p "$LIB_DIR"

# sysbak kopieren
cp "$SCRIPT_DIR/sysbak.sh" "$BASE_DIR/sysbak.sh"
chmod +x "$BASE_DIR/sysbak.sh"

# lib-Skripte kopieren
cp "$SCRIPT_DIR/lib/"*.sh "$LIB_DIR/"
chmod +x "$LIB_DIR/"*.sh

# ---------------- Dependencies ----------------
REQUIRED_CMDS=(rsync zip mount.cifs jq)

if ! command -v rsync >/dev/null; then
  if command -v apt-get >/dev/null; then
    apt-get update
    apt-get install -y rsync zip cifs-utils jq
  elif command -v dnf >/dev/null; then
    dnf install -y rsync zip cifs-utils jq
  else
    echo "Kein unterstützter Paketmanager"
    exit 1
  fi
fi

# ---------------- Config ----------------------
if [ -f "$CONFIG_FILE" ]; then
  echo "Config existiert bereits: $CONFIG_FILE"
  exit 0
fi

read -rp "Mountpoint [/mnt]: " MOUNTPOINT
MOUNTPOINT="${MOUNTPOINT:-/mnt}"

read -rp "SMB Share (//host/share): " SHARE

read -rp "Credential-Datei [/usr/local/simplesysbak/.smbcred]: " CRED_FILE
CRED_FILE="${CRED_FILE:-/usr/local/simplesysbak/.smbcred}"

read -rp "Retention (Tage) [14]: " RETENTION_DAYS
RETENTION_DAYS="${RETENTION_DAYS:-14}"

echo "Backup-Pfade (leer beendet Eingabe)"
SOURCES=()
while read -rp "Pfad: " P && [ -n "$P" ]; do
  SOURCES+=("$P")
done

# ---------------- Credentials -----------------
if [ ! -f "$CRED_FILE" ]; then
  echo "SMB Credentials anlegen"

  read -rp "SMB Benutzername: " SMB_USER
  read -rsp "SMB Passwort: " SMB_PASS
  echo
  read -rp "SMB Domain (optional): " SMB_DOMAIN

  {
    echo "username=$SMB_USER"
    echo "password=$SMB_PASS"
    [ -n "$SMB_DOMAIN" ] && echo "domain=$SMB_DOMAIN"
  } > "$CRED_FILE"

  chmod 600 "$CRED_FILE"
  echo "Credential-Datei erstellt: $CRED_FILE"
fi

# ---------------- Write Config ----------------
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
