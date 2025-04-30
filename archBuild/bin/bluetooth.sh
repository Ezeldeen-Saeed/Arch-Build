#!/bin/bash

SUCCESS_SOUND="$HOME/Music/Sounds/success.mp3"
FAIL_SOUND="$HOME/Music/Sounds/fails.mp3"


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

# Power on Bluetooth and reset any existing filters
bluetoothctl power on &>/dev/null
sleep 1

# Reset any existing filter by disabling discovery filters
bluetoothctl scan on &>/dev/null
sleep 2

# Check if Bluetooth adapter exists
bluetoothctl list &>/dev/null
if [ $? -ne 0 ]; then
    notify-send -u critical "Bluetooth Adapter Not Found"
    adjust_volume_and_play "$FAIL_SOUND"
    exit 1
fi

# Get list of available devices
mapfile -t devices < <(bluetoothctl devices | awk '{$1=""; print substr($0,2)}')

if [ "${#devices[@]}" -eq 0 ]; then
    notify-send -u critical "No Bluetooth Devices Found"
    adjust_volume_and_play "$FAIL_SOUND"
    exit 1
fi

# Pick a device
selection=$(printf "%s\n" "${devices[@]}" | rofi -dmenu -theme ~/.config/rofi/gruvbox.rasi -p "Select Bluetooth Device")
[ -z "$selection" ] && exit

mac=$(bluetoothctl devices | grep "$selection" | awk '{print $2}')
name="$selection"

# Check if the device is already connected
if bluetoothctl info "$mac" | grep -q "Connected: yes"; then
    bluetoothctl disconnect "$mac" &>/dev/null
    notify-send "📴 Disconnected" "$name disconnected"
    adjust_volume_and_play "$SUCCESS_SOUND"
    exit
fi

# If device is already paired, just connect
if bluetoothctl paired-devices | grep -q "$mac"; then
    # Device is paired, try to connect
    if bluetoothctl connect "$mac" &>/dev/null; then
        notify-send "🔊 Connected" "Connected to '$name'"
        adjust_volume_and_play "$SUCCESS_SOUND"
        exit
    else
        notify-send -u critical -i dialog-warning "❌ Connection Failed" "Could not connect to '$name'"
        adjust_volume_and_play "$FAIL_SOUND"
        exit 1
    fi
fi

# Try trusting, pairing, and connecting
bluetoothctl trust "$mac" &>/dev/null
sleep 1
if ! bluetoothctl pair "$mac" &>/dev/null; then
    # Attempt workaround for stubborn devices like AirPods
    bluetoothctl remove "$mac" &>/dev/null
    sleep 1
    bluetoothctl scan on &>/dev/null
    sleep 2
    bluetoothctl scan off &>/dev/null
    bluetoothctl trust "$mac" &>/dev/null
    sleep 1
    if ! bluetoothctl pair "$mac" &>/dev/null; then
        notify-send -u critical -i dialog-warning "❌ Pairing Failed" "Could not pair with '$name'. Try manual pairing."
        adjust_volume_and_play "$FAIL_SOUND"
        exit 1
    fi
fi

# Try connecting after successful pairing
if bluetoothctl connect "$mac" &>/dev/null; then
    notify-send "🔊 Connected" "Connected to '$name'"
    adjust_volume_and_play "$SUCCESS_SOUND"
else
    notify-send -u critical -i dialog-warning "❌ Connection Failed" "Could not connect to '$name'"
    adjust_volume_and_play "$FAIL_SOUND"
fi

bluetoothctl scan off &>/dev/null
