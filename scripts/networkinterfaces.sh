#!/bin/bash

# Generate a random unicast MAC address
random_mac=$(printf '%02X:%02X:%02X:%02X:%02X:%02X\n' \
    $(( (RANDOM % 256) & 0xFE )) $(( RANDOM % 256 )) $(( RANDOM % 256 )) \
    $(( RANDOM % 256 )) $(( RANDOM % 256 )) $(( RANDOM % 256 )))

# Define the configuration to append
config="
auto lo
iface lo inet loopback

# static mac address for onboard ethernet (castellated pins)
allow-hotplug eth0
iface eth0 inet dhcp
hwaddress ether $random_mac

allow-hotplug wlan0
iface wlan0 inet dhcp
    wpa-conf /etc/wpa_supplicant/wpa_supplicant.conf
"

# Append the configuration to /etc/network/interfaces
echo "$config" >> /etc/network/interfaces

# Output the generated MAC address
echo "Appended configuration with generated MAC address: $random_mac"
