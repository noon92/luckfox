#!/bin/bash

# Initial value for comparison (start with an empty value)
previous_value=""

while true; do
    # Run the command to fetch the value
    current_value=$(sudo cat /root/.portduino/default/prefs/config.proto | protoc --decode_raw | awk '/4 {/, /}/ {if ($1 == "1:") print $2}')
    
    # Check if the value has changed
    if [ "$current_value" != "$previous_value" ]; then
        # Display the change
        echo "Value changed: $previous_value -> $current_value"
        
        # Update the previous value for next comparison
        previous_value="$current_value"
        
        # Take action based on the new value
        if [ "$current_value" == "1" ]; then
            echo "Bringing wlan0 up"
            sudo ip link set wlan0 up
        else
            echo "Bringing wlan0 down"
            sudo ip link set wlan0 down
        fi
    fi
    
    # Wait for 10 seconds before checking again
    sleep 10
done