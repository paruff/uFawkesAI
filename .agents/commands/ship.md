---
description: Run pre-commit, fix issues, commit, push, and open a PR
agent: builder
---
Run pre-commit.
Fix auto-fixable issues (maximum 3 loops).
Run `/review-local` on the staged diff; a HIGH finding stops the ship until it is fixed.
Confirm branch is not `main`.
Stage only relevant files and exclude `.env`, credential files, and secrets.
Commit with a conventional commit message.
Push and open a PR with `gh pr create`, including summary and test plan.
