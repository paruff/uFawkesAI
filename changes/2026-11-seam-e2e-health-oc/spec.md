---
change: seam-e2e-health-oc
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam e2e health check (OpenCode): spec

## Requirements

- R1. A one-line note is added at `docs/seam-health-opencode.md` through the full loop, built by OpenCode.
- R2. Commits are by the bot identity; approvals by a human.
- R3. `sdlc-seam status seam-e2e-health-oc --json` matches the Claude Code run apart from slug and SHAs.

## Verification

R1: the file exists after build. R2: `git log` authors. R3: the jq diff in the plan.
