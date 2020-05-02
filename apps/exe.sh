#!/usr/bin/env bash

RELATIVE_PATH=`dirname "$BASH_SOURCE"`

for file in "$RELATIVE_PATH"/{basic.sh,extra.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && bash "$file";
done;
unset file;

for file in "$RELATIVE_PATH"/{hammerspoon.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && bash "$file";
done;
unset file;

unset RELATIVE_PATH
