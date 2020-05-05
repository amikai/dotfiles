TARGETS = basic extra python golang nvim rust

.PHONY: $(TARGETS)
all: $(TARGETS)

pkg_install: basic extra
pkg_set: python golang nvim rust

basic:
	./basic.sh

extra:
	./extra.sh

python: pkg_install
	./python.sh

golang: pkg_install
	./golang.sh

nvim: pkg_install python
	./neovim.sh

rust:
	./rust.sh
