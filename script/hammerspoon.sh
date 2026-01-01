#!/usr/bin/env bash

mkdir -p ~/.hammerspoon/Spoons/

curl -L https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip | bsdtar -xf - -C ~/.hammerspoon/Spoons/
