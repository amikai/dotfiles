set shell := ["bash", "-uc"]

dotfiles_dir := justfile_directory()
xdg_config_home := env_var_or_default("XDG_CONFIG_HOME", env_var("HOME") / ".config")

export DOTFILES_DIR := dotfiles_dir
# Some tools use XDG_CONFIG_HOME (e.g. Neovim)
export XDG_CONFIG_HOME := xdg_config_home
export MISE_GLOBAL_CONFIG_FILE := dotfiles_dir / "home/.config/mise/config.toml"
export PATH := "/opt/homebrew/bin:/usr/local/bin:" + env_var("PATH")

# List all available recipes
default:
    @just --list

# Complete setup: sudo, symlinks, and packages
all: sudo link brew-packages

# Keep sudo timestamp updated in background
[no-exit-message]
sudo:
    sudo -v
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Create the symlinks declared under [dotfiles] in home/.config/mise/config.toml.
# Stops, without changing anything, if a target is a regular file.
link: nvim-clone
    mise dot apply --yes

# Remove the symlinks that `just link` created
unlink:
    mise dot unapply --yes

# mise refuses to link ~/.config/nvim while its source is missing
nvim-clone:
    [ -d "{{dotfiles_dir}}/home/.config/nvim/.git" ] || git clone https://github.com/amikai/nvimrc "{{dotfiles_dir}}/home/.config/nvim"

# --- package installation & setup ---

brew-packages: brew-update mise-packages post-packages brew-casks brew-cleanup mise-install nvim-setup hammerspoon-setup agents-setup

brew-update:
    brew update
    brew upgrade

brew-cleanup:
    brew cleanup

brew-casks:
    brew bundle --file="{{dotfiles_dir}}/script/Brewfile"

# Reads the repository config through MISE_GLOBAL_CONFIG_FILE, so it does not
# wait for `link` (which stops while any target is a regular file)
mise-packages:
    mise bootstrap packages apply --yes

post-packages: mise-packages
    #!/usr/bin/env bash
    set -euo pipefail
    BREW_PREFIX="$(brew --prefix)"
    ln -sf "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
    if ! grep -qF "${BREW_PREFIX}/bin/zsh" /etc/shells; then
        echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
        chsh -s "${BREW_PREFIX}/bin/zsh"
    fi

mise-install:
    mise install

nvim-setup: mise-install nvim-clone
    mise exec -- "{{dotfiles_dir}}/script/neovim.sh"

hammerspoon-setup:
    "{{dotfiles_dir}}/script/hammerspoon.sh"

agents-setup: mise-install
    mise exec -- "{{dotfiles_dir}}/script/agents.sh"
