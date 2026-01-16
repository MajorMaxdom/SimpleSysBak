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

echo "Creating /usr/local/simplesysbak directory"
mkdir -p /usr/local/simplesysbak/lib

echo "Copying all files"
cp ssb_run.sh /usr/local/simplesysbak/
cp lib/*.sh /usr/local/simplesysbak/lib/

echo "Making ssb_run.sh executable"
chmod +x /usr/local/simplesysbak/ssb_run.sh

echo "All Done. Have fun backing up!"