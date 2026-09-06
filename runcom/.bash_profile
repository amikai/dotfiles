# Login shells (including GUI editor environment discovery) need tool shims.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash --shims)"
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# XDG_DIRS
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Brew prefix path
declare -A BREW_PREFIX_PATH

BASH_CONFIG_DIR="$XDG_CONFIG_HOME/bash"
for DOTFILE in "$BASH_CONFIG_DIR"/.{bash_prompt,exports,aliases,functions,extra,bash_prompt}; do
	[ -r "$DOTFILE" ] && [ -f "$DOTFILE" ] && source "$DOTFILE";
done;

# Clean up
unset DOTFILE BASH_CONFIG_DIR


# Added by Antigravity CLI installer
export PATH="/Users/amikai/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
