#!/usr/bin/env bash


download_nvimrc() {
	git clone https://github.com/amikai/nvimrc "$DOTFILES_DIR"/config/nvim
}

install_dep() {
	local PIP2="$(pyenv which pip2)"
	local PIP3="$(pyenv which pip3)"
	"$PIP2" install pynvim neovim
	"$PIP3" install pynvim neovim
}

install_nvim_plugin() {
	nvim --cmd "so $DOTFILES_DIR/config/nvim/init.vim" +checkhealth +"call dein#remote_plugins()" +qa
}

download_nvimrc
install_dep
install_nvim_plugin
