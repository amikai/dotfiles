# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# set some homebrew env variable and set path {{{
eval $(/opt/homebrew/bin/brew shellenv)
# }}}

# general setting {{{
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077

# cacert
export SSL_CERT_FILE=/etc/ssl/cert.pem

export EDITOR="nvim"
export VISUAL="nvim"

# use vim keybinding
bindkey -v

autoload edit-command-line
zle -N edit-command-line
bindkey -M viins '^x^e' edit-command-line
bindkey -M vicmd "X" edit-command-line

alias n='nvim'
# }}}

# history setting {{{
export HISTFILE=$XDG_CACHE_HOME/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
# }}}

# zim setting {{{
zstyle ':zim:zmodule' use 'degit'
ZIM_HOME="${XDG_CACHE_HOME}/zim"
ZIM_CONFIG_FILE="${XDG_CONFIG_HOME}/zsh/zimrc.zsh"
ZVM_INIT_MODE=sourcing

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules, and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh
# }}}

declare -A BREW_PREFIX_PATH

# set c compiler {{{
BREW_PREFIX_PATH[llvm]="${HOMEBREW_PREFIX}/opt/llvm"
export CC="${BREW_PREFIX_PATH[llvm]}/bin/clang"
export CXX="${BREW_PREFIX_PATH[llvm]}/bin/clang++"
# }}}

# some basic utility {{{
BREW_PREFIX_PATH[coreutils]="${HOMEBREW_PREFIX}/opt/coreutils"
export PATH="${BREW_PREFIX_PATH[coreutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[findutils]="${HOMEBREW_PREFIX}/opt/findutils"
export PATH="${BREW_PREFIX_PATH[findutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[grep]="${HOMEBREW_PREFIX}/opt/grep"
export PATH="${BREW_PREFIX_PATH[grep]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[curl]="${HOMEBREW_PREFIX}/opt/curl"
export PATH="${BREW_PREFIX_PATH[curl]}/bin:$PATH"

# Add to $PATH is not work, because time is built-in command
BREW_PREFIX_PATH[time]="${HOMEBREW_PREFIX}/opt/gnu-time/libexec/gnubin"
# }}}

# zip tools {{{
BREW_PREFIX_PATH[zip]="${HOMEBREW_PREFIX}/opt/zip"
export PATH="${BREW_PREFIX_PATH[zip]}/bin:$PATH"

BREW_PREFIX_PATH[unzip]="${HOMEBREW_PREFIX}/opt/unzip"
export PATH="${BREW_PREFIX_PATH[unzip]}/bin:$PATH"

# }}}

# rust {{{
export PATH="$HOME/.cargo/bin:$PATH"
# }}}

# golang {{{
BREW_PREFIX_PATH[golang]="${HOMEBREW_PREFIX}/opt/go"
export GOROOT="${BREW_PREFIX_PATH[golang]}/libexec"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# }}}

# nvm dir {{{
BREW_PREFIX_PATH[nvm]="${HOMEBREW_PREFIX}/opt/nvm"
NVM_DIR="${BREW_PREFIX_PATH[nvm]}"
# }}}

# pyenv {{{
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"
# }}}

# some binary {{{
export PATH="$HOME/bin:$PATH"
# }}}

ls() {
    if command -v eza &> /dev/null; then
        command eza "$@"
    else
        command ls "$@"
    fi
}

xtime() {
    if [ -f "$BREW_PREFIX_PATH[time]/time" ]; then
        command "${HOMEBREW_PREFIX}/opt/gnu-time/libexec/gnubin/time" "$@"
    elif [ -f "/usr/bin/time" ]; then
        command "/usr/bin/time" "$@"
    else
        time "$@"
    fi
}

# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :
