# .bash_profile


# Get the aliases and functions
[ -f $HOME/.bashrc ] && . $HOME/.bashrc

doas loadkeys .config/loadkeys/loadkeysrc

export BROWSER="firefox"
export TERMINAL="st"
export TERM="st"
export EDITOR="vim"
export NNN_OPENER="$HOME/.config/nnn/nnn-opener"


[[ ! $DISPLAY && $(tty) = "/dev/tty1" ]] && startx
