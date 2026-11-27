---
change: image-libzstd1-upgrade
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-27
approved_sha: 572c324
---
# Intent: Upgrade libzstd1 in the image (CVE-2026-124851)

## Problem

The image's Trivy gate fails on `libzstd1` (CVE-2026-124851, HIGH): the image carries `1.5.7+dfsg-1`, Debian's fix is `1.5.7+dfsg-1+deb13u1`. It is already in the apt snapshot (the 2026-11-27 snapshot has it), but the base image ships `libzstd1` and `apt-get install` upgrades it only when a package named in the list needs a newer version, so no snapshot bump ever clears it. Found by the live run of the stale-lock-aware gate (#390): both the pinned and the fresh-snapshot scans report it. Until it is fixed the Monday scheduled run and any tag dispatch fail, and the 3.0.0/3.1.0-style publish gap would repeat for the next release.

## Proposed outcome

The image upgrades `libzstd1` to the fixed version, so the gate passes on the pinned snapshot once it is at or past 2026-11-27 (the pinned snapshot is currently 2026-11-24; see Constraints).

## Affected users and systems

Anyone pulling the CDE Space image; `images/devsecops/Dockerfile` and the build workflow's gate.

## Constraints

Same pattern as `zlib1g` (CVE-2026-85091): name the package in the existing core-stage `apt-get install` so apt upgrades the base image's copy, with a comment saying when to drop it. The fixed version is not in the pinned snapshot `20261124T000000Z`, so naming the package alone installs nothing newer until the snapshot moves. This change therefore also needs the lock bump (`APT_SNAPSHOT` ≥ `20261127T000000Z`) to take effect; the weekly bump PR does that, or it is done in this change.

## How we know it worked

Trivy on the built image (the gate in `scan.sh`) reports no `libzstd1` finding, and a dispatch of the build workflow on the branch passes its gate step.

## Out of scope

Other packages; changing how base-image packages are upgraded in general (for example `apt-get upgrade`); the gate logic.

## Open questions

- Bump `APT_SNAPSHOT` in this change, or rely on the weekly bump PR? Recommendation: bump it here, one line, so the PR is self-sufficient and verifiable.
