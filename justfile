set shell := ["bash", "-uc"]

dotfiles_dir := justfile_directory()
xdg_config_home := env_var_or_default("XDG_CONFIG_HOME", env_var("HOME") / ".config")

export DOTFILES_DIR := dotfiles_dir
export MISE_GLOBAL_CONFIG_FILE := dotfiles_dir / "config/mise/config.toml"
export PATH := "/opt/homebrew/bin:" + env_var("PATH")

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

# Create all symlinks
link: link-runcom link-config

# Remove all symlinks
unlink: unlink-runcom unlink-config

# --- runcom links ---

link-runcom:
    ln -sf "{{dotfiles_dir}}/runcom/.bash_profile" "$HOME/.bash_profile"
    ln -sf "{{dotfiles_dir}}/runcom/.commitlintrc.yaml" "$HOME/.commitlintrc.yaml"
    ln -sf "{{dotfiles_dir}}/runcom/.golangci.yaml" "$HOME/.golangci.yaml"
    ln -sf "{{dotfiles_dir}}/runcom/.inputrc" "$HOME/.inputrc"
    ln -sf "{{dotfiles_dir}}/runcom/.zshrc" "$HOME/.zshrc"
    ln -sf "{{dotfiles_dir}}/runcom/.zprofile" "$HOME/.zprofile"
    mkdir -p "$HOME/.claude/skills/golang-style"
    ln -sf "{{dotfiles_dir}}/runcom/.claude.json" "$HOME/.claude.json"
    ln -sf "{{dotfiles_dir}}/runcom/.claude/.gitignore" "$HOME/.claude/.gitignore"
    ln -sf "{{dotfiles_dir}}/runcom/.claude/settings.json" "$HOME/.claude/settings.json"
    ln -sf "{{dotfiles_dir}}/runcom/.claude/skills/golang-style/SKILL.md" "$HOME/.claude/skills/golang-style/SKILL.md"
    mkdir -p "$HOME/.hammerspoon"
    ln -sf "{{dotfiles_dir}}/runcom/.hammerspoon/init.lua" "$HOME/.hammerspoon/init.lua"

unlink-runcom:
    rm -f "$HOME/.bash_profile"
    rm -f "$HOME/.commitlintrc.yaml"
    rm -f "$HOME/.golangci.yaml"
    rm -f "$HOME/.inputrc"
    rm -f "$HOME/.zshrc"
    rm -f "$HOME/.zprofile"
    rm -f "$HOME/.claude.json"
    rm -f "$HOME/.claude/.gitignore"
    rm -f "$HOME/.claude/settings.json"
    rm -f "$HOME/.claude/skills/golang-style/SKILL.md"
    rm -f "$HOME/.hammerspoon/init.lua"

# --- config links ---

link-config: link-mise
    ln -sfn "{{dotfiles_dir}}/config/ghostty" "{{xdg_config_home}}/ghostty"
    ln -sfn "{{dotfiles_dir}}/config/git" "{{xdg_config_home}}/git"
    ln -sfn "{{dotfiles_dir}}/config/karabiner" "{{xdg_config_home}}/karabiner"
    ln -sfn "{{dotfiles_dir}}/config/tmux" "{{xdg_config_home}}/tmux"
    ln -sfn "{{dotfiles_dir}}/config/wezterm" "{{xdg_config_home}}/wezterm"
    ln -sfn "{{dotfiles_dir}}/config/zed" "{{xdg_config_home}}/zed"
    ln -sfn "{{dotfiles_dir}}/config/sheldon" "{{xdg_config_home}}/sheldon"
    mkdir -p "{{xdg_config_home}}/codex"
    ln -sf "{{dotfiles_dir}}/config/codex/config.toml" "{{xdg_config_home}}/codex/config.toml"
    mkdir -p "{{xdg_config_home}}/opencode"
    ln -sf "{{dotfiles_dir}}/config/opencode/opencode.jsonc" "{{xdg_config_home}}/opencode/opencode.jsonc"

unlink-config:
    rm -f "{{xdg_config_home}}/ghostty"
    rm -f "{{xdg_config_home}}/git"
    rm -f "{{xdg_config_home}}/karabiner"
    rm -f "{{xdg_config_home}}/tmux"
    rm -f "{{xdg_config_home}}/wezterm"
    rm -f "{{xdg_config_home}}/zed"
    rm -f "{{xdg_config_home}}/sheldon"
    rm -f "{{xdg_config_home}}/codex/config.toml"
    rm -f "{{xdg_config_home}}/opencode/opencode.jsonc"
    rm -f "{{xdg_config_home}}/mise/config.toml"

link-mise:
    mkdir -p "{{xdg_config_home}}/mise"
    ln -sf "{{dotfiles_dir}}/config/mise/config.toml" "{{xdg_config_home}}/mise/config.toml"

# --- package installation & setup ---

brew-packages: link-mise brew-update brew-basic brew-extra brew-cleanup mise-install nvim-setup hammerspoon-setup

brew-update:
    brew update
    brew upgrade

brew-cleanup:
    brew cleanup

brew-basic:
    #!/usr/bin/env bash
    set -euo pipefail
    brew bundle --file="{{dotfiles_dir}}/script/Brewfile.basic"
    BREW_PREFIX="$(brew --prefix)"
    ln -sf "${BREW_PREFIX}/bin/gsha256sum" "${BREW_PREFIX}/bin/sha256sum"
    if ! grep -qF "${BREW_PREFIX}/bin/zsh" /etc/shells; then
        echo "${BREW_PREFIX}/bin/zsh" | sudo tee -a /etc/shells
        chsh -s "${BREW_PREFIX}/bin/zsh"
    fi

brew-extra:
    brew bundle --file="{{dotfiles_dir}}/script/Brewfile.extra"

mise-install:
    mise install

nvim-setup: mise-install
    mise exec -- "{{dotfiles_dir}}/script/neovim.sh"

hammerspoon-setup:
    "{{dotfiles_dir}}/script/hammerspoon.sh"
