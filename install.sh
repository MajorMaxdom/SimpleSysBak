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

echo "Installing SimpleSysBak"

echo "Creating /usr/local/systembackup directory"
mkdir -p /usr/local/systembackup/lib

echo "Copying all files"
cp systembackup.sh /usr/local/systembackup/
cp lib/*.sh /usr/local/systembackup/lib/

echo "Making systembackup.sh executable"
chmod +x /usr/local/systembackup/systembackup.sh

echo "All Done. Have fun backing up!"