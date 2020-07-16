#!/usr/bin/env zsh

# Load shared configuration settings
for file in 'variables.sh' 'aliases.sh' 'functions.sh' 'ssh-login'; do
  [ -e ~/.zsh/shell-commons/$file ] && source ~/.zsh/shell-commons/$file
done

# zsh specific aliases
alias history='history -d -f -i'

# window title & terminal start directory
case $TERM in
  alacritty|termite|*xterm*|rxvt|rxvt-unicode|rxvt-256color|rxvt-unicode-256color|(dt|k|E)term)
    precmd () {
      print -Pn "\e]0;[%n@%M %~%#]\a"
      echo $(pwd) > $HOME/.terminal_start_directory
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

# zsh-git-prompt settings
[ -e ~/.zsh/zsh-git-prompt/zshrc.sh ] && source ~/.zsh/zsh-git-prompt/zshrc.sh
ZSH_THEME_GIT_PROMPT_PREFIX=" ["
ZSH_THEME_GIT_PROMPT_SUFFIX="]"
ZSH_THEME_GIT_PROMPT_STAGED="%{$fg[green]%}%{▪%G%}"
ZSH_THEME_GIT_PROMPT_CHANGED="%{$fg[red]%}%{▫%G%}"
ZSH_THEME_GIT_PROMPT_CONFLICTS="%{$fg[red]%}%{⚡%G%}"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{…%G%}"
[ -e "$__GIT_PROMPT_DIR/src/.bin/gitstatus" ] && GIT_PROMPT_EXECUTABLE="haskell"

# actual prompt
PROMPT="$(cursorColorToZshColor)%(?.>.▪)%{$reset_color%}"' %n@%m %c$(git_super_status) '
unset -f cursorColorToZshColor

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
bindkey -M isearch          '^N'            history-incremental-search-forward
bindkey -M isearch          '^P'            history-incremental-search-backward
bindkey -M isearch          '^M'            accept-search
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
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY
setopt EXTENDED_HISTORY

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
[ -f ~/.bashhub/bashhub.zsh ] && source ~/.bashhub/bashhub.zsh
if [ -f ~/.zsh/z.lua/z.lua ]; then
  export _ZL_CMD=zz
  eval "$(lua ~/.zsh/z.lua/z.lua --init zsh enhanced once fzf)"
  alias z="$_ZL_CMD -I"
  alias zb="$_ZL_CMD -b"
fi

if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"
