#!/bin/bash

# Set the mount point
MOUNT_POINT="/mnt/usb"

# Function to log both to the screen and syslog
log_message() {
  local msg="USB config: $1"
  echo "$msg"  # Echo to the screen
  logger "USB config: $msg"  # Log to the system log
}

#Blink
blink() {
    echo 1 > /sys/class/gpio/gpio34/value;
    sleep "$1";
    echo 0 > /sys/class/gpio/gpio34/value;
}

escape_sed() {
    echo "$1" | sed -e 's/[]\/$*.^[]/\\&/g'
}

# Check if the mount point exists and if a USB drive is plugged in
USB_DEVICE=$(lsblk -o NAME,FSTYPE,SIZE,TYPE,MOUNTPOINT | grep -E "vfat|ext4|ntfs|exfat" | grep -E "sd[a-z][0-9]" | awk '{print $1}' | sed 's/[^a-zA-Z0-9]//g' | head -n 1)

if [ -d "$MOUNT_POINT" ]; then
  sudo rmdir "$MOUNT_POINT"
  log_message "/mnt/usb deleted."
fi

# If no USB device is found, exit
if [ -z "$USB_DEVICE" ]; then
  log_message "No USB drive found."
  exit 0
fi

# Create the mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
  sudo mkdir -p "$MOUNT_POINT"
fi

# Construct the full device path
USB_DEVICE="/dev/$USB_DEVICE"


# Debugging: Log and echo the extracted device name
log_message "Extracted device name: $USB_DEVICE"

# Check if the USB drive is already mounted
if mount | grep "$USB_DEVICE" > /dev/null; then
  log_message "USB drive is already mounted."
else
  # Mount the USB drive to the specified mount point
  sudo mount "$USB_DEVICE" "$MOUNT_POINT"
  if [ $? -eq 0 ]; then
    log_message "USB drive mounted successfully at $MOUNT_POINT."
  else
    log_message "Failed to mount USB drive."
    blink "4" && sleep "0.5"
    exit 1
  fi
fi

  WPA_SUPPLICANT_CONF="/etc/wpa_supplicant/wpa_supplicant.conf"
  USB_CONFIG="/tmp/femtofox-config.txt"

# Check if the mounted USB drive contains a file femtofox-config.txt
if [ -f "$MOUNT_POINT/femtofox-config.txt" ]; then
  log_message "femtofox-config.txt found on USB drive."

  # Remove Windows-style carriage returns
	tr -d '\r' < "$MOUNT_POINT/femtofox-config.txt" > $USB_CONFIG

  # Initialize variables
  SSID=""
  PSK=""
  COUNTRY=""
  RADIO=""
  FOUNDCONFIG="false"
  WIFI="false"

  # Read the fields from the USB config file if they exist
  if grep -qi 'ssid=' "$USB_CONFIG"; then
      SSID=$(grep 'ssid=' "$USB_CONFIG" | sed 's/ssid=//' | tr -d '"')
  fi
  if grep -qi 'psk=' "$USB_CONFIG"; then
      PSK=$(grep 'psk=' "$USB_CONFIG" | sed 's/psk=//' | tr -d '"')
  fi
  if grep -qi 'country=' "$USB_CONFIG"; then
      COUNTRY=$(grep 'country=' "$USB_CONFIG" | sed 's/country=//' | tr -d '"')
  fi
  if grep -qi 'radio=' "$USB_CONFIG"; then
      RADIO=$(grep 'radio=' "$USB_CONFIG" | sed 's/radio=//' | tr -d '"')
  fi


  # Escape special characters for sed
  ESCAPED_SSID=$(escape_sed "$SSID")
  ESCAPED_PSK=$(escape_sed "$PSK")
  ESCAPED_COUNTRY=$(escape_sed "$COUNTRY")
  ESCAPED_RADIO=$(escape_sed "$RADIO")

  # Update wpa_supplicant.conf with the new values if they exist
  if [[ -n "$COUNTRY" ]]; then
      sed -i "s/^\(country=\).*/\1$ESCAPED_COUNTRY/" "$WPA_SUPPLICANT_CONF"
      log_message "Updated country in wpa_supplicant.conf from femtofox-config.txt to $COUNTRY."
      FOUNDCONFIG="true"
      WIFI="true"
  fi
  if [[ -n "$SSID" ]]; then
      sed -i "/ssid=/s/\".*\"/\"$ESCAPED_SSID\"/" "$WPA_SUPPLICANT_CONF"
      log_message "Updated SSID in wpa_supplicant.conf from femtofox-config.txt to $SSID."
      FOUNDCONFIG="true"
      WIFI="true"
  fi
  if [[ -n "$PSK" ]]; then
      sed -i "/psk=/s/\".*\"/\"$ESCAPED_PSK\"/" "$WPA_SUPPLICANT_CONF"
      log_message "Updated PSK in wpa_supplicant.conf from femtofox-config.txt."
      FOUNDCONFIG="true"
      WIFI="true"
  fi

  if [[ -n "$RADIO" ]]; then
    rm -f /etc/meshtasticd/config.d/femtofox*
    FOUNDCONFIG="true"
    ESCAPED_RADIO=$(echo "$ESCAPED_RADIO" | tr '[:upper:]' '[:lower:]')
    case "$ESCAPED_RADIO" in
      'ebyte-e22-900m30s')
      cp /etc/meshtasticd/available.d/femtofox_EByte-E22-900M30S_Ebyte-E22-900M22S.yaml /etc/meshtasticd/config.d
        ;;
      'ebyte-e22-900m22s')
      cp /etc/meshtasticd/available.d/femtofox_EByte-E22-900M30S_Ebyte-E22-900M22S.yaml /etc/meshtasticd/config.d
        ;;
      'e22-900mm22s')
      cp /etc/meshtasticd/available.d/femtofox_EByte-E22-900MM22S.yaml /etc/meshtasticd/config.d
        ;;
      'heltec-ht-ra62')
      cp /etc/meshtasticd/available.d/femtofox_Heltec-HT-RA62_Seeed-WIO-SX1262.yaml /etc/meshtasticd/config.d
        ;;
      'seeed-wio-sx1262')
      cp /etc/meshtasticd/available.d/femtofox_Heltec-HT-RA62_Seeed-WIO-SX1262.yaml /etc/meshtasticd/config.d
        ;;
      'waveshare-sx126x-xxxm')
      cp /etc/meshtasticd/available.d/femtofox_Waveshare-SX126X-XXXM_AI-Thinker-RA-01SH.yaml /etc/meshtasticd/config.d
        ;;
      'ai-thinker-ra-01sh')
      cp /etc/meshtasticd/available.d/femtofox_Waveshare-SX126X-XXXM_AI-Thinker-RA-01SH.yaml /etc/meshtasticd/config.d
        ;;
      *)
        log_message 'Invalid radio name: $ESCAPED_RADIO'
        FOUNDCONFIG="false"
        ;;
    esac
    if [ "$FOUNDCONFIG" = "true" ]; then
      systemctl restart meshtasticd
      log_message "Set radio to $ESCAPED_RADIO, restarting Meshtasticd and proceeding with boot."
    fi
  fi


  if [ "$FOUNDCONFIG" = true ]; then
    for _ in {1..10}; do
      blink "0.125" && sleep 0.125
    done
    if [ "$WIFI" = true ]; then
      sudo systemctl restart wpa_supplicant
      sudo wpa_cli -i wlan0 reconfigure
      log_message "wpa_supplicant.conf updated and wifi restarted, proceeding with boot."
    fi
  else
    log_message "femtofox-config.txt does not contain valid configuration info, ignoring."
    for _ in {1..5}; do
      blink "1.5" && sleep 0.5
    done
  fi

  rm $USB_CONFIG

else
  log_message "USB drive mounted but femtofox-config.txt not found, ignoring."
  for _ in {1..3}; do
    blink "1.5" && sleep 0.5
  done
fi
