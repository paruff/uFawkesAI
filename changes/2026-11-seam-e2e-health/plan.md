---
change: seam-e2e-health
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 55969e7
---
# Seam e2e health check (Claude Code): plan

1. Approve intent, spec and plan (human).
2. Add `docs/seam-health.md` with one line; commit as the bot.
3. Run `scripts/sdlc-seam ci --base origin/main`; open the PR.
4. Save `status --json` and repeat the same change type in OpenCode.

## Verification

- R1: `test -s docs/seam-health.md` after the build step.
- R2: `git log --format=%ae` shows the bot on build commits and the human on `approve` commits.
- R3: `scripts/sdlc-seam status seam-e2e-health --json` saved from both harnesses and compared with `jq 'del(.change,.artifactsDir,.gates[].commit)'`.
