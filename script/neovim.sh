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
    brwe install cscope
    brew install --with-jansson --with-libyaml --HEAD universal-ctags/universal-ctags/universal-ctags

    # terraform ls
    brew install hashicorp/tap/terraform-ls
    # dockerfile ls
    npm install -g dockerfile-language-server-nodejs
    # ansible ls
    npm install -g @ansible/ansible-language-server
    # yaml ls
    brew install yaml-language-server
    # bash ls
    npm install -g bash-language-server
    # vimscript ls
    npm install -g vim-language-server
    # python ls
    install install_pylsp_deps
}


install_nvim_plugin() {
	nvim --cmd "so $DOTFILES_DIR/config/nvim/init.vim" +checkhealth +"call dein#remote_plugins()" +qa
}

download_nvimrc
install_dep
install_nvim_plugin
