#!/bin/bash

# Get the current MAC address for eth0
current_mac=$(cat /sys/class/net/eth0/address)

# Define the configuration to append
config="
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

# Append the configuration to /etc/network/interfaces
echo "$config" | sudo tee -a /etc/network/interfaces

# Output the current MAC address
echo "Appended configuration with current MAC address: $current_mac"
