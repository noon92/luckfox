#!/bin/bash

# Check if the RTC (Real-Time Clock) has a valid time
if [[ $(hwclock -r) ]]; then
  echo "Got time from RTC: $(hwclock -r)"  # Output the time obtained from the RTC
  time="$(hwclock -r)"  # Store the RTC time in the 'time' variable
  hwclock -s  # Set the system time from the RTC time
fi

# Check if we can get the time from a network source (e.g., google.com)
if [[ ! $(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g') ]]; then
  echo "Could not get time from network"  # If no time is obtained, print an error message
else
  # Get the time from the network and store it in the 'time' variable
  time="$(curl -s --head http://google.com | grep ^Date: | sed 's/Date: //g')"
  echo "Got time from network: ${time}"  # Output the time obtained from the network
  date -s "${time}"  # Set the system time from the network time
fi

# If no time is set yet, fall back to a default date
if [[ -z ${time} ]]; then
  echo "Could not get time from any source. Setting to Jan 1 2024."  # Inform the user of the fallback date
  date -s "1 JAN 2024 00:00:00"  # Set the system time to January 1st, 2024
fi

# Check if the RTC device exists
if [[ -z /dev/rtc* ]]; then
  echo "No RTC found"  # If no RTC device is found, print an error message
else
  echo "RTC found, setting time from system clock"  # If an RTC is found, set its time from the system clock
  hwclock -w  # Write the system time to the RTC
fi

exit 0  # Exit the script successfully
