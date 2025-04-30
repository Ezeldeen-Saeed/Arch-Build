#!/bin/bash

# Config
SCRIPT_PATH="$HOME/.local/bin/battery-alert.sh"
LOOP_PATH="$HOME/.local/bin/battery-alert-loop.sh"
SERVICE_DIR="$HOME/.config/systemd/user"
SERVICE_FILE="$SERVICE_DIR/battery-alert.service"
SOUND_FILE="$HOME/Music/Sounds/fails.mp3"  # Your custom sound

# Create script directory if needed
mkdir -p "$(dirname "$SCRIPT_PATH")"
mkdir -p "$SERVICE_DIR"

# Define the volume adjustment and sound playback function
adjust_volume_and_play() {
    local sound_file="$1"
    
    # List all sinks and filter out the running ones
    local sinks
    sinks=$(pactl list short sinks | grep RUNNING | awk '{print $1}')
    
    # If no running sink, exit
    [ -z "$sinks" ] && return

    # Loop through all running sinks
    for sink in $sinks; do
        # Get current mute and volume state of the sink
        local current_mute
        current_mute=$(pactl get-sink-mute "$sink" | awk '{print $2}')
        local current_volume
        current_volume=$(pactl get-sink-volume "$sink" | grep -oP '\d+%' | head -1)

        # If the sink is muted or volume is below 50%, unmute and set to 100% before playing the sound
        if [ "$current_mute" = "yes" ] || [ "${current_volume%\%}" -lt 50 ]; then
            # Save the current volume and mute state
            pactl set-sink-mute "$sink" 0
            pactl set-sink-volume "$sink" 100%

            # Play the sound at max volume
            paplay "$sound_file"

            # Restore the original volume and mute state
            pactl set-sink-volume "$sink" "$current_volume"
            [ "$current_mute" = "yes" ] && pactl set-sink-mute "$sink" 1
        else
            # If the volume is fine and it's not muted, just play the sound
            paplay "$sound_file"
        fi
    done
}

# Create the main battery alert script
cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash

THRESHOLD=15
BATTERY_LEVEL=$(cat /sys/class/power_supply/BAT0/capacity)
STATUS=$(cat /sys/class/power_supply/BAT0/status)

if [ "$STATUS" = "Discharging" ] && [ "$BATTERY_LEVEL" -lt "$THRESHOLD" ]; then
    notify-send "⚠️ Low Battery" "Battery is at ${BATTERY_LEVEL}%" -u critical

    # Call the function to play the sound with volume adjustment
    "$HOME/.local/bin/battery-alert.sh" "$HOME/Music/Sounds/fails.mp3"
fi
EOF

chmod +x "$SCRIPT_PATH"

# Create the looping wrapper script
cat > "$LOOP_PATH" << EOF
#!/bin/bash
while true; do
    "$SCRIPT_PATH"
    sleep 60
done
EOF

chmod +x "$LOOP_PATH"

# Create the systemd user service
cat > "$SERVICE_FILE" << EOF
[Unit]
Description=Battery Alert Service

[Service]
ExecStart=$LOOP_PATH
Restart=always

[Install]
WantedBy=default.target
EOF

# Enable and start the service
systemctl --user daemon-reexec
systemctl --user enable --now battery-alert.service

echo "✅ Battery alert service installed and running."
