#!/bin/bash

logger "$(date): Listening for button press on $DEVICE..."

evtest --grab /dev/input/event0 | while read line; do
    if echo $line | grep -q "EV_KEY.*value 1"; then
        logger "Button pressed, triggering reboot..."
        sudo reboot
    fi
done
