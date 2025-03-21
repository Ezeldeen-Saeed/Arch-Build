
# Install doas and configure it
sudo pacman -S opendoas

echo "permit nopass ezooz as root" | sudo tee /etc/doas.conf > /dev/null

# Move system files to home dir
mv -f .bashrc .bash_profile .xinitrc .gitignore .gitmodules .git/ archBuild/ ../

mv * ../

mv postinstall.sh ../

# Create a usage directory
mkdir Downloads
mkdir Pictures
mkdir Pictures/Wallpapers
mkdir Videos
mkdir Videos/Records
mkdir Music
mkdir files
mkdir drives

mv * ../

mv .config/* ../.config/


doas pacman -S xorg-xrandr xorg-xinput sxhkd feh dunst ttf-dejavu xorg-xinit xorg-xserver libx11 libxft libxinerama

cd $HOME/archBuild/src/dwm/
doas rm config.h
doas make install clean

cd $HOME/archBuild/src/st/
doas rm config.h
doas make install clean


cd $HOME/archBuild/src/dmenu/
doas rm config.h
doas make install clean


cd $HOME/archBuild/src/slstatus/
doas rm config.h
doas make install clean


cd $HOME/archBuild/src/nnn/
doas make install clean
