---
change: image-gate-fresh-snapshot
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: fa1fa30
---
# Image gate: tell a stale lock from a real CVE: spec

## Requirements

- R1. On a gated run (`schedule` or `workflow_dispatch`), `verify` scans the pinned image as today. If it passes, nothing else changes.
- R2. If the pinned gate fails, `verify` rebuilds `ai` with `APT_SNAPSHOT` set to today (`YYYYMMDDT000000Z`) as a diagnostic image `fawkes-space-ai:fresh` and runs the same `scan.sh` gate on it. If today's snapshot is not published, the fresh result is "unavailable".
- R3. `scripts/image-gate-decide.sh <ref-kind> <pinned-rc> <fresh-rc|unavailable>` decides the outcome and prints one line for the log:
  - pinned 0: exit 0.
  - pinned fails, ref is not a tag, fresh 0: exit 0, with a `::warning::` that the lock is stale and a bump is pending.
  - pinned fails, ref is not a tag, fresh fails or unavailable: exit 1, "findings persist on the newest snapshot".
  - pinned fails, ref is a tag, fresh 0: exit 1, "stale lock: bumping to <date> clears all findings; merge the image-lock-bump PR (or run it), then re-dispatch this tag".
  - pinned fails, ref is a tag, fresh fails or unavailable: exit 1, "findings persist on the newest snapshot".
- R4. The fresh image is never pushed, signed or tagged; `publish` depends on `verify` as before and is unchanged.
- R5. PR and push runs are unchanged (report-only, no fresh build).
- R6. `scripts/test-image-gate-decide.sh` covers every row of R3 and runs in the `verify` job's self-test step.

## Design

`scan.sh` keeps its policy. The workflow step runs it with `GATE_EXIT=1` on gated runs, captures the exit code with `|| rc=$?` so the step can continue, and on failure runs `docker buildx bake ai --load --set "*.args.APT_SNAPSHOT=<today>"` with `TAG=fresh`, then `scan.sh` again. The final exit comes from `image-gate-decide.sh`, so the policy is testable without Docker. The build-arg override only affects the diagnostic build.

## Verification

- R3, R6: `bash scripts/test-image-gate-decide.sh`.
- R1, R2, R4, R5: workflow review plus a manual `workflow_dispatch` of the build on this branch (the pinned snapshot is current, so the gate path is a pass); the failing paths are exercised by the decision script test, and by dispatching with a deliberately old `APT_SNAPSHOT` if a live check is wanted.

## Areas of concern

- The fresh build adds a full image build and scan on the failing path only (extra run time on stale weeks).
- A green Monday with a warning can be ignored; the bump PR remains the control. A fresh scan that is clean says nothing about the tool and Python layers, which are the same in both builds.
- Snapshot publication lag: today's snapshot may not exist yet early in the UTC day, which yields "unavailable" and fails as before rather than passing unverified.
