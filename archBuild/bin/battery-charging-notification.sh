#!/bin/bash

# Minimum battery level
THRESHOLD=20
BATTERY_PATH="/sys/class/power_supply/BAT0"
SOUND="$HOME/Music/alert-sound.mp3"
LOG_FILE="$HOME/battery-alert.log"

# Ensure a log file exists
touch "$LOG_FILE"

# Get the current user environment for notifications
export DISPLAY=:0
export DBUS_SESSION_BUS_ADDRESS=$(dbus-launch | grep 'DBUS_SESSION_BUS_ADDRESS' | sed 's/;.*//')

# Function to log messages
log_message() {
    echo "$(date): $1" >> "$LOG_FILE"
}

# Start monitoring battery
log_message "Battery monitor script started."

while true; do
    # Get the current battery level and status
    if [ -f "$BATTERY_PATH/capacity" ]; then
        BATTERY_LEVEL=$(cat "$BATTERY_PATH/capacity")
    else
        log_message "Error: Battery capacity file not found!"
        exit 1
    fi

    if [ -f "$BATTERY_PATH/status" ]; then
        STATUS=$(cat "$BATTERY_PATH/status")
    else
        log_message "Error: Battery status file not found!"
        exit 1
    fi

    # Check battery level and if it's discharging
    if [ "$BATTERY_LEVEL" -le "$THRESHOLD" ] && [ "$STATUS" == "Discharging" ]; then
        log_message "Low battery detected: ${BATTERY_LEVEL}% (Status: $STATUS)."

        # Get current volume and mute state
        CURRENT_VOLUME=$(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}' | sed 's/%//')
        IS_MUTED=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')

        # Unmute if muted
        if [ "$IS_MUTED" == "yes" ]; then
            pactl set-sink-mute @DEFAULT_SINK@ false
        fi

        # Set volume to 100%
        pactl set-sink-volume @DEFAULT_SINK@ 100%

        # Show notification
        if notify-send -u critical "Low Battery" "Battery level is at ${BATTERY_LEVEL}%!"; then
            log_message "Notification sent successfully."
        else
            log_message "Failed to send notification."
        fi

        # Play alert sound
        if paplay "$SOUND"; then
            log_message "Alert sound played successfully."
        else
            log_message "Failed to play alert sound: $SOUND."
        fi

        # Restore previous volume and mute state
        pactl set-sink-volume @DEFAULT_SINK@ "${CURRENT_VOLUME}%"
        if [ "$IS_MUTED" == "yes" ]; then
            pactl set-sink-mute @DEFAULT_SINK@ true
        fi
    fi

    # Sleep for 2 minutes before checking again
    sleep 120
done
