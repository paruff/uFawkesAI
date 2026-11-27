---
change: image-gate-fresh-snapshot
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 11a0093
---
# Intent: Image gate: tell a stale lock from a real CVE

## Problem

The Trivy gate in `build-cde-space-image.yml` fails on any fixable CRITICAL/HIGH Debian finding, including fixes Debian published after the pinned `APT_SNAPSHOT`. The weekly Monday scheduled run has failed five weeks running (2026-10-26 to 11-23, e.g. 56 `libkrb5` findings on 11-23) and the 3.0.0 and 3.1.0 tag publishes failed the same way. The Sunday lock-bump PR already fixes these, but a human merges it days later (1, 2 and 8 days on the last three), so the gate cannot tell "the lock is a few days stale" from "a vulnerability we cannot fix". The Monday failure is no longer a signal, and a release can be blocked by merge timing, with a log that does not say so.

## Proposed outcome

When the gate fails on the pinned snapshot, the run rebuilds the image against today's snapshot and gates that:

- Scheduled and manual non-tag runs: pass with a warning when the fresh snapshot is clean (a bump is pending); fail when it is not (a real, unfixed finding).
- Tag publishes: still fail on the pinned image (what ships must be clean), but the failure says whether bumping the lock clears every finding and what to do (merge the lock-bump PR, then re-dispatch).

## Affected users and systems

Maintainers cutting releases and reading the Monday run; `.github/workflows/build-cde-space-image.yml`, a new `scripts/image-gate-decide.sh` and its test.

## Constraints

What is published is still built from the pinned Dockerfile and scanned clean; the fresh-snapshot build is diagnostic only and never published or tagged. No change to the Trivy policy (`scan.sh`, `.trivyignore`), the bump workflow, or the auto-merge rule (bump PRs stay human-merged).

## How we know it worked

A Monday run with only snapshot-lag findings is green with a "bump pending" warning; a tag dispatch with the same findings fails with the bump instruction; a finding that persists on the fresh snapshot fails both. The decision script has offline tests for each case.

## Out of scope

Auto-merging the bump PR; changing the bump cadence; a staleness SLA or issue filing; the 3.0.0 and 3.1.0 image gap.

## Open questions

None.
