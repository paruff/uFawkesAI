---
change: opencode-v2-plugin
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-23
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: e838fdf
---
# Intent: OpenCode 2.x gate plugin

## Problem

On OpenCode 2.x the gate plugin never loads, so a session can commit and push with an unapproved plan, and the secret-scan and protected-path hooks are off too (#371).

## Proposed outcome

The plugin loads on OpenCode 2.x and blocks `git commit` and `git push` with the same script as before; 1.x keeps working.

## Affected users and systems

Anyone running OpenCode 2.x on this template; `.opencode/plugins/ai-sdlc-hooks.ts`.

## Constraints

No gate logic in the plugin: it calls `scripts/hooks/seam-gate.sh`. Spec R6.3 of `docs/ai-sdlc/sdlc-engine-seam/spec.md`.

## How we know it worked

`bash scripts/test-opencode-live.sh`: a real `opencode run` is refused a commit while the plan is unapproved.

## Out of scope

Pinning OpenCode in the image; porting the other plugin (`shift-left.js`).

## Open questions

- Which OpenCode version does the fawkes-space image pin?
