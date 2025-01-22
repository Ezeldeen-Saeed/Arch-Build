#!/bin/bash

# Define the tmpPID file path
tmpPID="/tmp/.tmp_recording_pid"

# Check if the tmpPID file exists and is not empty
if [ -s "$tmpPID" ]; then
    kill $(cat "$tmpPID")  # Kill the process ID stored in tmpPID
    rm -rf "$tmpPID"       # Remove the tmpPID file
    # Send signal to slstatus to update the status
    pkill -RTMIN+10 slstatus
    exit 1                 # Exit the script after killing the process
fi

# Get the list of connected displays using xrandr
displays=$(xrandr --query | grep ' connected' | awk '{ print $1 }')

# Use dmenu to select the display
selected_display=$(echo "$displays" | dmenu -i -p "Select display to record:")

# Set the display variable for ffmpeg based on the selected display
if [ "$selected_display" == "LVDS-1" ]; then
    display=":0.0"  # LVDS1 maps to :0.0
    screen_resolution="1920x1080"
    offset="+0,0"  # No offset for LVDS1
elif [ "$selected_display" == "VGA-1" ]; then
    display=":0.0"  # VGA1 still maps to :0.0
    screen_resolution="1680x1050"
    offset="+1930,0"  # Offset for VGA1
else
    echo "Invalid display selected."
    exit 1
fi

# Set the output file name with a timestamp
output_file="$HOME/Videos/Records/output_$(date +'%Y%m%d_%H%M%S').mp4"
audio_device="alsa_output.pci-0000_00_1b.0.analog-stereo.monitor"
microphone_device="alsa_input.pci-0000_00_1b.0.analog-stereo"

# Update slstatus to show recording status
echo "[[ Recording ]]" > "$tmpPID"

# Send signal to slstatus to update the status bar
pkill -RTMIN+10 slstatus

# Start recording from the selected display with both desktop and microphone audio
ffmpeg -f x11grab -s "$screen_resolution" -i "$display$offset" \
    -f pulse -i "$audio_device" -f pulse -i "$microphone_device" \
    -c:v libx264 -preset ultrafast -crf 0 -c:a aac -b:a 320k \
    -filter_complex "[1:a][2:a]amerge=inputs=2[a]" -map 0:v -map "[a]" \
    "$output_file"

# After recording is done, clear the slstatus message
rm -rf "$tmpPID"
pkill -RTMIN+10 slstatus  # Send signal to slstatus to clear the "Recording" status

echo "Recording saved to $output_file"
