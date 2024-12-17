#!/bin/bash

#resize filesystem to fill partition
/usr/bin/filesystem_resize.sh

# prevent randomized mac address for eth0
msg="First boot: Setting eth0 MAC address to derivative of CPU s/n."
echo "$msg"
logger "$msg"
cat <<EOF >> /etc/network/interfaces
# static mac address for onboard ethernet (castellated pins)
allow-hotplug eth0
iface eth0 inet dhcp
hwaddress ether $(awk '/Serial/ {print $3}' /proc/cpuinfo | tail -c 11 | sed 's/^\(.*\)/a2\1/' | sed 's/\(..\)/\1:/g;s/:$//')
EOF

# set meshtastic nodeid to derivative of CPU serial number (unique to this board). Check at boot in case of upgrade overwriting this.
seed=$(printf "%d\n" 0x$(awk '/Serial/ {print $3}' /proc/cpuinfo) | tail -c 9)
#seed=$((0x$(awk '/Serial/ {print $3}' /proc/cpuinfo) & 0x3B9AC9FF))
sed -i "/^ExecStart=/ s:$: -h $seed:" /usr/lib/systemd/system/meshtasticd.service
msg="First boot: Using Luckfox CPU S/N to generate nodeid for Meshtastic."
echo "$msg"
logger "$msg"
systemctl daemon-reload
systemctl enable meshtasticd
systemctl start meshtasticd

# enable wifi in meshtastic settings. Because this is very important, we'll try 10 times.
msg="First boot: Enabling wifi setting in Meshtasticd."
echo "$msg"
logger "$msg"
#/usr/local/bin/updatemeshtastic.sh "--set lora.region US" 10 "First boot"
/usr/local/bin/updatemeshtastic.sh "--set network.wifi_enabled true" 10 "First boot"

sudo sed -i '/^After=network-online.target/a After=rc-local.service' /usr/lib/systemd/system/meshtasticd.service
systemctl daemon-reload

rm /usr/local/bin/.firstboot
msg="First boot: Removing first boot flag and rebooting..."
echo "$msg"
logger "$msg"
reboot