#!/bin/bash

# run USB automount and config tool
/usr/local/bin/usbconfig.sh

# enable wifi in meshtastic settings. Because this is very important, we'll try 10 times.
#msg="First boot: Enabling wifi setting in Meshtasticd."
#echo "$msg"
#logger "$msg"
#/usr/local/bin/updatemeshtastic.sh "--set lora.region US" 10 "First boot"
#/usr/local/bin/updatemeshtastic.sh "--set network.wifi_enabled true" 10 "First boot"