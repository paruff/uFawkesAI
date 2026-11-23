---
change: seam-board-mirror-merge
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:
issue: 380
created: 2026-11-23
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Board mirror: Done on merge

## Problem

R7 defines no state for merged work, so a merged change leaves its board item at Needs human / PR review until someone closes the issue.

## Proposed outcome

When a change PR merges into main, the mirror sets Status Done and clears Gate for the issue in intent.md, except goal issues.

## Affected users and systems

Maintainers; scripts/board-mirror.sh and .github/workflows/board-mirror.yml.

## Constraints

Board writes only; leaf issues only (title does not start with goal(); idempotent.

## How we know it worked

scripts/test-board-mirror.sh covers merged leaf and merged goal cases.

## Out of scope

Closing issues, and any state beyond Done.

## Open questions

None.
