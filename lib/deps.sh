REQUIRED_CMDS=(rsync zip mount.cifs umount jq)

install_packages() {
  if command -v apt-get >/dev/null; then
    apt-get update
    apt-get install -y rsync zip cifs-utils jq
  elif command -v dnf >/dev/null; then
    dnf install -y rsync zip cifs-utils jq
  elif command -v yum >/dev/null; then
    yum install -y rsync zip cifs-utils jq
  elif command -v pacman >/dev/null; then
    pacman -Sy --noconfirm rsync zip cifs-utils jq
  else
    echo "Kein unterstützter Paketmanager"
    exit 1
  fi
}

for CMD in "${REQUIRED_CMDS[@]}"; do
  command -v "$CMD" >/dev/null || install_packages
done
