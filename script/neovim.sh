#!/usr/bin/env bash
set -euo pipefail

NVIM_CONFIG_DIR="$DOTFILES_DIR/config/nvim"

download_nvimrc() {
    if [ -d "$NVIM_CONFIG_DIR/.git" ]; then
        git -C "$NVIM_CONFIG_DIR" pull --ff-only
    else
        git clone https://github.com/amikai/nvimrc "$NVIM_CONFIG_DIR"
    fi
}

install_nvim_plugin() {
    nvim --headless -c 'lua require("lazy").sync()' -c 'checkhealth' -c 'quitall'
}

download_nvimrc
install_nvim_plugin
