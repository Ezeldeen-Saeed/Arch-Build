# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# general
alias ll='ls -l'

# pacman
alias i='doas pacman -Sy; doas pacman -S'
alias u='i; doas pacman -U pacman; doas pacman -Syu;'
alias q='doas pacman -Ss'
alias qi='doas pacman -Q'
alias r='doas pacman -Rns'

set -o vi 
export PATH="$HOME/.local/bin:$PATH"
export IDEA_JDK=/usr/lib/jvm/java-17-openjdk/
export PATH=$JAVA_HOME/bin:$PATH
