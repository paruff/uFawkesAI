# Spec — v2.3.0: releases that publish themselves, and a smaller repo

**Traces to:** [`intent.md`](intent.md). **Plan:** [`plan.md`](plan.md).

Scope: v2.3.0 ships the two parts of the intent that need no owner decision:
every release publishes its image, and the tracked file count goes down. The
Google lifecycle is out of this release (see the plan's "Not in this release").

## Acceptance criteria

### AC-230-01: A Release Please tag publishes its image

- **Given** Release Please merges a release PR and creates tag `vX.Y.Z` with
  the default `GITHUB_TOKEN`
- **Then** `build-cde-space-image.yml` runs on that tag with no person pushing
  anything, and its `publish` job succeeds
- **Verification:** `docker manifest inspect ghcr.io/paruff/fawkes-space:X.Y.Z`
  exits 0 for the first tag after the fix (paruff/uFawkesAI#252)

### AC-230-02: Every self-test runs in the unit runner

- **Then** every `scripts/test-*.sh` is listed in `SUITES` in
  `scripts/run-unit-tests.sh`
- **Verification:** `for f in scripts/test-*.sh; do grep -q "$f" scripts/run-unit-tests.sh || echo "$f"; done`
  prints nothing

### AC-230-03: The repo is smaller

- **Then** `git ls-files | wc -l` is at most 250 at the `v2.3.0` tag (276 on
  2026-11-09)
- **Verification:** the count, pasted in the release PR
