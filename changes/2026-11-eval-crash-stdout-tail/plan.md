---
change: eval-crash-stdout-tail
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: dc75cf3
---
# Evals: show the agent's stdout tail on a silent crash: plan

1. Test first: add cases to `scripts/test-run-evals.sh` for R1, R2 and R3 (stdout tail on empty stderr, the no-output line, stderr-only when stderr has content); confirm R1 and R2 fail (R5).
2. Extend the block in `scripts/run-evals.sh` (R1, R2, R3).
3. Run `bash scripts/test-run-evals.sh`, shellcheck and shfmt in Docker, and the pre-commit hooks (R4).
4. Push, open the PR and read the Agent Config Evals run.

## Verification

- R1, R2, R5: the new cases pass; the R1 and R2 cases failed in step 1.
- R3, R4: the existing cases pass unchanged; the stderr-present case prints no stdout.
