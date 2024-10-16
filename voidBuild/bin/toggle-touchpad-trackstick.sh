#!/bin/sh

# Replace these IDs with the actual IDs of your touchpad and trackstick
TOUCHPAD_ID=18
TRACKSTICK_ID=19

# Function to check if a device is enabled
is_device_enabled() {
    xinput list-props $1 | grep "Device Enabled (.*):.*1" > /dev/null
}

# Function to enable devices
enable_devices() {
    xinput enable $TOUCHPAD_ID
    xinput enable $TRACKSTICK_ID
    echo "Touchpad and Trackstick enabled."
}

# Function to disable devices
disable_devices() {
    xinput disable $TOUCHPAD_ID
    xinput disable $TRACKSTICK_ID
    echo "Touchpad and Trackstick disabled."
}

# Check the current state of the touchpad and trackstick and toggle
if is_device_enabled $TOUCHPAD_ID; then
    disable_devices
else
    enable_devices
fi

