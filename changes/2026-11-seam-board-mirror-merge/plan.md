---
change: seam-board-mirror-merge
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: 70d7665
---
# Board mirror: Done on merge: plan

1. RED: add merged-leaf, merged-goal and idempotence cases to `scripts/test-board-mirror.sh`.
2. GREEN: add `--merged` and the goal-title check to `scripts/board-mirror.sh`.
3. Workflow: run on merged PRs, pass `--merged`.

## Verification

- R1: merged-leaf case gives Done with no Gate.
- R2: merged-goal case makes no edit.
- R3: the `closed` condition in `.github/workflows/board-mirror.yml` requires `github.event.pull_request.merged`.
- R4: second-run case makes no edits.
