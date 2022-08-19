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
    # jsonnet ls
    go install github.com/grafana/jsonnet-language-server@latest
    #  vscode-langservers-extracted install following:
    #     vscode-html-language-server
    #     vscode-css-language-server
    #     vscode-json-language-server
    #     vscode-eslint-language-server
    npm install -g vscode-langservers-extracted
}


install_nvim_plugin() {
    nvim -c 'checkhealth' -c 'autocmd User PackerComplete quitall' -c 'PackerSync'
}

download_nvimrc
install_dep
install_nvim_plugin
