#!/bin/sh

choice=$(echo "Shutdown
Reboot
Exit" | dmenu)

[ $choice = "Shutdown" ] && doas poweroff
[ $choice = "Reboot" ] && doas reboot
[ $choice = "Exit" ] && pkill dwm
