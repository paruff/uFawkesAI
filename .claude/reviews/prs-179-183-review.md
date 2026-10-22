# Review: PRs #179–#183 (paruff/uFawkesAI, all merged)

**Reviewed**: 2026-10-03
**Decision**: REQUEST CHANGES (1 HIGH, fix before tagging `v2.0.0`)

| PR | Title | Verdict |
|---|---|---|
| #179 | remove unused Java LSP plugin | Clean |
| #180 | run live acceptance as root, tests as dev | Superseded by #182 (the image's default USER is dev); no residue |
| #181 | ship curl in the runtime image; time-box the OTLP test | Clean |
| #182 | run the acceptance container explicitly as root | Clean; proven green on rc.3 |
| #183 | release readiness (cosign v3, README claims, benchmark, DevEx) | 1 HIGH, 1 LOW |

## Findings

### HIGH

1. **The warm-start gate will fail releases on runner noise** —
   `images/devsecops/tests/benchmark-start.sh` + the warm baseline from #183.
   Warm starts are ~95–137 ms, so the 10% gate is a ~12 ms window. Two
   consecutive runs of identical images differed by up to 22%
   (`core-arm64`: 99 ms on rc.2, 121 ms on rc.3). Since #178,
   `release-digest` needs `benchmark`, so noise alone can block `v2.0.0`'s
   digest. **Fix:** fail only when the regression exceeds the percentage
   *and* an absolute floor (e.g. `REGRESSION_MIN_MS`, default 50 ms), which
   still catches real regressions (Jaspan & Green: any latency gain counts,
   but noise isn't a regression); add a self-test case.

### MEDIUM

None.

### LOW

2. **README-claims check covers paths and npm scripts only** —
   `scripts/check-readme-claims.sh`. Named skills (`discovery`), agent
   counts ("4 execution-boundary agents") and workflow job names aren't
   checked. Acceptable for AC-AI-04's "every claimed tool appears in the
   template's tree"; extend if those claims drift.

### Checked and fine

- `sudo -u dev` resets the environment, but none of the acceptance
  scripts read `CI` or `GITHUB_*`.
- `BENCH_PRUNE` runs only on CI (job env), never locally; under `set -e`,
  the unset case doesn't abort.
- Warm-only baseline: `.cold_ms // 0` makes cold ungated until recorded, by design.
- `curl runs` check sits outside the `ai` block, so `core` is checked too.
- The OTLP listener's 20 s timeout turns a hang into a failed check.

## Validation (on `main` at the time of review)

| Check | Result |
|---|---|
| Unit suites | Pass (10/10) |
| Typecheck / tests | Pass |
| actionlint / shellcheck | Pass |
| `check-readme-claims.sh` | Pass |
| CI on rc.3 (verify, publish+sign, benchmark, live acceptance, digest) | Pass |
