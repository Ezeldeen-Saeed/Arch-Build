#!/bin/bash

# Function to get the resolution of a monitor
get_resolution() {
    monitor=$1
    resolution=$(xrandr | grep "$monitor" | awk '{print $3}' | sed 's/[^0-9x]//g')
    if [ -z "$resolution" ]; then
        echo "Error: Could not retrieve resolution for $monitor"
        exit 1
    fi
    echo "$resolution"
}

# Function to get connected monitors
get_connected_monitors() {
    xrandr | grep ' connected' | awk '{print $1}'
}

# Function to duplicate monitors and scale the secondary monitor
duplicate_monitors() {
    # Scale secondary monitor to match primary resolution
    xrandr --output "$secondary_monitor" --auto --same-as "$primary_monitor"
}

# Function to extend monitors with a specified position
extend_monitors() {
    primary_monitor=$1
    secondary_monitor=$2
    position=$3

    xrandr --output "$primary_monitor" --auto
    xrandr --output "$secondary_monitor" --auto

    case "$position" in
        "Top")
            xrandr --output "$secondary_monitor" --above "$primary_monitor"
            ;;
        "Bottom")
            xrandr --output "$secondary_monitor" --below "$primary_monitor"
            ;;
        "Right")
            xrandr --output "$secondary_monitor" --right-of "$primary_monitor"
            ;;
        "Left")
            xrandr --output "$secondary_monitor" --left-of "$primary_monitor"
            ;;
        *)
            echo "Invalid position selected."
            ;;
    esac
}

# Show options using dmenu for the main choice
show_options() {
    echo -e "Extend\nDuplicate\nOnly Primary\nOnly Secondary" | dmenu -p "Select display mode:"
}

# Show position options using dmenu for extending
show_extend_options() {
    echo -e "Top\nBottom\nRight\nLeft" | dmenu -p "Select position to extend:"
}

# Get the list of connected monitors
monitors=$(get_connected_monitors)
primary_monitor=$(echo "$monitors" | head -n 1)  # Assume the first monitor is the primary
secondary_monitor=$(echo "$monitors" | tail -n 1)  # Assume the second monitor is the secondary

# Check if both monitors are detected
if [ -z "$primary_monitor" ] || [ -z "$secondary_monitor" ]; then
    echo "Error: Both monitors must be connected."
    exit 1
fi

# Show options and get user selection
selected_option=$(show_options)

case "$selected_option" in
    "Duplicate")
        duplicate_monitors "$primary_monitor" "$secondary_monitor"
        ;;
    "Extend")
        # Show position options and get user selection
        extend_position=$(show_extend_options)
        if [ -z "$extend_position" ]; then
            echo "No position selected or canceled."
            exit 1
        fi
        extend_monitors "$primary_monitor" "$secondary_monitor" "$extend_position"
        ;;
    "Only Primary")
        xrandr --output "$primary_monitor" --auto --output "$secondary_monitor" --off
        ;;
    "Only Secondary")
        xrandr --output "$primary_monitor" --off --output "$secondary_monitor" --auto
        ;;
    *)

        echo "No valid option selected or canceled."
        ;;
esac

