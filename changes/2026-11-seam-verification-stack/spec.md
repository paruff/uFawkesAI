---
change: seam-verification-stack
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam verification stack (R9): spec

## Requirements

- R1. The SAST job in `agent-ci.yml` runs Semgrep with `p/ci`, `p/typescript` and `p/secrets` and exits non-zero on a finding.
- R2. `ci-quality.yml` has a `seam-mutation` job that runs Stryker's command runner (`scripts/test-sdlc-seam.sh`) over `scripts/seam/**/*.ts` and fails under `thresholds.break`.
- R3. `thresholds.break` is the first full run's score minus 5, recorded in `plan.md`.
- R4. `verifier.md` lists the checklist in order: verification-before-completion, requesting-code-review plus `/code-review`, CI green, then hand-off. `REVIEW.md` flags "done" without command output.
- R5. An eval task shows the verifier blocks a builder claim with no command output.
- R6. `AI_STANCE.md` names Semgrep and Stryker and matches what CI runs.

## Verification

- R1, R2: both jobs run on this PR; actionlint passes.
- R3: first full run scored 50.73 percent, so break is 45.
- R4, R6: `pre-commit run --all-files`, `scripts/check-ai-stance.sh`.
- R5: `scripts/run-evals.sh` on the task passes.
