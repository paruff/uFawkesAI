---
change: run-evals-model-default
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Align eval model references: plan

1. Edit the `opencode` default and header comment in `scripts/run-evals.sh` (R1).
2. Update `.agents/evals/baseline.json`: model, task count, note (R2).
3. Run `bash scripts/test-run-evals.sh` and the pre-commit hooks (R3).

## Verification

- R1, R2: `git grep gemini-3.1-flash-lite` is empty outside history.
- R3: all 31 cases pass; Agent Config Evals green on the PR.
