---
change: seam-superpowers-board-mirror
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:
issue: 356
created: 2026-11-23
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Seam phase 4: Superpowers and the board mirror

## Problem

Both harnesses lack a pinned Superpowers setup and a stage mapping, and Project #7 does not follow the approval commits (seam spec R7, R8; issues #357, #358).

## Proposed outcome

Superpowers pinned in OpenCode and documented for Claude Code, each agent file names its stage skills, and a workflow mirrors gate state onto the board.

## Affected users and systems

Agents and maintainers of this template; `opencode.json`, `.agents/agents/`, `.github/workflows/`.

## Constraints

Board writes only; no secrets in files; parity check stays green.

## How we know it worked

`scripts/test-board-mirror.sh` and `scripts/check-harness-parity.sh` pass in CI.

## Out of scope

Issue 359 (live end-to-end in both harnesses) needs a human at each gate.

## Open questions

- Which secret holds the project PAT (`BOARD_TOKEN` assumed)?
