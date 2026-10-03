# Plan: Delivery events that work outside CI

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

## Architecture Overview

Three small, independent changes to the existing delivery-events feature
([`../dora-events/`](../dora-events/)). No new runtime dependencies and no
change to the event schema.

```text
emit-dora-event.sh ──(REQ-002: repo resolution)──► JSON event ──► stdout / file
                                                        │
                                                        └─ OTLP/HTTP :4318 ─► uFawkesObs collector ─► Loki
                                                                                         ▲
verify-dora-event-in-loki.sh ── (REQ-003: emit marker, poll query_range) ───────────────┘
```

## Components

### Component: repo resolution in `scripts/emit-dora-event.sh` (REQ-002)

Add a `--repo` flag and a `resolve_repo` function implementing the order in
the spec (flag, `GITHUB_REPOSITORY`, `CI_REPO`, `git remote get-url origin`).
Remote parsing handles `https://github.com/o/n(.git)` and
`git@github.com:o/n(.git)` with shell parameter expansion, no new tools. When
unresolved it calls the existing `warn` and keeps `repo=unknown`. The
existing `[ "$repo" != unknown ]` guard on the PR lookup keeps working.

### Component: `scripts/verify-dora-event-in-loki.sh` (REQ-003)

A standalone script, not wired into `run-unit-tests.sh`. Inputs by env var:
`OTEL_EXPORTER_OTLP_ENDPOINT` (default `http://localhost:4318`),
`LOKI_URL` (default from plan step 0), `VERIFY_TIMEOUT_SECONDS` (default 30).
Exit codes: 0 found, 1 timed out, 2 stack unreachable (SKIP).

### Component: documentation (REQ-001, AC-05)

`docs/UFAWKES_INTEGRATION.md`: prerequisites, the verified LogQL query and
label mapping, how to run the live check. `../dora-events/plan.md`: correct the
AC-03 row to say the stdlib validator.

## Tradeoffs

| Decision                                  | Chosen                              | Rejected                              | Why                                                                              |
| ----------------------------------------- | ----------------------------------- | ------------------------------------- | -------------------------------------------------------------------------------- |
| Unknown repo                              | warn, emit `unknown`, exit 0        | fail the run                          | An emitter must never break a pipeline; same policy as failed OTLP export        |
| Live check in required CI                 | no, manual / opt-in                 | start uFawkesObs in CI                | Needs a second repo's stack; would make PR CI slow and cross-repo flaky          |
| Remote parsing                            | shell expansion                     | add a dependency                      | Only two URL shapes matter; keeps the offline suite dependency-free              |
| Poll Loki                                 | bounded poll on `query_range`       | fixed `sleep`                         | Ingestion latency varies; a condition-based wait is faster and not flaky         |

## Governance Alignment

| Requirement | Design Decision                                              | Status  |
| ----------- | ------------------------------------------------------------ | ------- |
| Security    | localhost only; endpoints from env vars; no secrets          | COVERED |
| Testing     | REQ-002 test-first; live check separated from the offline gate | COVERED |
| Pipeline    | unit suite unchanged in shape; no new required check         | COVERED |

## Implementation Sequence

Test-first throughout: each behaviour change starts with a failing test.

0. **Discover, do not assume.** In the uFawkesObs checkout run `make up-dora`;
   read the Loki host port from its compose file; emit one event with
   `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`; in Loki, record which
   labels the event actually carries and the LogQL that finds it. This answers
   spec open questions 1 and 2 and fixes the query used in steps 4 and 5.
   Record the evidence (query, response) in the PR.
1. **REQ-002 tests (red).** Extend `scripts/test-emit-dora-event.sh` with the
   AC-02 and AC-03 cases using throwaway git repos with an https remote, an
   ssh remote, no remote, and `--repo` against a remote. Confirm they fail.
2. **REQ-002 implementation (green).** Add `--repo` and `resolve_repo` to
   `scripts/emit-dora-event.sh`; usage text updated.
3. **REQ-001 error message.** Change the missing-tool message in the test to
   name the system package manager (AC-01), and add a `grep`-based doc check
   to the unit suite for AC-05.
4. **REQ-003 script.** Write `scripts/verify-dora-event-in-loki.sh` with the
   query from step 0, bounded polling, and the three exit codes.
5. **Docs.** Update `docs/UFAWKES_INTEGRATION.md` and the dora-events plan
   row (AC-05).
6. **Handoff.** Open a `dojo-feedback` follow-up so Lab 02 can drop its
   workarounds and add a "see it in Grafana" step (cross-repo, not in this PR).

## Verification Strategy

| AC    | How it is proven                                                                                 | test_type   | Command / CI job                                         |
| ----- | ------------------------------------------------------------------------------------------------ | ----------- | -------------------------------------------------------- |
| AC-01 | run the test in a stock Debian container with only `python3` and `jq`; no pip                    | integration | `docker run debian:stable-slim ... test-emit-dora-event.sh` |
| AC-02 | throwaway repos: https remote, ssh remote, `--repo` over remote, env var over remote             | unit        | `scripts/test-emit-dora-event.sh`                        |
| AC-03 | no flag, env or remote: stderr warns, JSON valid, `repo` is `unknown`, exit 0                    | unit        | `scripts/test-emit-dora-event.sh`                        |
| AC-04 | `make up-dora`, run the script, assert exit 0; stop the stack, assert exit 2 and a SKIP message  | live-system | `scripts/verify-dora-event-in-loki.sh` (manual, opt-in)  |
| AC-05 | `grep` for the prerequisites and the LogQL in the docs; the stale row is gone                    | unit        | `scripts/run-unit-tests.sh`                              |

AC-04 cannot run in required CI by design; its evidence is the recorded
output from plan step 0 and from a final run in the PR description.

**Evidence (2026-10-03, uFawkesObs `main` dfd4fc9, `make up-dora`):** the
event carries labels `service_name="uFawkesAI"`, `job="uFawkesAI"`,
`exporter="OTLP"`; the line is the OTLP record with the event JSON in `body`.
`scripts/verify-dora-event-in-loki.sh` exited 0 with the event found by
`{service_name="uFawkesAI", exporter="OTLP"} | json | line_format "{{.body}}" | json | event="job-finish" | step="<marker>"`;
exited 2 (SKIP) with `LOKI_URL` pointing at a closed port; exited 1 after the
timeout with the OTLP endpoint pointing at a closed port.

## Risks

- **Label mapping differs from the docs' `service_name` convention.** Mitigated
  by step 0; the spec forbids writing the LogQL before that run.
- **Loki ingestion latency** makes a fixed wait flaky; mitigated by bounded polling.
- **Cross-repo drift:** uFawkesObs can change its collector config. The script
  fails with the query and the last response, which makes drift diagnosable.
