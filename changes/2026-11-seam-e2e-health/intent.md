---
change: seam-e2e-health
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:
issue: 359
created: 2026-11-23
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 4846ee4
---
# Intent: Seam e2e health check (Claude Code)

## Problem

Issue 359 needs one change completed intent to ship in Claude Code, to compare its gate verdicts with the OpenCode run.

## Proposed outcome

A one-line health note added through the loop, built in Claude Code, committed by the bot, approved by a human.

## Affected users and systems

Maintainers; the seam gates and the Claude Code hooks.

## Constraints

Bot identity commits, human approvals.

## How we know it worked

status --json matches the OpenCode run apart from slug and SHAs.

## Out of scope

Anything beyond a one-line note.

## Open questions

- None.
