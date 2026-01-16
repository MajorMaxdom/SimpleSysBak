if [ ! -f "$CRED_FILE" ]; then
  read -rp "SMB Benutzer: " SMB_USER
  read -rsp "SMB Passwort: " SMB_PASS
  echo
  read -rp "SMB Domain (optional): " SMB_DOMAIN

  {
    echo "username=$SMB_USER"
    echo "password=$SMB_PASS"
    [ -n "$SMB_DOMAIN" ] && echo "domain=$SMB_DOMAIN"
  } > "$CRED_FILE"

  chmod 600 "$CRED_FILE"
fi
