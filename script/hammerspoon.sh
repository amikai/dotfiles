#!/usr/bin/env bash
set -euo pipefail

mkdir -p ~/.hammerspoon/Spoons/

curl -fL https://github.com/Hammerspoon/Spoons/raw/master/Spoons/SpoonInstall.spoon.zip | bsdtar -xf - -C ~/.hammerspoon/Spoons/
