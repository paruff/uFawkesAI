# Intent — Cold/Warm Start Benchmark for DevSecOps Images

Status: ACCEPTED (originator: repo owner, 2026-10-03)

## Problem

The DevSecOps images (core, ai, devcontainer) are used as the single source of truth for local pre-commit, devcontainer, and CI verification. However, there is no continuous measurement of their start latency:

- Cold start (docker pull + first run) latency is unknown and unmonitored
- Warm start (cached subsequent runs) latency is unknown and unmonitored
- Performance regressions in image size, layer composition, or tool initialization can go undetected
- Release notes lack quantitative startup performance data

## Desired Outcome

A benchmark that runs on every scheduled build and release tag to:

1. Measure cold start (pull + first `docker run`) and warm start (cached `docker run`) latency for all image variants on both architectures
2. Compare against a committed baseline to detect regressions > 10%
3. Publish results to workflow summary for inclusion in release notes
4. Fail the build on regression to prevent shipping slower images

## Decisions Already Made

- Benchmark runs in the `verify` job of `build-devsecops-images.yml`
- Runs on scheduled builds (Mondays) and `image-v*` tag releases only — skipped on regular PRs to avoid CI slowdown
- Threshold: 10% regression limit (configurable via `REGRESSION_THRESHOLD` env var)
- Baseline stored in `images/devsecops/benchmarks/baseline.json` and updated manually when intentional improvements are made
- Results published as markdown table to `$GITHUB_STEP_SUMMARY`

## Out of Scope

- Benchmarking application code startup (only the toolchain image itself)
- Continuous profiling or flame graphs
- Historical trend visualization beyond the workflow summary
