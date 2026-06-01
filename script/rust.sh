#!/usr/bin/env bash

export PATH="$(brew --prefix rustup)/bin:$PATH"
CARGO="$(rustup which cargo)"

# Use stable version
rustup toolchain install stable && rustup default stable
rustup component add rust-analyzer clippy
$CARGO install cargo-watch
