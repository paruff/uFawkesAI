---
change: seam-e2e-health-oc
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: e5733e1
---
# Seam e2e health check (OpenCode): plan

1. Approve intent, spec and plan (human).
2. Run `opencode run` to add `docs/seam-health-opencode.md`; the bot commits.
3. Capture `status --json`, compare with the Claude Code output, attach to issue 359.

## Verification

- R1: `test -s docs/seam-health-opencode.md`.
- R2: `git log --format=%ae` shows the bot on build commits and the human on approve commits.
- R3: `jq 'del(.change,.artifactsDir,.gates[].commit)'` of both status outputs is identical.
