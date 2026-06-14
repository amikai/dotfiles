#!/usr/bin/env bash

fnm install --lts && fnm default lts-latest

# install delance lsp for nvim
fnm exec --using=default npm install -g @delance/runtime
