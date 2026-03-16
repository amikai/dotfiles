DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
export PATH := $(DOTFILES_DIR)runcom/bin:$(PATH)
export PATH := /opt/homebrew/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config

SHELL = /bin/bash
ZSHELL = /bin/zsh

TARGETS = sudo brew bash git brew-packages
.PHONY: $(TARGETS)

all: sudo brew git bash zsh link brew-packages

sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

brew:
	[ -x "$$(command -v brew)" ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

LINK_TARGETS = link-bash-profile link-claude link-commitlintrc link-gemini \
	link-golangci link-hammerspoon link-inputrc link-zshrc link-bin \
	link-bash link-codex link-ghostty link-git link-karabiner \
	link-opencode link-tmux link-wezterm link-zed link-zsh link-iterm2-focus

UNLINK_TARGETS = $(LINK_TARGETS:link-%=unlink-%)

.PHONY: link unlink $(LINK_TARGETS) $(UNLINK_TARGETS)

link: $(LINK_TARGETS)
unlink: $(UNLINK_TARGETS)

# --- runcom: top-level files (directory symlinks where possible) ---

link-bash-profile:
	ln -sf $(DOTFILES_DIR)runcom/.bash_profile $(HOME)/.bash_profile

unlink-bash-profile:
	rm -f $(HOME)/.bash_profile

link-commitlintrc:
	ln -sf $(DOTFILES_DIR)runcom/.commitlintrc.yaml $(HOME)/.commitlintrc.yaml

unlink-commitlintrc:
	rm -f $(HOME)/.commitlintrc.yaml

link-golangci:
	ln -sf $(DOTFILES_DIR)runcom/.golangci.yaml $(HOME)/.golangci.yaml

unlink-golangci:
	rm -f $(HOME)/.golangci.yaml

link-inputrc:
	ln -sf $(DOTFILES_DIR)runcom/.inputrc $(HOME)/.inputrc

unlink-inputrc:
	rm -f $(HOME)/.inputrc

link-zshrc:
	ln -sf $(DOTFILES_DIR)runcom/.zshrc $(HOME)/.zshrc

unlink-zshrc:
	rm -f $(HOME)/.zshrc

link-bin:
	ln -sfn $(DOTFILES_DIR)runcom/bin $(HOME)/bin

unlink-bin:
	rm -f $(HOME)/bin

# --- runcom: file-level links (runtime dirs) ---

link-claude:
	mkdir -p $(HOME)/.claude/skills/golang-style
	ln -sf $(DOTFILES_DIR)runcom/.claude.json $(HOME)/.claude.json
	ln -sf $(DOTFILES_DIR)runcom/.claude/.gitignore $(HOME)/.claude/.gitignore
	ln -sf $(DOTFILES_DIR)runcom/.claude/settings.json $(HOME)/.claude/settings.json
	ln -sf $(DOTFILES_DIR)runcom/.claude/skills/golang-style/SKILL.md $(HOME)/.claude/skills/golang-style/SKILL.md

unlink-claude:
	rm -f $(HOME)/.claude.json
	rm -f $(HOME)/.claude/.gitignore
	rm -f $(HOME)/.claude/settings.json
	rm -f $(HOME)/.claude/skills/golang-style/SKILL.md

link-gemini:
	mkdir -p $(HOME)/.gemini
	ln -sf $(DOTFILES_DIR)runcom/.gemini/settings.json $(HOME)/.gemini/settings.json

unlink-gemini:
	rm -f $(HOME)/.gemini/settings.json

link-hammerspoon:
	mkdir -p $(HOME)/.hammerspoon
	ln -sf $(DOTFILES_DIR)runcom/.hammerspoon/init.lua $(HOME)/.hammerspoon/init.lua

unlink-hammerspoon:
	rm -f $(HOME)/.hammerspoon/init.lua

# --- config: directory symlinks ---

link-ghostty:
	ln -sfn $(DOTFILES_DIR)config/ghostty $(XDG_CONFIG_HOME)/ghostty

unlink-ghostty:
	rm -f $(XDG_CONFIG_HOME)/ghostty

link-git:
	ln -sfn $(DOTFILES_DIR)config/git $(XDG_CONFIG_HOME)/git

unlink-git:
	rm -f $(XDG_CONFIG_HOME)/git

link-karabiner:
	ln -sfn $(DOTFILES_DIR)config/karabiner $(XDG_CONFIG_HOME)/karabiner

unlink-karabiner:
	rm -f $(XDG_CONFIG_HOME)/karabiner

link-tmux:
	ln -sfn $(DOTFILES_DIR)config/tmux $(XDG_CONFIG_HOME)/tmux

unlink-tmux:
	rm -f $(XDG_CONFIG_HOME)/tmux

link-wezterm:
	ln -sfn $(DOTFILES_DIR)config/wezterm $(XDG_CONFIG_HOME)/wezterm

unlink-wezterm:
	rm -f $(XDG_CONFIG_HOME)/wezterm

link-zed:
	ln -sfn $(DOTFILES_DIR)config/zed $(XDG_CONFIG_HOME)/zed

unlink-zed:
	rm -f $(XDG_CONFIG_HOME)/zed

link-zsh:
	ln -sfn $(DOTFILES_DIR)config/zsh $(XDG_CONFIG_HOME)/zsh

unlink-zsh:
	rm -f $(XDG_CONFIG_HOME)/zsh

# --- config: file-level links (runtime dirs) ---

link-codex:
	mkdir -p $(XDG_CONFIG_HOME)/codex
	ln -sf $(DOTFILES_DIR)config/codex/config.toml $(XDG_CONFIG_HOME)/codex/config.toml

unlink-codex:
	rm -f $(XDG_CONFIG_HOME)/codex/config.toml

link-opencode:
	mkdir -p $(XDG_CONFIG_HOME)/opencode
	ln -sf $(DOTFILES_DIR)config/opencode/opencode.jsonc $(XDG_CONFIG_HOME)/opencode/opencode.jsonc

unlink-opencode:
	rm -f $(XDG_CONFIG_HOME)/opencode/opencode.jsonc

# --- iterm2_focus (requires sudo) ---

link-iterm2-focus:
	sudo mkdir -p /usr/local/bin
	sudo ln -sf $(DOTFILES_DIR)runcom/bin/iterm2_focus /usr/local/bin/iterm2_focus

unlink-iterm2-focus:
	sudo rm -f /usr/local/bin/iterm2_focus

bash: BASH=/opt/homebrew/bin/bash
bash: SHELLS=/private/etc/shells
bash: brew
	if ! grep -q $(BASH) $(SHELLS); then brew install bash bash-completion@2 pcre && sudo append $(BASH) $(SHELLS); fi

zsh: ZSH=/opt/homebrew/bin/zsh
zsh: SHELLS=/private/etc/shells
zsh: brew
	if ! grep -q $(ZSHELL) $(SHELLS); then brew install zsh pcre && sudo append $(ZSH) $(SHELLS) && chsh -s $(ZSH); fi

git: brew
	brew install git git-extras

brew-packages: brew
	$(MAKE) -C ./script
