# XDG_DIRS {{{
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
# }}}

# general setting {{{
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077
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

# set the editor to nvim {{{
export EDITOR="nvim"
# }}}

# aliases {{{
alias n="/usr/local/bin/nvim"
alias hh="history -i"
alias cc="clear"
# }}}

declare -A BREW_PREFIX_PATH

# set c compiler {{{
BREW_PREFIX_PATH[llvm]='/usr/local/opt/llvm'
export CC="${BREW_PREFIX_PATH[llvm]}/bin/clang"
export CXX="${BREW_PREFIX_PATH[llvm]}/bin/clang++"
# }}}

# some basic utility {{{
BREW_PREFIX_PATH[coreutils]='/usr/local/opt/coreutils'
export PATH="${BREW_PREFIX_PATH[coreutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[findutils]='/usr/local/opt/findutils'
export PATH="${BREW_PREFIX_PATH[findutils]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[grep]='/usr/local/opt/grep'
export PATH="${BREW_PREFIX_PATH[grep]}/libexec/gnubin:$PATH"

BREW_PREFIX_PATH[curl]='/usr/local/opt/curl'
export PATH="${BREW_PREFIX_PATH[curl]}/bin:$PATH"
# }}}

# zip tools {{{
BREW_PREFIX_PATH[zip]='/usr/local/opt/zip'
export PATH="${BREW_PREFIX_PATH[zip]}/bin:$PATH"

BREW_PREFIX_PATH[unzip]='/usr/local/opt/unzip'
export PATH="${BREW_PREFIX_PATH[unzip]}/bin:$PATH"

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

# pyenv {{{
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
zinit wait lucid for \
    has"pyenv" \
    OMZP::pyenv
# }}}

# kubectl setting {{{
zinit wait lucid for \
    has"kubectl" \
    OMZP::kubectl
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
#
zinit ice wait lucid atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay"
zinit light zdharma-continuum/fast-syntax-highlighting

# some binary {{{
export PATH="$HOME/bin:$PATH"
# }}}

# -- vim: set foldmethod=marker tw=80 sw=4 ts=4 sts =4 sta nowrap et :
