# Login shells expose shims to GUI editors (e.g. VS Code) without loading interactive plugins.
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
# mise's official installer puts the binary here.
export PATH="$HOME/.local/bin:$PATH"
if command -v mise >/dev/null 2>&1; then
    eval "$(mise activate zsh --shims)"
fi
