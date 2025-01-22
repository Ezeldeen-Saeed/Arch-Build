#!/bin/bash

# Bluetooth service path
BLUETOOTH_SERVICE="/var/service/bluetoothd"

# Function to check if Bluetooth is running
is_bluetooth_enabled() {
    if sv status bluetoothd | grep -q "run"; then
        return 0
    else
        return 1
    fi
}

# Function to start Bluetooth service
enable_bluetooth() {
    echo "Enabling Bluetooth service..."
    if [ ! -L "$BLUETOOTH_SERVICE" ]; then
        # Only create the symlink if it doesn't already exist
        doas ln -s /etc/sv/bluetoothd /var/service/
    fi
    doas sv up bluetoothd
}

# Function to stop Bluetooth service
disable_bluetooth() {
    echo "Disabling Bluetooth service..."
    doas sv down bluetoothd
    if [ -L "$BLUETOOTH_SERVICE" ]; then
        # Only remove the symlink if it exists
        doas rm -f /var/service/bluetoothd
    fi
}

# Function to scan for Bluetooth devices and display in dmenu
scan_devices() {
    echo "Scanning for Bluetooth devices..."
    
    # Power on Bluetooth and start scan
    doas bluetoothctl power on
    doas bluetoothctl agent on
    doas bluetoothctl default-agent
    doas bluetoothctl scan on &
    
    # Wait for devices to be discovered (adjust this sleep time if needed)
    sleep 10
    
    # Get the list of devices discovered
    devices=$(doas bluetoothctl devices | awk '{print $2 " " $3}')
    doas bluetoothctl scan off  # Stop scanning

    if [[ -z "$devices" ]]; then
        echo "No devices found"
        exit 1
    fi

    # Display scanned devices in dmenu and select one
    selected_device=$(echo "$devices" | dmenu -i -p "Select Bluetooth device to connect:" | awk '{print $1}')
    
    if [[ -z "$selected_device" ]]; then
        echo "No device selected"
        exit 1
    fi

    echo "$selected_device"
}

# Function to pair and connect to the selected device
pair_and_connect() {
    device="$1"
    doas bluetoothctl <<EOF
trust $device
pair $device
connect $device
exit
EOF
}

# Main logic
if is_bluetooth_enabled; then
    # Bluetooth is running, perform scan and disable it after
    device=$(scan_devices)
    if [[ -n "$device" ]]; then
        echo "Connecting to $device"
        pair_and_connect "$device"
        echo "Connected to $device"
    else
        echo "Failed to find device."
        exit 1
    fi
    disable_bluetooth
else
    # Bluetooth is not running, enable it and scan
    enable_bluetooth
    device=$(scan_devices)
    if [[ -n "$device" ]]; then
        echo "Connecting to $device"
        pair_and_connect "$device"
        echo "Connected to $device"
    else
        echo "Failed to find device."
        exit 1
    fi
fi
