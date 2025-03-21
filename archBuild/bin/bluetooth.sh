#!/bin/bash

# Function to power on Bluetooth and start scanning
enable_bluetooth_and_scan() {
    bluetoothctl power on || { echo "Failed to power on Bluetooth."; exit 1; }
    bluetoothctl agent NoInputNoOutput || { echo "Failed to register agent."; exit 1; }
    bluetoothctl discoverable on || { echo "Failed to make device discoverable."; exit 1; }
    bluetoothctl scan on || { echo "Failed to start scanning."; exit 1; }
    echo "Scanning for devices... Please wait."
    sleep 10
}

# Function to get a list of discovered devices
get_discovered_devices() {
    devices=$(bluetoothctl devices | awk '{print $2 " " substr($0, index($0,$3))}')
    bluetoothctl scan off || { echo "Failed to stop scanning."; exit 1; }
    echo "$devices"
}

# Function to get a list of connected devices
get_connected_devices() {
    connected_devices=$(bluetoothctl devices | grep "Connected" | awk '{print $2 " " substr($0, index($0,$3))}')
    echo "$connected_devices"
}

# Function to pair, trust, and connect to the selected device
pair_and_connect() {
    local device="$1"
    bluetoothctl pair "$device" || { echo "Failed to pair with $device."; exit 1; }
    bluetoothctl trust "$device" || { echo "Failed to trust $device."; exit 1; }
    bluetoothctl connect "$device" || { echo "Failed to connect to $device."; exit 1; }
    echo "Successfully connected to $device."
}

# Function to disconnect from a Bluetooth device
disconnect_from_device() {
    local device="$1"
    bluetoothctl disconnect "$device" || { echo "Failed to disconnect from $device."; exit 1; }
    echo "Disconnected from $device."
}

# Function to disable Bluetooth
disable_bluetooth() {
    bluetoothctl power off || { echo "Failed to power off Bluetooth."; exit 1; }
}

# Function to display menu options using dmenu
display_menu() {
    local options=("Connect" "Disconnect" "Disable" "Exit")
    local selected_option=$(printf "%s\n" "${options[@]}" | dmenu -i -p "Bluetooth Menu:")

    case "$selected_option" in
        "Connect")
            enable_bluetooth_and_scan
            selected_device=$(get_discovered_devices | dmenu -i -p "Select Bluetooth device to connect:")
            if [[ ! -z "$selected_device" ]]; then
                pair_and_connect "$selected_device"
            fi
            ;;
        "Disconnect")
            connected_devices=$(get_connected_devices)
            if [[ -z "$connected_devices" ]]; then
                echo "No connected devices found."
            else
                selected_device=$(echo "$connected_devices" | dmenu -i -p "Select Bluetooth device to disconnect:")
                if [[ ! -z "$selected_device" ]]; then
                    disconnect_from_device "$selected_device"
                fi
            fi
            ;;
        "Disable")
            disable_bluetooth
            ;;
        "Exit")
            exit 0
            ;;
    esac
}

# Main script
display_menu
