setxkbmap -layout us,ara -variant ,digits -option grp:alt_shift_toggle caps:swapescape altwin:menu_win
xrandr --output VGA-1 --right-of LVDS1
xrandr --output LVDS-1 --pos -10x0
synclient tapbutton1=1
sxhkd &
slstatus &
feh --bg-fill "$HOME/Pictures/Wallpapers/Gruvbox/White-Mountain.jpg"
$HOME/archBuild/bin/battery-charging-notification.sh &
dwm
dunst &
xinput disable 14 && xinput disable 15
