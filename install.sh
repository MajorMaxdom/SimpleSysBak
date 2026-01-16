cat <<'EOF'
   _____ _                 __    _____            ____        __  
  / ___/(_)___ ___  ____  / /__ / ___/__  _______/ __ )____ _/ /__
  \__ \/ / __ `__ \/ __ \/ / _ \\__ \/ / / / ___/ __  / __ `/ //_/
 ___/ / / / / / / / /_/ / /  __/__/ / /_/ (__  ) /_/ / /_/ / ,<   
/____/_/_/ /_/ /_/ .___/_/\___/____/\__, /____/_____/\__,_/_/|_|  
                /_/                /____/                         
EOF

echo "Installing SimpleSysBak"

echo "Creating /usr/local/systembackup directory"
mkdir -p /usr/local/systembackup/lib

echo "Copying all files"
cp systembackup.sh /usr/local/systembackup/
cp lib/*.sh /usr/local/systembackup/lib/

echo "Making systembackup.sh executable"
chmod +x /usr/local/systembackup/systembackup.sh

echo "All Done. Have fun backing up!"