# XDG_DIRS
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Enable autocompletion
autoload -Uz compinit

# case insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

#set the PERMISSIONS for newly-created files
umask 077

# Brew prefix path
declare -A BREW_PREFIX_PATH

ZSH_CONFIG_DIR="$XDG_CONFIG_HOME/zsh"
for DOTFILE in "$ZSH_CONFIG_DIR"/.{exports,aliases,extra}; do
	[ -r "$DOTFILE" ] && [ -f "$DOTFILE" ] && source "$DOTFILE";
done;


unset ZSH_CONFIG_DIR DOTFILE
