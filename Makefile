SHELL = /bin/bash
ZSHELL = /bin/zsh
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PATH := $(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)


TARGETS = sudo brew bash stow link unlink bash git brew-packages
.PHONY: $(TARGETS)

all: sudo brew git bash zsh link brew-packages

sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

brew:
	[ -x "$$(command -v brew)" ] || /bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

stow: brew
	[ -x "$$(command -v brew)" ] && [ -x "$$(command -v stow)" ] || brew install stow

link: stow
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) runcom
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config

bash: BASH=/usr/local/bin/bash
bash: SHELLS=/private/etc/shells
bash: brew
	if ! grep -q $(BASH) $(SHELLS); then brew install bash bash-completion@2 pcre && sudo append $(BASH) $(SHELLS); fi

zsh: ZSH=/usr/local/bin/zsh
zsh: SHELLS=/private/etc/shells
zsh: brew
	if ! grep -q $(ZSHELL) $(SHELLS); then brew install zsh pcre && sudo append $(ZSH) $(SHELLS) && chsh -s $(ZSH); fi

git: brew
	brew install git git-extras

brew-packages: brew
	$(MAKE) -C ./script
