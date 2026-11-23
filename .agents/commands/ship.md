---
description: Run pre-commit, fix issues, commit, push, and open a PR
agent: builder
---
Run `scripts/sdlc-seam next`, then load the skill for the stage it names (ship: `finishing-a-development-branch`). Run pre-commit and `/review-local` first, never ship from `main`, and open the PR with `gh pr create`.
