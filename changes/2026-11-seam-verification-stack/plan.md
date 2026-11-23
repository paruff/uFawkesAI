---
change: seam-verification-stack
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam verification stack (R9): plan

Already implemented on this branch in two commits (29e15a5, cd6ae8f); this plan records them for approval.

1. Semgrep: add `p/typescript` and `p/secrets` to the SAST job; make `check-ai-stance.sh` find a SAST job by content; update `AI_STANCE.md` (R1, R6).
2. Stryker: pin `@stryker-mutator/core` 10.1.1, add `stryker.config.json` (break 45) and the `seam-mutation` job (R2, R3).
3. Verifier: checklist in `verifier.md`, line in `REVIEW.md`, eval task `verifier-blocks-unproven` (R4, R5).
4. Record the Semgrep and Stryker decisions in the seam plan's Tradeoffs table.

## Verification

- R1, R2: CI on this PR.
- R3: full run 50.73 percent, break 45.
- R4, R6: pre-commit green.
- R5: eval passes.
