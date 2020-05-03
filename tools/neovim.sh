#!/usr/bin/env bash


git clone https://github.com/amikai/nvimrc "$DOTFILES_DIR"/config/nvim
nvim +qa
nvim +checkhealth +"call dein#remote_plugins()" +qa
