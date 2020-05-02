#!/usr/bin/env bash

RELATIVE_PATH=`dirname "$BASH_SOURCE"`

for file in "$RELATIVE_PATH"/{basic.sh,extra.sh}; do
	[ -r "$file" ] && echo "test" && [ -f "$file" ] && source "$file";
done;
unset file;

for file in "$RELATIVE_PATH"/{python.sh,golang.sh,neovim.sh}; do
	[ -r "$file" ] && echo "test" && [ -f "$file" ] && source "$file";
done;
unset file;

unset RELATIVE_PATH
