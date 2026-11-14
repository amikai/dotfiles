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

# 2. Install Homebrew only if missing, then load its environment. It installs
#    the casks in script/Brewfile; mise installs formulae without it.
if ! command -v brew >/dev/null 2>&1; then
    echo "==> Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    configure_homebrew
fi

# 3. Ensure mise is installed; it installs the remaining packages
if ! command -v mise >/dev/null 2>&1; then
    echo "==> Installing mise..."
    brew install mise
fi

# 4. Hand off to the tasks in mise.toml
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "==> Handing off to mise..."
mise trust "${DOTFILES_DIR}/mise.toml"
mise -C "${DOTFILES_DIR}" run setup
