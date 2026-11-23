---
change: seam-e2e-health-oc
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:
issue: 359
created: 2026-11-23
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Seam e2e health check (OpenCode)

## Problem

Issue 359 needs the same change type completed in OpenCode, to compare gate verdicts with the Claude Code run.

## Proposed outcome

A one-line health note added through the loop with OpenCode building and the bot committing.

## Affected users and systems

Maintainers; the seam gates and the OpenCode plugin.

## Constraints

Bot identity commits, human approvals.

## How we know it worked

status --json matches the Claude Code run apart from slug and SHAs.

## Out of scope

Anything beyond a one-line note.

## Open questions

- None.
