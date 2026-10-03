# Specification (v1) — Cold/Warm Start Benchmark for DevSecOps Images

Status: DRAFT — for human review. Derived from `intent.md`; `plan.md` follows.

## Requirements

**R1 — Benchmark execution.** The benchmark runs inside the `verify` job of `build-devsecops-images.yml` on:
- Scheduled workflow runs (Mondays, cron: `17 6 * * 1`)
- Manual workflow dispatch
- Tag pushes matching `image-v*`

It does NOT run on regular pull requests or pushes to main (to avoid slowing down CI).

**R2 — Variants and architectures tested.** The benchmark measures all combinations:

| Variant | Image name | Architectures |
|---------|------------|---------------|
| core | `fawkes-space-core` | amd64, arm64 |
| ai | `fawkes-space-ai` | amd64, arm64 |
| devcontainer | `fawkes-space-devcontainer` | amd64, arm64 |
| devcontainer-polyglot | `fawkes-space-ai` (polyglot target) | amd64, arm64 |

Total: 8 variant/architecture combinations per run.

**R3 — Cold start measurement.** Cold start = `docker pull` (if not present locally) + first `docker run --rm <image> echo ready`. The image must not be present in the local Docker cache before the pull.

**R4 — Warm start measurement.** Warm start = subsequent `docker run --rm <image> echo ready` runs (3 runs by default, configurable via `RUNS` env var) after the first run has populated the container filesystem cache. The median of the warm runs is reported.

**R5 — Baseline comparison.** Each variant/architecture combination has a baseline value in `images/devsecops/benchmarks/baseline.json`. The benchmark calculates the regression percentage:

```
regression_pct = ((measured - baseline) / baseline) * 100
```

**R6 — Regression gate.** If any variant/architecture exceeds the regression threshold (default 10%, configurable via `REGRESSION_THRESHOLD`), the workflow fails. The gate runs only on scheduled builds and tag releases.

**R7 — Results publication.** Results are aggregated into a markdown table and appended to `$GITHUB_STEP_SUMMARY` for visibility in the workflow run and release notes.

**R8 — Determinism.** The benchmark script (`images/devsecops/tests/benchmark-start.sh`) is deterministic: same inputs produce same outputs. It outputs JSON lines for programmatic aggregation.

## Design

### Repository layout additions

```
images/devsecops/
  benchmarks/
    baseline.json          # baseline values per variant/arch
  tests/
    benchmark-start.sh     # executable benchmark script
```

### Benchmark script interface

```bash
benchmark-start.sh <image-name> <tag> <variant> <arch>
```

Environment variables:
- `REGISTRY` — container registry (default: `ghcr.io/paruff`)
- `BASELINE_FILE` — path to baseline.json (default: `images/devsecops/benchmarks/baseline.json`)
- `REGRESSION_THRESHOLD` — regression percentage to fail (default: 10)
- `RUNS` — number of warm runs (default: 3)

Output: JSON lines to stdout, one per variant/arch:
```json
{"key":"core-amd64","variant":"core","arch":"amd64","image":"fawkes-space-core","cold_ms":1250,"warm_ms":340,"baseline_cold_ms":1200,"baseline_warm_ms":330,"cold_regression_pct":4,"warm_regression_pct":3,"pass":true}
```

Exit code: 0 if all pass, 1 if any regression exceeds threshold or benchmark fails.

### Workflow integration

In `build-devsecops-images.yml`, the `verify` job gets a new step:

```yaml
- name: Cold/warm start benchmark
  if: env.SCHEDULED == 'true' || startsWith(github.ref, 'refs/tags/image-v')
  env:
    REGISTRY: ${{ env.REGISTRY }}
    BASELINE_FILE: ${{ github.workspace }}/images/devsecops/benchmarks/baseline.json
    REGRESSION_THRESHOLD: 10
    RUNS: 3
  run: |
    # ... runs benchmark script for all variants/archs
    # aggregates results to $GITHUB_STEP_SUMMARY
    # exits 1 if any regression exceeds threshold
```

### Baseline file format

```json
{
  "core-amd64": { "cold_ms": 1200, "warm_ms": 330 },
  "core-arm64": { "cold_ms": 1800, "warm_ms": 450 },
  "ai-amd64": { "cold_ms": 2100, "warm_ms": 520 },
  "ai-arm64": { "cold_ms": 3200, "warm_ms": 780 },
  "devcontainer-amd64": { "cold_ms": 2200, "warm_ms": 540 },
  "devcontainer-arm64": { "cold_ms": 3300, "warm_ms": 800 },
  "devcontainer-polyglot-amd64": { "cold_ms": 2300, "warm_ms": 560 },
  "devcontainer-polyglot-arm64": { "cold_ms": 3400, "warm_ms": 820 }
}
```

## Acceptance criteria

1. Benchmark script runs standalone and outputs valid JSON for each variant/arch
2. Workflow runs benchmark on scheduled and tag triggers, skips on PR/push
3. Workflow fails when any variant/arch exceeds 10% regression vs baseline
4. Workflow summary contains a markdown table with all 8 variant/arch results
5. Baseline file can be updated manually to reflect intentional improvements
6. No network access required during benchmark (uses local Docker daemon)

## Risks

- **CI runner variability:** GitHub-hosted runners have variable performance. Mitigation: run 3 warm runs and use median; threshold at 10% absorbs normal variance.
- **Docker layer caching:** GitHub Actions cache may affect cold start. Mitigation: benchmark runs in the same job as the build, so layers are fresh; cold start includes explicit pull.
- **Baseline drift:** Baseline must be updated when intentional improvements are made. Mitigation: documented in PR template; baseline update is a deliberate human action.
