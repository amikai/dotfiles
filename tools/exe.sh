#!/usr/bin/env bash

for file in ./{basic.sh,extra.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && bash "$file";
done;
unset file;

for file in ./{python.sh,golang.sh}; do
	[ -r "$file" ] && [ -f "$file" ] && bash "$file";
done;
unset file;
