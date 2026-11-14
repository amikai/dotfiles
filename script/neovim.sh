#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="$DOTFILES_DIR/home/.config/nvim"

# The nvim-clone task in mise.toml clones the repository before this runs.
update_nvimrc() {
    git -C "$NVIM_CONFIG_DIR" pull --ff-only
}

install_nvim_plugin() {
    nvim --headless '+Lazy! sync' +qa
}

update_nvimrc
install_nvim_plugin
