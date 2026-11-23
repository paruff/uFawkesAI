---
change: seam-e2e-health
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Seam e2e health check (Claude Code): plan

1. Approve intent, spec and plan (human).
2. Add `docs/seam-health.md` with one line; commit as the bot.
3. Run `scripts/sdlc-seam ci --base origin/main`; open the PR.
4. Save `status --json` and repeat the same change type in OpenCode.
