TARGETS = basic extra golang npm rust nvim coding_agent hammerspoon

.PHONY: $(TARGETS) all pkg_install pkg_set brew_update brew_cleanup
all: $(TARGETS)

pkg_install: brew_update basic extra brew_cleanup
pkg_set: golang rust npm nvim

brew_update:
	brew update
	brew upgrade

brew_cleanup:
	brew cleanup

basic:
	brew bundle --no-lock --file=Brewfile.basic
	$(eval BREW_PREFIX := $(shell brew --prefix))
	ln -sf "$(BREW_PREFIX)/bin/gsha256sum" "$(BREW_PREFIX)/bin/sha256sum"
	@if ! grep -qF "$(BREW_PREFIX)/bin/zsh" /etc/shells; then \
		echo "$(BREW_PREFIX)/bin/zsh" | sudo tee -a /etc/shells; \
		chsh -s "$(BREW_PREFIX)/bin/zsh"; \
	fi

extra:
	brew bundle --no-lock --file=Brewfile.extra

golang: pkg_install
	./golang.sh

npm: pkg_install
	./npm.sh

nvim: pkg_install rust npm
	./neovim.sh

rust: pkg_install
	./rust.sh

hammerspoon: pkg_install
	./hammerspoon.sh

coding_agent: pkg_install
	./coding_agent.sh
