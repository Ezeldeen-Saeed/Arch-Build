#!/bin/sh

# Function to change volume and unmute
change_volume() {
    local adjustment=$1
    # Adjust volume using pactl for PulseAudio
    pactl set-sink-volume @DEFAULT_SINK@ "$adjustment"
    
    # Unmute if muted
    if pactl list sinks | grep -q 'Mute: yes'; then
        pactl set-sink-mute @DEFAULT_SINK@ false
    fi

    # Optional: Show the current volume level
    pactl list sinks | grep 'Volume'
}

# Function to toggle mute status
toggle_mute() {
    # Toggle mute using pactl for PulseAudio
    if pactl list sinks | grep -q 'Mute: yes'; then
        pactl set-sink-mute @DEFAULT_SINK@ false
        echo "Unmuted"
    else
        pactl set-sink-mute @DEFAULT_SINK@ true
        echo "Muted"
    fi
}

# Check the argument and call the appropriate function
case "$1" in
    up)
        change_volume "+2%"
        ;;
    down)
        change_volume "-2%"
        ;;
    mute)
        toggle_mute
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac
