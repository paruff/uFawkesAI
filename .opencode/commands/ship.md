---
description: Run pre-commit, fix issues, commit, push, and open a PR
agent: builder
---
Run pre-commit.
Fix auto-fixable issues (maximum 3 loops).
Confirm branch is not `main`.
Stage only relevant files and exclude `.env`, credential files, and secrets.
Commit with a conventional commit message.
Push and open a PR with `gh pr create`, including summary and test plan.
