---
change: image-libzstd1-upgrade
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Upgrade libzstd1 in the image (CVE-2026-124851): spec

## Requirements

- R1. `libzstd1` is named in the core-stage `apt-get install` list in `images/devsecops/Dockerfile`, with a comment citing CVE-2026-124851 and when to drop it (once the base digest carries `1.5.7+dfsg-1+deb13u1`).
- R2. `ARG APT_SNAPSHOT` is `20261127T000000Z` or later, so the fixed package is available. The snapshot is probed first (both archives' `InRelease`, as `image-lock-bump.sh` does).
- R3. The built image has `libzstd1` at `1.5.7+dfsg-1+deb13u1` or newer, and the `scan.sh` gate reports no finding for it.
- R4. Nothing else in the image changes: same packages, tools, locks and base digest. `verify-tools.sh` still passes.

## Design

Add `libzstd1` next to `zlib1g` in the same `RUN`, mirror the existing comment, and move the snapshot date. No new stage, script or workflow change.

## Verification

- R1, R2: diff review; both `InRelease` URLs for the new date return 200.
- R3, R4: `workflow_dispatch` of `build-cde-space-image.yml` on the branch (verify offline, then the Trivy gate, which fails the run on a `libzstd1` finding) and the build's verify step.

## Areas of concern

- Moving the snapshot to 2026-11-27 pulls every Debian update published since 2026-11-24, not only `libzstd1`. They are the same updates the next weekly bump would take, but they ride in this PR; the Trivy report and `verify-tools.sh` show whether any changes behaviour.
- The comment is the only reminder to drop the pin; a stale pin is harmless (apt keeps the newer version).
