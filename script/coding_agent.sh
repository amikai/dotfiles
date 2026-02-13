#!/usr/bin/env bash

# install superpowers for codex and opencode
bunx skills add https://github.com/obra/superpowers --global \
    --agent opencode codex --yes \
    --skill brainstorming dispatching-parallel-agents executing-plans finishing-a-development-branch \
    receiving-code-review requesting-code-review subagent-driven-development systematic-debugging test-driven-development \
    using-git-worktrees using-superpowers verification-before-completion writing-plans writing-skills
