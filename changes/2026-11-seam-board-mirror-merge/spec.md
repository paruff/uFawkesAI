---
change: seam-board-mirror-merge
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Board mirror: Done on merge: spec

## Requirements

- R1. `board-mirror.sh <status.json> <issue> --merged` sets Status Done and clears Gate.
- R2. If the issue title starts with `goal(`, `--merged` makes no edit and exits 0.
- R3. The workflow runs on `pull_request: closed` when the PR was merged, from the PR head branch.
- R4. A second run makes no edits.

## Verification

- R1, R2, R4: `scripts/test-board-mirror.sh` new cases.
- R3: workflow YAML review and a live merged PR.
