#!/bin/sh
echo "Content-type: text/plain"
echo ""
sudo apt install --only-upgrade meshtasticd && sudo systemctl restart meshtasticd
