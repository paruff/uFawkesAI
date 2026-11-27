---
change: agents-md-dangling-agents
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: f0b5e19
---
# AGENTS.md: stop naming agents the repo deletes: plan

1. Test first: extend `scripts/test-sdlc-block-drift.sh` with the restored-old-sentence case and an idempotence check on the fixup; confirm it fails with no fixup script (R1, R5).
2. Add `scripts/seam/agents-block-fixup.sh` (R1).
3. Call it from `scripts/seam/setup.sh` after `sdlc sync` and from `scripts/check-sdlc-block-drift.sh` on the synced copy (R2, R3).
4. Apply it to `AGENTS.md` and check that the diff is the one sentence (R4).
5. Run the drift self-test, the drift check, setup.sh in a throwaway copy, and the pre-commit hooks (R2, R3, R5).

## Verification

- R1, R5: the self-test's new cases pass; they failed in step 1.
- R2, R3, R4: drift check passes, setup.sh leaves `AGENTS.md` unchanged, the `AGENTS.md` diff is a single sentence.
