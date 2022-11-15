#!/usr/bin/env bash

PIP2="$(pyenv which pip2)"
PIP3="$(pyenv which pip3)"

download_nvimrc() {
	git clone https://github.com/amikai/nvimrc "$DOTFILES_DIR"/config/nvim
}

install_pylsp_deps() {
    "$PIP3" install "python-lsp-server[all]"
    "$PIP3" install pyls-flake8
    "$PIP3" install pylsp-mypy
    "$PIP3" install python-lsp-black
    "$PIP3" install pylsp-rope
}

install_dep() {
	"$PIP2" install pynvim neovim
	"$PIP3" install pynvim neovim

    # For code navigation and plugin dependencies
    brew install global
    brew install cscope
    brew install --HEAD universal-ctags/universal-ctags/universal-ctags

    # python ls
    install_pylsp_deps
}


install_nvim_plugin() {
    nvim -c 'checkhealth' -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

download_nvimrc
install_dep
install_nvim_plugin
