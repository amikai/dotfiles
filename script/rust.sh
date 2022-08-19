#!/usr/bin/env bash

# Input 1 install default
DEFAULT_INSTALLATION=1
echo $DEFAULT_INSTALLATION | rustup-init

source $HOME/.cargo/env

# Use nightly version
rustup toolchain install nightly && rustup default nightly
