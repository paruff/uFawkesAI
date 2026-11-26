---
change: run-evals-stderr
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-26
approved_sha: 66cf376
---
# Print the agent's stderr when an eval task fails: plan

Already implemented on this branch; this plan records it for approval.

1. Test first: add `STUB_STDERR` to the stub agent and four cases (stderr shown on a non-zero exit, absent on a passing run); confirm the R1 case fails (R1, R2, R4).
2. Add the block to `scripts/run-evals.sh` (R1, R2, R3).
3. Run `scripts/test-run-evals.sh` and the pre-commit hooks.

## Verification

- R1, R2, R4: 31 cases pass; R1 was red before step 2.
- R3: existing cases unchanged.
