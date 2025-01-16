#!/bin/bash

# Minimum battery level
THRESHOLD=20
BATTERY_PATH="/sys/class/power_supply/BAT0"
SOUND="$HOME/Sounds/alert-sound.mp3"

while true; do
    # Get the current battery level
    BATTERY_LEVEL=$(cat "$BATTERY_PATH/capacity")
    # Check if the battery is discharging
    STATUS=$(cat "$BATTERY_PATH/status")

    if [ "$BATTERY_LEVEL" -le "$THRESHOLD" ] && [ "$STATUS" == "Discharging" ]; then
        # Get the current volume level and mute status
        CURRENT_VOLUME=$(amixer get Master | grep -oP '[0-9]+(?=%)' | head -1)
        IS_MUTED=$(amixer get Master | grep -oP '\[(on|off)\]' | head -1)

        # Unmute if muted
        if [ "$IS_MUTED" == "[off]" ]; then
            amixer sset Master unmute > /dev/null
        fi

        # Set volume to 100%
        amixer sset Master 100% > /dev/null

        # Show notification and play sound

        for DISPLAY in $(xrandr --listmonitors | awk '{print $2}' | sed 's/[^a-zA-Z0-9]//g'); do
            export DISPLAY=$DISPLAY
            notify-send -u critical "Low Battery" "Battery level is at ${BATTERY_LEVEL}%!"
        done
        
        paplay "$SOUND"

        # Restore the previous volume and mute state
        amixer sset Master "${CURRENT_VOLUME}%" > /dev/null
        if [ "$IS_MUTED" == "[off]" ]; then
            amixer sset Master mute > /dev/null
        fi

    fi

    # Sleep for 2 minutes before checking again
    sleep 120
done
