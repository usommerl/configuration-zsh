#!/usr/bin/env zsh

# Load shared configuration settings
for name in 'variables' 'aliases' 'functions' 'ssh-login'; do
    if [ -e ~/.zsh/shell-commons/$name ]; then
        source ~/.zsh/shell-commons/$name
    fi
done

# zsh specific aliases
alias history='history -d -f -i'

# window title & terminal start directory
case $TERM in
    termite|*xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
        precmd () { 
            print -Pn "\e]0;[%n@%M %~%#]\a" 
            echo $(pwd) > $HOME/.urxvt/start_directory
        }
        preexec () { print -Pn "\e]0;[%n@%M %~%#] $1\a" }
    ;;
    screen|screen-256color)
        precmd () { 
            print -Pn "\e]83;title \"$1\"\a" 
            print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~]\a" 
        }
        preexec () { 
            print -Pn "\e]83;title \"$1\"\a" 
            print -Pn "\e]0;$TERM - (%L) [%n@%M]%# [%~] ($1)\a" 
        }
    ;; 
esac

# options
setopt PROMPT_SUBST
setopt AUTO_CD
setopt AUTO_PUSHD
setopt EXTENDED_GLOB
setopt NO_CASE_GLOB
setopt COMPLETE_IN_WORD
#setopt completealiases

# load functions
fpath=(~/.zsh/functions ~/.zsh/completions $fpath)
autoload -U ~/.zsh/functions/*(:t)
autoload -U compinit && compinit
autoload -U promptinit && promptinit
autoload -U colors && colors
autoload -U zmv

unalias run-help 2>/dev/null
autoload -U run-help
autoload run-help-git
autoload run-help-svn
autoload run-help-svk

# prompt
PROMPT="$(cursorColorToZshColor)>%{$reset_color%} %n@%m %c%# "
RPROMPT="$(cursorColorToZshColor)⋅%{$reset_color%}"
unset -f cursorColorToZshColor

# ls colors
eval $(dircolors $HOME/.dir_colors 2>/dev/null)

# load modules
zmodload -i zsh/complist

# completion
zstyle ':completion:*' menu select
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*:processes' command 'ps --forest -e -o pid,user,tty,cmd'

# keybindings
bindkey -e
bindkey                     '^R'            history-incremental-search-backward
bindkey                     '^A'            beginning-of-line
bindkey                     '^E'            end-of-line
bindkey                     '^[[1;5D'       backward-word
bindkey                     '^[[1;5C'       forward-word
bindkey                     '^[[3~'         delete-char
bindkey                     '^U'            backward-kill-line
bindkey                     '^K'            kill-line
bindkey -M menuselect       'h'             backward-char
bindkey -M menuselect       'j'             down-line-or-history
bindkey -M menuselect       'k'             up-line-or-history
bindkey -M menuselect       'l'             forward-char

# history 
HISTFILE=~/.zsh/zsh_history
SAVEHIST=10000
HISTSIZE=10000
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

# vim: set filetype=sh:
