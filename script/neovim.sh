#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="$DOTFILES_DIR/config/nvim"

# The justfile's nvim-clone recipe clones the repository before this runs.
update_nvimrc() {
    git -C "$NVIM_CONFIG_DIR" pull --ff-only
}

install_nvim_plugin() {
    nvim --headless -c 'lua require("lazy").sync()' -c 'checkhealth' -c 'quitall'
}

update_nvimrc
install_nvim_plugin
