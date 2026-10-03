# Specification (v2) — Cold/Warm Start Benchmark for DevSecOps Images

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 2

Revision 2 (2026-10-03): v1 ran before publish and pulled `<image>:<tag>-<arch>`
refs that are never published, and its cold start excluded the pull. It now
benchmarks the release just published, on every release (AC-AI-08).

## Requirements

**R1 — When.** A `benchmark` job in `build-devsecops-images.yml` runs after
`publish` on every release tag (`v*`; `image-v*` until v2.1.0). It doesn't run
on PRs, pushes or the weekly schedule: there is no new published image to
measure.

**R2 — What.** On a native runner per arch (amd64, arm64), for the published
version `V`:

| Key | Image ref |
|---|---|
| `core-<arch>` | `ghcr.io/paruff/fawkes-core:V` |
| `ai-<arch>` | `ghcr.io/paruff/fawkes-space-ai:V` |
| `devcontainer-<arch>` | `ghcr.io/paruff/fawkes-space:V` |
| `devcontainer-polyglot-<arch>` | `ghcr.io/paruff/fawkes-space:V-polyglot` |

**R3 — Cold start** = `docker pull` + first `docker run --rm --network none
<ref> true`, with the image removed locally first.

**R4 — Warm start** = median of `RUNS` (default 3) further runs.

**R5 — Baseline.** `images/devsecops/benchmarks/baseline.json`,
`{"<key>": {"cold_ms": int, "warm_ms": int}}`. A key with no baseline passes
and prints its numbers; a human records them (first: `v2.0.0-rc.1`).

**R6 — Gate.** The job fails if any key's cold or warm time regresses more
than `REGRESSION_THRESHOLD` (default 10%) over its baseline.

**R7 — Publication.** A markdown table per arch in the job summary (copied
into the release notes) and a `benchmark-<arch>.jsonl` artifact.

## Interface

`images/devsecops/tests/benchmark-start.sh <image-ref> <key>`: progress on
stderr, one JSON line on stdout (`key`, `image`, `cold_ms`, `warm_ms`,
`baseline_cold_ms`, `baseline_warm_ms`, `cold_regression_pct`,
`warm_regression_pct`, `pass`), exit 1 on regression or failed pull.

## Acceptance criteria

1. `images/devsecops/tests/test-benchmark-start.sh` passes: no baseline →
   pass; faster than baseline → pass; slower beyond threshold → fail.
2. On a release tag, the `benchmark` job reports 4 keys per arch (8 total).
3. A regression > 10% fails the job.

## Risks

- **Runner variability** (pull time depends on GHCR and network): median of
  warm runs; the threshold applies per key; a failing run can be re-run before
  re-baselining.
