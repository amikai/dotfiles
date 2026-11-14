#!/usr/bin/env bash
set -euo pipefail

# Run it through `mise run agents`, whose `mise exec` puts nub's nubx on PATH.

# Install Cloudflare security-audit skill
# Note: The `skills` CLI identifies agy as `antigravity-cli` (and `antigravity` for the GUI app).
nubx -y skills add cloudflare/security-audit-skill \
    --skill security-audit \
    --global \
    --yes \
    --agent pi claude-code codex grok antigravity antigravity-cli

# Install Matt Pocock skills (exclude claude-code because Claude Code manages Matt's skills via plugins)
nubx -y skills add mattpocock/skills \
    --global \
    --yes \
    --agent pi codex grok antigravity antigravity-cli

# Install herdr skill (Claude Code only).
# We normally run Claude as the orchestrator/planner that drives the other
# agents through herdr, so only claude-code needs the herdr skill.
nubx -y skills add herdrdev/herdr \
    --skill herdr \
    --global \
    --yes \
    --agent claude-code

# Install herdr plugins and integrations.
# herdr is installed by `mise bootstrap packages apply`, earlier in `mise run setup`.
herdr plugin install -y kryptamine/herdr-auto-title
herdr integration install claude
