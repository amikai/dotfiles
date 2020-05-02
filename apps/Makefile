TARGETS = basic extra hammerspoon

.PHONY: $(TARGETS)
all: $(TARGETS)

pkg_install: basic extra
pkg_set: hammerspoon

basic:
	./basic.sh

extra:
	./extra.sh

hammerspoon: pkg_install
	./hammerspoon.sh
