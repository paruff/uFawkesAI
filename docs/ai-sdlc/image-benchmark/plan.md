# Plan (v1) — Cold/Warm Start Benchmark for DevSecOps Images

Status: DRAFT — for human review. Implements `spec.md` (approved 2026-10-03).

## Implementation notes

This PR implements the cold/warm start benchmark as a single cohesive change:

1. **New benchmark script**: `images/devsecops/tests/benchmark-start.sh`
   - Measures cold start (docker pull + first run) and warm start (cached subsequent runs)
   - Tests all variants: core, ai, devcontainer, devcontainer-polyglot
   - Tests both architectures: amd64, arm64
   - Outputs JSON for aggregation and markdown for release notes

2. **Baseline file**: `images/devsecops/benchmarks/baseline.json`
   - Initial baseline values for all 8 variant/arch combinations
   - Updated manually when intentional performance improvements are made

3. **Workflow integration**: `.github/workflows/build-devsecops-images.yml`
   - Runs in verify job on scheduled builds (Mondays) and image-v* tag releases
   - Skips on regular PR/push to avoid slowing down CI
   - Fails if any variant/arch regresses > 10% vs baseline
   - Publishes markdown table to workflow summary for release notes

## Verification Strategy

### Acceptance Criteria

| AC    | How it is proven                                                    | test_type   | Command / CI job                          |
| ----- | ------------------------------------------------------------------- | ----------- | ----------------------------------------- |
| AC-01 | Benchmark script runs standalone for a single variant/arch          | unit        | `images/devsecops/tests/benchmark-start.sh fawkes-space-ai ci ai amd64` |
| AC-02 | Benchmark script outputs valid JSON with all required fields        | unit        | Script output parsed by `jq` without errors |
| AC-03 | Workflow runs benchmark on scheduled trigger (not on PR)            | integration | `build-devsecops-images.yml` › `verify` job on schedule |
| AC-04 | Workflow runs benchmark on image-v* tag push                        | integration | `build-devsecops-images.yml` › `verify` job on tag |
| AC-05 | Workflow skips benchmark on regular PR/push to main                 | integration | `build-devsecops-images.yml` › `verify` job on PR |
| AC-06 | Workflow fails when regression > 10% for any variant/arch           | integration | Modify baseline to be lower, run scheduled workflow |
| AC-07 | Workflow summary contains markdown table with all 8 variant/arch rows | integration | Check `$GITHUB_STEP_SUMMARY` in verify job |
| AC-08 | All 8 variant/arch combinations are tested                          | integration | Count rows in summary table = 8 |

### Verification Commands

```bash
# Standalone script test (requires Docker and built images)
cd /Users/philruff/projects/github/paruff/uFawkesAI
REGISTRY=ghcr.io/paruff BASELINE_FILE=images/devsecops/benchmarks/baseline.json \
  REGRESSION_THRESHOLD=10 RUNS=3 \
  images/devsecops/tests/benchmark-start.sh fawkes-space-ai ci ai amd64

# Verify JSON output structure
images/devsecops/tests/benchmark-start.sh fawkes-space-ai ci ai amd64 | jq '.'

# Run full benchmark suite locally (requires all images built)
for variant in core ai devcontainer; do
  for arch in amd64 arm64; do
    if [[ "$variant" == "core" ]]; then IMAGE="fawkes-space-core"; fi
    if [[ "$variant" == "ai" ]]; then IMAGE="fawkes-space-ai"; fi
    if [[ "$variant" == "devcontainer" ]]; then IMAGE="fawkes-space-devcontainer"; fi
    REGISTRY=ghcr.io/paruff BASELINE_FILE=images/devsecops/benchmarks/baseline.json \
      images/devsecops/tests/benchmark-start.sh "$IMAGE" ci "$variant" "$arch"
  done
done

# Test polyglot variants
for arch in amd64 arm64; do
  REGISTRY=ghcr.io/paruff BASELINE_FILE=images/devsecops/benchmarks/baseline.json \
    images/devsecops/tests/benchmark-start.sh "fawkes-space-ai" ci "devcontainer-polyglot" "$arch"
done
```

### CI Verification

The feature is verified by the `build-devsecops-images.yml` workflow:

1. **On scheduled run (Mondays):** The `verify` job runs the benchmark step, which:
   - Iterates all 8 variant/arch combinations
   - Runs `benchmark-start.sh` for each
   - Aggregates JSON output to markdown table in `$GITHUB_STEP_SUMMARY`
   - Exits with code 1 if any regression > 10%

2. **On image-v* tag:** Same as scheduled run, runs before publish

3. **On PR/push:** Benchmark step is skipped (condition `env.SCHEDULED == 'true' || startsWith(github.ref, 'refs/tags/image-v')`)

## PR sequence

This feature ships as a single PR (#164):

- `images/devsecops/tests/benchmark-start.sh` (new)
- `images/devsecops/benchmarks/baseline.json` (new)
- `.github/workflows/build-devsecops-images.yml` (modified: adds benchmark step)

## Acceptance mapping

| Spec criterion                          | Proven in |
| --------------------------------------- | --------- |
| R1 — Benchmark execution on schedule/tag | AC-03, AC-04 |
| R2 — All variants/archs tested          | AC-08 |
| R3 — Cold start measurement             | AC-01 |
| R4 — Warm start measurement             | AC-01 |
| R5 — Baseline comparison                | AC-02 |
| R6 — Regression gate                    | AC-06 |
| R7 — Results publication                | AC-07 |
| R8 — Determinism                        | AC-02 |

## Risks

- **CI runner variability:** GitHub-hosted runners have variable performance. Mitigation: run 3 warm runs and use median; threshold at 10% absorbs normal variance.
- **Docker layer caching:** GitHub Actions cache may affect cold start. Mitigation: benchmark runs in the same job as the build, so layers are fresh; cold start includes explicit pull.
- **Baseline drift:** Baseline must be updated when intentional improvements are made. Mitigation: documented in PR template; baseline update is a deliberate human action.
