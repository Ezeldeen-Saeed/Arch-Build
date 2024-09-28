#!/bin/sh

# Function to change volume and unmute
change_volume() {
    local adjustment=$1
    amixer set Master "$adjustment"
    amixer set Speaker+LO "$adjustment"

    # Unmute if muted
    if amixer get Master | grep -q '\[off\]'; then
        amixer set Master unmute
    fi
    if amixer get Speaker+LO | grep -q '\[off\]'; then
        amixer set Speaker+LO unmute
    fi
}

# Function to toggle mute status
toggle_mute() {
    if amixer get Master | grep -q '\[off\]'; then
        amixer set Master unmute
    else
        amixer set Master mute
    fi

    if amixer get Speaker+LO | grep -q '\[off\]'; then
        amixer set Speaker+LO unmute
    else
        amixer set Speaker+LO mute
    fi
}

# Check the argument and call the appropriate function
case "$1" in
    up)
        change_volume "2%+"
        ;;
    down)
        change_volume "2%-"
        ;;
    mute)
        toggle_mute
        ;;
    *)
        echo "Usage: $0 {up|down|mute}"
        exit 1
        ;;
esac

