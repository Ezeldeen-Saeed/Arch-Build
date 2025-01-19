# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# general
alias ll='ls -l'

# xbps
alias i='doas pacman -S'
alias u='i; doas pacman -U pacman; doas pacman -U'
alias q='doas pacman -Q'
alias r='doas pacman -R'

set -o vi 
export PATH="$HOME/.local/bin:$PATH"
