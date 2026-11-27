---
change: image-gate-fresh-snapshot
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Image gate: tell a stale lock from a real CVE: plan

1. Test first: `scripts/test-image-gate-decide.sh` with the five R3 cases plus pinned-pass; confirm it fails without the script (R3, R6).
2. Add `scripts/image-gate-decide.sh` and make the tests pass (R3).
3. Edit `build-cde-space-image.yml`: add the decision test to the self-test step; replace the Trivy gate step with pinned scan, conditional fresh build and scan, and the decide call; keep the report summary step (R1, R2, R4, R5).
4. Run the test script and the pre-commit hooks; dispatch the build workflow on the branch and read the log (R1, R5).

## Verification

- R3, R6: all cases pass; step 1 was red before step 2.
- R1, R5: the branch dispatch passes the gate step on the pinned image and skips the fresh build.
- R2, R4: reviewed in the diff (no push, sign or tag on the fresh image).
