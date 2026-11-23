---
change: seam-superpowers-board-mirror
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam phase 4: Superpowers and the board mirror: spec

Requirements are R7 (board mirror) and R8 (Superpowers in both harnesses) of
[docs/ai-sdlc/sdlc-engine-seam/spec.md](../../docs/ai-sdlc/sdlc-engine-seam/spec.md). The change adds:

- `opencode.json` `plugin`: Superpowers pinned to tag `v7.0.0`; `check-harness-parity.sh` fails if unpinned.
- Stage → skill mapping (R8.3) and R8.4 in the planner, builder and verifier agent files; install notes in `SETUP.md`.
- `scripts/board-mirror.sh`, its test, and `.github/workflows/board-mirror.yml` (R7), keyed on `issue:` in `intent.md`.
