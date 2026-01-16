mount_share() {
  mkdir -p "$MOUNTPOINT"
  mountpoint -q "$MOUNTPOINT" || \
    mount -t cifs "$SHARE" "$MOUNTPOINT" \
      -o credentials="$CRED_FILE",vers=3.1.1,serverino
}

unmount_share() {
  mountpoint -q "$MOUNTPOINT" && umount "$MOUNTPOINT"
}
