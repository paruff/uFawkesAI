---
change: seam-retire-loop
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 3311467
---
# Seam phase 3: retire the hand-built loop: plan

1. Delete the two artifact-chain scripts and their suite entry.
2. Shrink the five commands to pointers.
3. Replace gate prose in builder.md and planner.md.
4. Update docs/ai-sdlc/README.md.

## Verification Strategy

scripts/run-unit-tests.sh and pre-commit run --all-files pass.
