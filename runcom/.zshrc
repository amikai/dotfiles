# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# binary path installed by homebrew {{{
export PATH="/opt/homebrew/bin:$PATH"
# }}}

# general setting {{{
# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077

# cacert
export SSL_CERT_FILE=/etc/ssl/cert.pem

# }}}

# initialize zinit {{{
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [[ ! -f $ZINIT_HOME/zinit.zsh ]]; then
    mkdir -p "$(dirname $ZINIT_HOME)"
    git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
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
zinit wait lucid for \
    zsh-users/zsh-autosuggestions \
    zdharma-continuum/history-search-multi-word

zinit wait lucid for \
    OMZL::key-bindings.zsh \
    OMZL::completion.zsh \
    OMZL::theme-and-appearance.zsh \
    OMZP::colored-man-pages
# }}}

# zsh vi mode {{{
ZVM_VI_INSERT_ESCAPE_BINDKEY=jk
zinit wait lucid for \
    jeffreytse/zsh-vi-mode
# }}}

# set the editor to nvim {{{
export EDITOR="nvim"
# }}}

# aliases {{{
alias n="/opt/homebrew/bin/nvim"
alias hh="history -i"
alias cc="clear"
alias l="exa"
alias g="git"
# }}}

declare -A BREW_PREFIX_PATH

# set c compiler {{{
BREW_PREFIX_PATH[llvm]='/opt/homebrew/opt/llvm'
export CC="${BREW_PREFIX_PATH[llvm]}/bin/clang"
export CXX="${BREW_PREFIX_PATH[llvm]}/bin/clang++"
# }}}

# some basic utility {{{
BREW_PREFIX_PATH[coreutils]='/opt/homebrew/opt/coreutils'
export PATH="${BREW_PREFIX_PATH[coreutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[findutils]='/opt/homebrew/opt/findutils'
export PATH="${BREW_PREFIX_PATH[findutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[grep]='/opt/homebrew/opt/grep'
export PATH="${BREW_PREFIX_PATH[grep]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[curl]='/opt/homebrew/opt/curl'
export PATH="${BREW_PREFIX_PATH[curl]}/bin:$PATH"
# }}}

# zip tools {{{
BREW_PREFIX_PATH[zip]='/opt/homebrew/opt/zip'
export PATH="${BREW_PREFIX_PATH[zip]}/bin:$PATH"

BREW_PREFIX_PATH[unzip]='/opt/homebrew/opt/unzip'
export PATH="${BREW_PREFIX_PATH[unzip]}/bin:$PATH"

# }}}

# rust {{{
export PATH="$HOME/.cargo/bin:$PATH"
# }}}

# golang {{{
BREW_PREFIX_PATH[golang]='/opt/homebrew/opt/go'
export GOROOT="${BREW_PREFIX_PATH[golang]}/libexec"
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"
zinit wait lucid for \
    has"go" \
    as"completion" \
    OMZP::golang/_golang

# }}}

# nvm dir {{{
export NVM_DIR="$XDG_CONFIG_HOME/nvm"
export PATH="/opt/homebrew/opt/node@16/bin:$PATH"
# }}}

# pyenv {{{
export PYENV_ROOT="$HOME/.pyenv"
eval "$(pyenv init -)"
zinit wait lucid for \
    has"pyenv" \
    OMZP::pyenv
# }}}

# kubectl setting {{{
zinit wait lucid for \
    has"kubectl" \
    OMZP::kubectl

zinit wait lucid for \
    has"minikube" \
    OMZP::minikube
# }}}

# helm setting {{{
zinit wait lucid for \
    has"helm" \
    OMZP::helm
# }}}

# gcloud setting {{{
zinit wait lucid for \
    has"gcloud" \
    OMZP::gcloud
# }}}

# docker setting {{{
zinit wait lucid for \
    has"docker" \
    as"completion" \
    OMZP::docker/_docker
# }}}

zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# some binary {{{
export PATH="$HOME/bin:$PATH"
# }}}

# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :
