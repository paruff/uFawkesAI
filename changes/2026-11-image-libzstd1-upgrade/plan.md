---
change: image-libzstd1-upgrade
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Upgrade libzstd1 in the image (CVE-2026-124851): plan

1. Probe the 2026-11-27 snapshot (both `InRelease` URLs) (R2).
2. Edit `images/devsecops/Dockerfile`: add `libzstd1` and its comment to the core-stage install, set `APT_SNAPSHOT=20261127T000000Z` (R1, R2).
3. Run the pre-commit hooks (hadolint, shfmt etc.) (R4).
4. Push, open the PR, dispatch the build workflow on the branch and read the gate step: the run must pass with no `libzstd1` finding (R3, R4).

## Verification

- R3: the branch dispatch's Trivy gate passes; the run before this change failed on `libzstd1` (run 45974255378).
- R4: verify-tools and the determinism rebuild pass in the same run.
