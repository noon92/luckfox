#!/bin/bash

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

# enable wifi in meshtastic settings. Because this is very important, we'll try 5 times.
msg="First boot: Enabling wifi setting in Meshtasticd."
echo "$msg"
logger "$msg"
for retries in $(seq 1 10); do
  output=$(meshtastic --host --set network.wifi_enabled true 2>&1)
  echo "$output"
  if echo "$output" | grep -qiE "Abort|invalid|Error"; then
    if [ "$retries" -lt 3 ]; then
      msg="First boot: Meshtastic update failed, retrying ($(($retries + 1))/10)..."
      echo "$msg"
      logger "$msg"
      sleep 2 # Add a small delay before retrying
    fi
  else
    break
  fi
done

rm /usr/local/bin/.firstboot
msg="First boot: Removing first boot flag and rebooting..."
echo "$msg"
logger "$msg"
reboot