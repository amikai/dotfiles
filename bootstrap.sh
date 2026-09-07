#!/usr/bin/env bash
set -euo pipefail

echo "==> Starting dotfiles bootstrap..."

configure_homebrew() {
    if [ -x /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    elif [ -x /usr/local/bin/brew ]; then
        eval "$(/usr/local/bin/brew shellenv)"
    fi
}

# 1. Discover an existing Homebrew installation before checking PATH
configure_homebrew

# 2. Install Homebrew only if missing, then load its environment
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    configure_homebrew
fi

# 3. Ensure just is installed
if ! command -v just >/dev/null 2>&1; then
    echo "==> Installing just..."
    brew install just
fi

# 4. Hand off to justfile
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> Handing off to just..."
just --justfile "${DOTFILES_DIR}/justfile" --working-directory "${DOTFILES_DIR}" all
