# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# initialize zinit {{{
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
# }}}

# general setting {{{
# enable autocompletion
autoload -Uz compinit
compinit

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077
# }}}

# history setting {{{
export HISTFILE=$XDG_CACHE_HOME/.histfile
export HISTSIZE=1000000   # the number of items for the internal history list
export SAVEHIST=1000000   # maximum number of items for the history file

setopt INC_APPEND_HISTORY_TIME  # append command to history file immediately after execution
setopt EXTENDED_HISTORY  # record command start time
setopt SHARE_HISTORY
# }}}

# zsh prompt {{{
zinit ice compile'(pure|async).zsh' pick'async.zsh' src'pure.zsh'
zinit light sindresorhus/pure
# }}}

# zsh user experience {{{
zinit ice wait lucid atload'_zsh_autosuggest_start'
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-history-substring-search

zinit snippet OMZ::lib/key-bindings.zsh
zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::lib/theme-and-appearance.zsh
# }}}

# set the editor to nvim {{{
export EDITOR="nvim"
# }}}

# aliases {{{
alias n="/usr/local/bin/nvim"
alias hh="history -i"
# }}}

declare -A BREW_PREFIX_PATH

# set c compiler {{{
BREW_PREFIX_PATH[llvm]='/usr/local/opt/llvm'
export CC="${BREW_PREFIX_PATH[llvm]}/bin/clang"
export CXX="${BREW_PREFIX_PATH[llvm]}/bin/clang++"
# }}}

# some basic utility {{{
BREW_PREFIX_PATH[coreutils]='/usr/local/opt/coreutils'
export PATH="${BREW_PREFIX_PATH[coreutils]}libexec/gnubin:$PATH"

BREW_PREFIX_PATH[findutils]='/usr/local/opt/findutils'
export PATH="${BREW_PREFIX_PATH[findutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[grep]='/usr/local/opt/grep'
export PATH="${BREW_PREFIX_PATH[grep]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[curl]='/usr/local/opt/curl'
export PATH="${BREW_PREFIX_PATH[curl]}/bin:$PATH"
# }}}

# rust {{{
export PATH="$HOME/.cargo/bin:$PATH"
# }}}

# golang {{{
BREW_PREFIX_PATH[golang]='/usr/local/opt/go'
export GOROOT="${BREW_PREFIX_PATH[golang]}/libexec"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
# }}}

# nvm dir {{{
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
# }}}

# TODO: use OMZ pyenv and lazy load
# pyenv {{{
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
zinit ice lucid wait '1'
zinit snippet OMZ::plugins/pyenv/pyenv.plugin.zsh
# }}}

# TODO: use OMZ nvm and lazy load

# kubectl setting {{{
zinit ice lucid wait '1'
zinit snippet OMZ::plugins/kubectl/kubectl.plugin.zsh
# }}}

# helm setting {{{
zinit ice lucid wait '1'
zinit snippet OMZ::plugins/helm/helm.plugin.zsh
# }}}

# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :
