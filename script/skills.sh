#!/usr/bin/env bash
set -euo pipefail

# nubx is provided by nub, which is managed by mise.
# Ensure mise is installed and available in PATH.
if ! command -v mise >/dev/null 2>&1; then
    echo "Error: 'mise' is required to provide 'nubx' (via nub), but mise was not found in PATH." >&2
    exit 1
fi

eval "$(mise activate bash)"

# Install archify skill
# Note: The `skills` CLI identifies agy as `antigravity-cli` (and `antigravity` for the GUI app).
nubx -y skills add tt-a1i/archify \
    --global \
    --yes \
    --agent pi claude-code codex grok antigravity antigravity-cli

# Install Matt Pocock skills (exclude claude-code because Claude Code manages Matt's skills via plugins)
nubx -y skills add mattpocock/skills \
    --global \
    --yes \
    --agent pi codex grok antigravity antigravity-cli

# Install personal skills
nubx -y skills add amikai/skills \
    --global \
    --yes \
    --agent pi claude-code codex grok antigravity antigravity-cli
