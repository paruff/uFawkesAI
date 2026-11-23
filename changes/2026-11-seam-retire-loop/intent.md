---
change: seam-retire-loop
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-23
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 1a07c2a
---
# Intent: Seam phase 3: retire the hand-built loop

## Problem

The hand-built loop (artifact-chain scripts, loop prose in commands and agent files) duplicates the engine behind `sdlc-seam`.

## Proposed outcome

No hand-written loop script, command or gate prose duplicates the engine; everything calls `sdlc-seam`.

## Affected users and systems

<People, teams, services, APIs.>

## Constraints

<Security, data, compliance, timelines, technology.>

## How we know it worked

All checks pass with the old scripts removed.

## Out of scope

<What is explicitly not being done.>

## Open questions

- <question>
