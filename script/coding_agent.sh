#!/usr/bin/env bash

# install superpowers for codex and opencode under ~/.agent folder
# claude-code use superpowers by plugin
bunx skills add https://github.com/obra/superpowers --global --yes \
    --agent opencode codex gemini-cli
