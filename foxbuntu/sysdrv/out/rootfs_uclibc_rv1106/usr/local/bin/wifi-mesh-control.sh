#!/bin/bash

# Wait 60 seconds for networking to be available during boot
sleep 60

# Initial value for comparison (set to up by default)
previous_value="1"

# Ensure Wi-Fi interface is up by default on boot
ip link set wlan0 up

while true; do
    # Fetch the current value
    current_value=$(cat /root/.portduino/default/prefs/config.proto | protoc --decode_raw | awk '/4 {/, /}/ {if ($1 == "1:") print $2}')

    # Check if the value has changed
    if [ "$current_value" != "$previous_value" ]; then
        # Log the previous state
        case "$previous_value" in
            1) prev_text="Wifi on" ;;
            2) prev_text="Startup" ;;
            *) prev_text="Wifi off" ;;
        esac

        # Log the current state
        if [ "$current_value" -eq 1 ]; then
            cur_text="Wifi on"
        else
            cur_text="Wifi off"
        fi

        # Log the change
        logger "Wifi mesh control: wifi setting changed: $prev_text -> $cur_text"

        # Update the previous value for next comparison
        previous_value="$current_value"
    fi

    # Take action based on the current value
    if [ "$current_value" == "1" ]; then
        ip link set wlan0 up
    elif [ "$current_value" == "0" ]; then
        ip link set wlan0 down
    fi

    # Wait for 30 seconds before checking again
    sleep 30
done
