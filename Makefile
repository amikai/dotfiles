SHELL = /bin/bash
DOTFILES_DIR := $(dir $(realpath $(firstword $(MAKEFILE_LIST))))
PATH := $(DOTFILES_DIR)/bin:$(PATH)
export XDG_CONFIG_HOME := $(HOME)/.config
export STOW_DIR := $(DOTFILES_DIR)


TARGETS = sudo brew bash stow unkink bash git brew-packages
.PHONY: $(TARGETS)

all: sudo brew bash git 

sudo:
	sudo -v
	while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

brew:
	[ -x "$(command -v brew)" ] && (curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install | ruby)

macos:
	./macos

stow: brew
	brew install stow

link: stow brew-packages
	mkdir -p $(XDG_CONFIG_HOME)
	stow -t $(HOME) runcom
	stow -t $(XDG_CONFIG_HOME) config

unlink: stow
	stow --delete -t $(HOME) runcom
	stow --delete -t $(XDG_CONFIG_HOME) config

bash: BASH=/usr/local/bin/bash
bash: SHELLS=/private/etc/shells
bash: brew
	if ! grep -q $(BASH) $(SHELLS); then brew install bash bash-completion@2 pcre && sudo append $(BASH) $(SHELLS) && chsh -s $(BASH); fi

git: brew
	brew install git git-extras

brew-packages: brew
	$(MAKE) -C ./script
