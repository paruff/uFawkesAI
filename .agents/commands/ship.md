---
description: Run pre-commit, fix issues, commit, push, and open a PR
agent: builder
---
Run `scripts/sdlc-seam next`, then load the skill for the stage it names (ship: `finishing-a-development-branch`). Run pre-commit (at most 3 fix loops) and `/review-local` first, never ship from `main`, stage only relevant files (no `.env` or credentials), commit with a conventional message, and open the PR with `gh pr create` including summary and test plan.
