DOTFILES_DIR ?= $(abspath $(dir $(lastword $(MAKEFILE_LIST)))/..)
export MISE_GLOBAL_CONFIG_FILE := $(DOTFILES_DIR)/config/mise/config.toml

TARGETS = basic extra mise nvim coding_agent hammerspoon

.PHONY: $(TARGETS) all pkg_install pkg_set brew_update brew_cleanup
all: $(TARGETS)

pkg_install: brew_update basic extra brew_cleanup
pkg_set: mise nvim

brew_update:
	brew update
	brew upgrade

brew_cleanup:
	brew cleanup

basic:
	brew bundle --file=Brewfile.basic
	$(eval BREW_PREFIX := $(shell brew --prefix))
	ln -sf "$(BREW_PREFIX)/bin/gsha256sum" "$(BREW_PREFIX)/bin/sha256sum"
	@if ! grep -qF "$(BREW_PREFIX)/bin/zsh" /etc/shells; then \
		echo "$(BREW_PREFIX)/bin/zsh" | sudo tee -a /etc/shells; \
		chsh -s "$(BREW_PREFIX)/bin/zsh"; \
	fi

extra:
	brew bundle --file=Brewfile.extra

mise: pkg_install
	mise install

nvim: mise
	mise exec -- ./neovim.sh

hammerspoon: pkg_install
	./hammerspoon.sh

coding_agent: pkg_install
	./coding_agent.sh
