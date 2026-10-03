# Review: Phase 1 — uFawkesAI v2.0.0

**Reviewed**: 2026-10-03
**Scope**: merged `3bd9a84..be4695e` (#168–#175, 55 files) + open #176, #177
**Decision**: REQUEST CHANGES (1 HIGH, fix before tagging `v2.0.0-rc.1`)

## Summary

The Phase 1 changes are sound: every new script has a self-test, the gates
fail loudly instead of passing empty, and the live claims (Loki, evals) were
checked against real runs. One HIGH would break the first tag's acceptance
job; one MEDIUM makes local Claude eval runs score wrongly.

## Findings

### CRITICAL

None.

### HIGH

1. **Live acceptance job can't pull a private image** —
   `.github/workflows/build-devsecops-images.yml`, job `live-acceptance-tests`.
   The job runs inside `ghcr.io/paruff/fawkes-space:<version>` with no
   `credentials:`, and the workflow grants only `contents: read`. `fawkes-space`
   is a new GHCR package; a first publish is typically private, so on
   `v2.0.0-rc.1` the container pull fails before any test runs. The benchmark
   job already logs in for this reason.
   **Fix:** add `credentials: {username: ${{ github.actor }}, password: ${{ secrets.GITHUB_TOKEN }}}`
   to the container and `permissions: {contents: read, packages: read}` to the job.

### MEDIUM

2. **Claude transcripts overcount trajectory steps** — `scripts/run-evals.sh`,
   `parse_transcript`. Claude `stream-json` emits one `assistant` event per
   content block (thinking, tool_use, text share a `message.id`); a 2-message
   run counted 4 steps (verified with a real Haiku call). CI uses OpenCode and
   is unaffected; local `EVAL_HARNESS=claude` runs fail `max_steps` spuriously.
   **Fix:** count `[.message.id] | unique | length`; give the self-test stub
   message ids and a multi-block message.

### LOW

3. **Release digest can land before acceptance passes** — `release-digest`
   needs only `publish`, so it edits the Release while live tests and the
   benchmark still run. The Release is a draft when the job creates it, so the
   exposure is small. **Fix (optional):** `needs: [publish, live-acceptance-tests]`.
4. **The audit flags its own marker** — `.template:2` contains a bare
   `[PLACEHOLDER]`, so `PLACEHOLDER_ENFORCE=1` in the template reports it.
   Generated repos delete the file, so they're unaffected. **Fix:** backtick it.
5. **`verify-dora-event-in-loki.sh` exit code on emitter failure** — under
   `set -e`, a failing emitter exits with its own code instead of the
   documented 0/1/2. **Fix:** `|| { echo …; exit 1; }` on the emit call.
6. **Stale `AGENTS.md:25` link** to `docs/ai-sdlc/spec.md` (moved in #171).
   Agents may not edit `AGENTS.md`; owner fix.
7. **#177 leaves `.devcontainer/claude-plugins/ufawkes-lsp-java/`** in the
   tree (unlisted, inert); a local hook blocked its deletion. Owner removes it.

## Checked and fine

- `sort -V` downgrade check: `v0.11.0.1 → v0.11.0.1-1` and `v3.14.1 → v3.14.1-1`
  aren't flagged; `v8.30.1 → v8.30.0` is.
- No `[PLACEHOLDER` marker spans lines, so the single-line regex misses none.
- `run_bounded` passes `MODEL` into the timed-out subshell (real OpenCode run
  completed 5/5 through it).
- #176: nothing else reads `/opt/ufawkes/pre-commit/cache`; `verify-tools.sh`
  sets its own `PRE_COMMIT_HOME`.
- #177: no remaining jdtls handling in `scripts/` or the lock-bump path;
  `tools.lock.json` lost only the jdtls entry.

## Validation Results

| Check | Result |
|---|---|
| Unit suites (`scripts/run-unit-tests.sh`) | Pass (9/9) |
| Type check (`npm run typecheck`) | Pass |
| Tests (`npm test`) | Pass |
| Lint (`npm run lint`) | Fail, pre-existing: markdownlint walks local `node_modules`; same failure at `3bd9a84` |
| actionlint / shellcheck on changed workflows and scripts | Pass |
| Real eval run (OpenCode 1.18.32, gemini-3.1-flash-lite) | 5/5 on all three dimensions, local and on `main` CI |

## Files Reviewed

Workflows: `build-devsecops-images.yml`, `agent-config-ci.yml`,
`pre-commit-autoupdate.yml`. Scripts: `run-evals.sh`, `test-run-evals.sh`,
`check-placeholders.sh`, `test-check-placeholders.sh`, `preflight.sh`,
`verify.sh`, `setup.sh`, `verify-dora-event-in-loki.sh`,
`test-emit-dora-event.sh`, `benchmark-start.sh`, `test-benchmark-start.sh`,
`install-tools.sh`, `verify-tools.sh`. Images: `Dockerfile`,
`docker-bake.hcl`, `tools.lock.json`, `.devcontainer/Dockerfile`. Config:
eval tasks and baselines, `opencode.jsonc`, plugin marketplace, `.template`.
Docs: the `v2.0.0`, `image-benchmark`, `placeholder-audit`, `evals-gate`,
`dora-events-portability`, `devsecops-image` chains, README.
