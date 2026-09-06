# XDG_DIRS
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"

# Login shells (including GUI editor environment discovery) need tool shims.
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash --shims)"
fi

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Prompt
PS1="\e[0;32m\u\e[m@\e[0;34m\h\e[m \e[0;33m\w\e[m \n> "

# Added by Antigravity CLI installer
export PATH="/Users/amikai/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate bash)"
fi
