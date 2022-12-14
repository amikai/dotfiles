TARGETS = basic extra python golang npm rust nvim

.PHONY: $(TARGETS)
all: $(TARGETS)

pkg_install: basic extra
pkg_set: python golang rust npm nvim

basic:
	./basic.sh

extra:
	./extra.sh

python: pkg_install
	./python.sh

golang: pkg_install
	./golang.sh

npm: pkg_instgall
	./npm.sh

nvim: pkg_install python rust npm
	./neovim.sh

rust:
	./rust.sh
