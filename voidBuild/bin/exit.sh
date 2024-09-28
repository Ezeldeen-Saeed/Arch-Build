#!/bin/sh

choice=$(echo "Shutdown\nReboot\nExit" | dmenu)

[ $choice = "Shutdown" ] && doas poweroff
[ $choice = "Reboot" ] && doas reboot
[ $choice = "Exit" ] && pkill dwm
