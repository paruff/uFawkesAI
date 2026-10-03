# Plan (v2) — Cold/Warm Start Benchmark for DevSecOps Images

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 2

## Changes (revision 2, ships with the v2.0.0 publish-path fix, #111)

1. `benchmark-start.sh` takes a full image ref and a key; cold start includes
   the pull; warm is a median; a portable millisecond timer (Perl).
2. `test-benchmark-start.sh`: stub-docker self-test, run first in the job.
3. The benchmark moves from the `verify` job to a `benchmark` job after
   `publish`, on release tags only, logged in to GHCR.
4. `baseline.json` is emptied: v1's values were placeholders, not
   measurements. `v2.0.0-rc.1` records the first real baseline.

## Verification Strategy

| AC | How it is proven | Command / CI job |
|---|---|---|
| 1 | Self-test | `bash images/devsecops/tests/test-benchmark-start.sh` |
| 2 | Release run | `benchmark` job summary on `v2.0.0-rc.1` shows 8 rows |
| 3 | Gate | Self-test case 3 (regression fails); on CI, a baseline set below the measured values fails the job |

Lint: `actionlint .github/workflows/build-devsecops-images.yml`,
`shellcheck images/devsecops/tests/*.sh`.

## Risks

- First rc.1 run has no baseline, so it can't fail on regression: by design;
  record the numbers in the same PR that bumps to `v2.0.0`.
