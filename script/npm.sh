#!/usr/bin/env bash

NVM_PREFIX="$(brew --prefix nvm)"

. "${NVM_PREFIX}/nvm.sh"

nvm install stable
nvm use stable
