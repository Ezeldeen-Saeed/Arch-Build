# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# general
alias ll='ls -l'

# xbps
alias i='doas xbps-install -S'
alias u='i; doas xbps-install -u xbps; doas xbps-install -u'
alias q='doas xbps-query -Rs'
alias r='doas xbps-remove -R'

set -o vi 
export PATH="$HOME/.local/bin:$PATH"
export CPLUS_INCLUDE_PATH=/usr/include/c++/13.2.0:/usr/local/include:$CPLUS_INCLUDE_PATH
