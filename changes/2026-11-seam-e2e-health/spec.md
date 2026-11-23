---
change: seam-e2e-health
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam e2e health check (Claude Code): spec

## Requirements

- R1. A one-line health note is added at `docs/seam-health.md` through the full loop (intent, spec, plan, build, ship).
- R2. Commits are made by the bot identity. Approvals are made by a human.
- R3. `sdlc-seam status seam-e2e-health --json` after each gate matches the OpenCode run, apart from slug and SHAs.

## Verification

`scripts/sdlc-seam gate seam-e2e-health plan` exits 0 after approval; both `status --json` outputs are attached to issue 359.
