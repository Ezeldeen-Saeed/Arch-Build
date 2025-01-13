#!/bin/bash

# Minimum battery level
THRESHOLD=20

# Battery status path (adjust if needed)
BATTERY_PATH="/sys/class/power_supply/BAT0"

# Notification sound file
SOUND="$HOME/Sounds/alert-sound.mp3"

while true; do
    # Get the current battery level
    BATTERY_LEVEL=$(cat "$BATTERY_PATH/capacity")
    # Check if the battery is discharging
    STATUS=$(cat "$BATTERY_PATH/status")

    if [ "$BATTERY_LEVEL" -lt "$THRESHOLD" ] && [ "$STATUS" == "Discharging" ]; then
        # Send a desktop notification
        notify-send -u critical "Low Battery" "Battery level is at ${BATTERY_LEVEL}%!"

        # Play a sound
        paplay "$SOUND"

        # Wait for 5 minutes before checking again
        sleep 300
    else
        # Check every 10 seconds
        sleep 10
    fi
done
