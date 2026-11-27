---
change: agents-md-dangling-agents
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# AGENTS.md: stop naming agents the repo deletes: spec

## Requirements

- R1. `scripts/seam/agents-block-fixup.sh <file>` rewrites, inside the `ai-sdlc` block of `<file>`, the sentence ``For clean-context reviews (verifier, spec-reviewer, simplifier, researcher), use `.agents/agents/<name>.md`.`` to ``For a clean-context review, use `.agents/agents/verifier.md`.``. It is idempotent and changes nothing when the sentence is absent or already rewritten.
- R2. `scripts/seam/setup.sh` runs the fixup on `AGENTS.md` right after `sdlc sync`, before it compares the block with the committed copy, so a sync leaves `AGENTS.md` unchanged.
- R3. `scripts/check-sdlc-block-drift.sh` runs the same fixup on the freshly synced copy before diffing, so the expected block equals the committed one; every other difference inside the block still fails and is named.
- R4. `AGENTS.md` carries the rewritten sentence and nothing else changes in it.
- R5. `scripts/test-sdlc-block-drift.sh` still passes (clean passes, outside edit passes, inside edit fails) and gains a case: the old sentence restored in `AGENTS.md` fails the drift check, and the fixup is idempotent.

## Design

One small script holds the rewrite (a single `sed` on the one line, keyed on the exact engine text), called from the two places that compare against engine output. The rewrite lives in one file so the two callers cannot disagree. If a future engine version changes the sentence, the fixup no longer matches, the drift check fails loudly with the engine's new text, and the fixup is updated or dropped.

## Verification

- R1, R5: `bash scripts/test-sdlc-block-drift.sh` (new cases red before the script exists).
- R2, R3, R4: `bash scripts/check-sdlc-block-drift.sh` passes on the new `AGENTS.md`; `git diff` of `AGENTS.md` is that one sentence; `scripts/seam/setup.sh` run in a throwaway copy leaves `AGENTS.md` unchanged.

## Areas of concern

- `AGENTS.md` is owner-approval-only and loaded by every harness; the PR carries a one-line diff to it for the owner to approve.
- A hard-coded text match is brittle by design: it fails loudly on an engine upgrade rather than silently drifting.
- `CLAUDE.md`, `.cursorrules` and the Copilot/Cursor files are symlinks to the same file, so they change with it.
