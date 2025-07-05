#!/usr/bin/env bash

download_nvimrc() {
    git clone https://github.com/amikai/nvimrc "$DOTFILES_DIR"/config/nvim
}

install_nvim_plugin() {
    nvim --headless -c 'lua require("lazy").sync()' -c 'checkhealth' -c 'quitall'
}

download_nvimrc
install_nvim_plugin
