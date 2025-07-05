TARGETS = basic extra golang npm rust nvim

.PHONY: $(TARGETS)
all: $(TARGETS)

pkg_install: basic extra
pkg_set: golang rust npm nvim

basic:
	./basic.sh

extra:
	./extra.sh

golang: pkg_install
	./golang.sh

npm: pkg_install
	./npm.sh

nvim: pkg_install rust npm
	./neovim.sh

rust:
	./rust.sh
