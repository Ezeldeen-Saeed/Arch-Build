#!/bin/sh

choice=$(echo "Shutdown
Reboot
Exit
Suspend" | dmenu)

[ $choice = "Shutdown" ] && doas poweroff
[ $choice = "Reboot" ] && doas reboot
[ $choice = "Exit" ] && pkill dwm
[ $choice = "Suspend" ] && echo 1 | doas tee /sys/bus/pci/devices/0000:01:00.0/remove && systemctl suspend
