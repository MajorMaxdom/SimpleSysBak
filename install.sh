cat <<'EOF'
   _____            ____        __  
  / ___/__  _______/ __ )____ _/ /__
  \__ \/ / / / ___/ __  / __ `/ //_/
 ___/ / /_/ (__  ) /_/ / /_/ / ,<   
/____/\__, /____/_____/\__,_/_/|_|  
     /____/                         
EOF

mkdir -p /usr/local/systembackup/lib
cp systembackup.sh /usr/local/systembackup/
cp lib/*.sh /usr/local/systembackup/lib/
chmod +x /usr/local/systembackup/systembackup.sh
