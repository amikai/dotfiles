TARGETS = basic extra python golang nvim

.PHONY: $(TARGETS)
all: $(TARGETS)

pkg_install: basic extra
pkg_set: python golang nvim

basic:
	./basic.sh

extra:
	./extra.sh

python: pkg_install
	./python.sh

golang: pkg_install
	./golang.sh

nvim: pkg_install python
	pip2 install pynvim neovim
	pip3 install pynvim neovim
	./neovim.sh
