#!/bin/bash

# Get the current MAC address for eth0
current_mac=$(cat /sys/class/net/eth0/address)

# Define the configuration string to replace
config="# interfaces(5) file used by ifup(8) and ifdown(8)
# Include files from /etc/network/interfaces.d:
source /etc/network/interfaces.d/*

auto lo
iface lo inet loopback

# static mac address for onboard ethernet (castellated pins)
allow-hotplug eth0
iface eth0 inet dhcp
hwaddress ether $current_mac

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
"

# Replace the existing configuration for eth0 in /etc/network/interfaces
sudo sed -i "/iface eth0 inet/d" /etc/network/interfaces
echo "$config" | sudo tee /etc/network/interfaces > /dev/null

# Output the current MAC address
echo "Replaced /etc/network/interfaces with new MAC address ($current_mac) and wifi support\n"
