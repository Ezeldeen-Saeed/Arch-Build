setxkbmap -layout us,ara -variant ,digits -option grp:alt_shift_toggle caps:swapescape altwin:menu_win
xrandr --output VGA1 --right-of LVDS1
xrandr --output LVDS1 --pos -10x0
sxhkd &
slstatus &
feh --bg-fill "$HOME/Pictures/Wallpapers/Natural/sam-plummer-TEC9kkg_6BQ-unsplash.jpg"
dwm
xinput disable 18 && xinput disable 19
