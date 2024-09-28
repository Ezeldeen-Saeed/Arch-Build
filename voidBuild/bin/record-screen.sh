#!/bin/bash

# Get the list of connected displays using xrandr
displays=$(xrandr --query | grep ' connected' | awk '{ print $1 }')

# Use dmenu to select the display
selected_display=$(echo "$displays" | dmenu -i -p "Select display to record:")

# Set the display variable for ffmpeg based on the selected display
if [ "$selected_display" == "LVDS-1" ]; then
    display=":0.0"  # LVDS-1 maps to :0.0
    screen_resolution="1920x1080"
    offset="+0,0"  # No offset for LVDS-1
elif [ "$selected_display" == "VGA-1" ]; then
    display=":0.0"  # VGA-1 still maps to :0.0
    screen_resolution="1680x1050"
    offset="+1930,0"  # Offset for VGA-1
else
    echo "Invalid display selected."
    exit 1
fi

# Set the output file name with a timestamp
output_file="$HOME/Videos/Records/output_$(date +'%Y%m%d_%H%M%S').mp4"
audio_device="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"

# Start recording from the selected display
ffmpeg -f x11grab -s "$screen_resolution" -i "$display$offset" -f pulse -i "$audio_device" \
    -c:v libx264 -preset ultrafast -crf 0 -c:a aac -b:a 320k "$output_file"

echo "Recording saved to $output_file"
