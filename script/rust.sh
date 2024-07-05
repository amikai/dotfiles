#!/usr/bin/env bash

# Input 1 install default
DEFAULT_INSTALLATION=1
echo $DEFAULT_INSTALLATION | rustup-init

source $HOME/.cargo/env
CARGO="$(rustup which cargo)"

# Use stable version
rustup toolchain install stable && rustup default stable
rustup component add rust-analyzer clippy fmt
$CARGO install cargo-watch
