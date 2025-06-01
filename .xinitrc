setxkbmap -layout us,ara -variant ,digits -option grp:alt_shift_toggle caps:swapescape altwin:menu_win
xrandr --output VGA-1 --right-of LVDS1
xrandr --output LVDS-1 --pos -10x0
synclient tapbutton1=1
sxhkd &
slstatus &
/usr/lib/vktablet/vktablet &
feh --bg-fill "$HOME/Pictures/Wallpapers/gruvbox/wall5.jpg"
dunst &
dwm
