# Specification: Delivery events that work outside CI

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 2
**Builds on:** [`../dora-events/`](../dora-events/) (evidence:
[`dojo-feedback.md`](../dora-events/dojo-feedback.md))

## Current state vs. the evidence

The Dojo lab ran on 2026-09-27. Each gap was re-checked against the code on
`main` before being specified, so this spec does not repeat stale evidence.

| Gap    | Lab evidence                                                 | State on `main` today                                                                                                   | Remaining work     |
| ------ | ------------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------- | ------------------ |
| GAP-01 | Test needed `jsonschema`, which could not be pip-installed   | **Fixed in code:** `test-emit-dora-event.sh` validates with a stdlib draft-07 subset and needs only `python3` and `jq`  | Documentation only |
| GAP-02 | `repo` silently became `unknown` outside CI                  | **Open:** no `--repo` flag; `repo="${GITHUB_REPOSITORY:-${CI_REPO:-unknown}}"` with no warning                          | Code + tests       |
| GAP-03 | Nothing proved an event reaches Loki                         | **Open:** AC-04 only proves a local listener; `docs/UFAWKES_INTEGRATION.md` says the label mapping "depends on settings" | Script + docs      |

## Functional Requirements

### REQ-001: Prerequisites are written down and accurate (GAP-01)

The verification command's prerequisites (`python3`, `jq`; no pip, no
third-party modules) are stated in the places a learner or agent looks:
`docs/UFAWKES_INTEGRATION.md` and the Verification Strategy of
[`../dora-events/plan.md`](../dora-events/plan.md), whose AC-03 row still says
"jsonschema Draft-07 validation". When a prerequisite is missing, the test's
error names the tool and how to install it with the system package manager,
never `pip install`.

### REQ-002: The emitter resolves the repo outside CI (GAP-02)

`scripts/emit-dora-event.sh` resolves `repo` in this order, first hit wins:

1. `--repo <owner/name>` flag
2. `GITHUB_REPOSITORY`, then `CI_REPO` (unchanged CI behaviour)
3. `git remote get-url origin` of the current checkout, parsed from both
   `https://github.com/<owner>/<name>(.git)` and `git@github.com:<owner>/<name>(.git)`

If none yields a repo, the emitter prints a `warn` to stderr naming the ways to
supply one, and still emits the event with `repo: "unknown"` and exits 0. It
never fails the caller: the same non-fatal policy as a failed OTLP export.
Existing CI behaviour is unchanged because rule 2 precedes rule 3.

### REQ-003: An event is shown arriving in uFawkesObs's Loki (GAP-03)

A script, `scripts/verify-dora-event-in-loki.sh`, proves the end-to-end path
against a **running** uFawkesObs stack (`make up-dora` in that repo; collector
OTLP/HTTP on `:4318`, logs pipeline to Loki):

1. emit a `job-finish` event carrying a unique marker (`step` set to a
   per-run token) with `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`;
2. poll Loki's `query_range` API with the documented LogQL query until the
   marker appears or a timeout elapses;
3. exit 0 and print the matched line, or exit 1 with the query and the last
   response on timeout.

If the stack is not reachable the script exits 2 with a `SKIP` message naming
`make up-dora`. It is a live-system check, so it is **not** part of
`scripts/run-unit-tests.sh` or the offline CI gate. The LogQL query and the
Loki label mapping are documented in `docs/UFAWKES_INTEGRATION.md`, replacing
the sentence that says the mapping "depends on your collector's settings".

### REQ-004: Out of scope

Changes to uFawkesObs itself; `Agent-Tokens` footers for OpenCode; updating
uFawkesDojo Lab 02 (a cross-repo follow-up, handed off through
[`../dojo-handoff.md`](../dojo-handoff.md) once REQ-001 to REQ-003 ship).

## Acceptance Criteria

- [ ] AC-01: `test-emit-dora-event.sh` passes in a stock `python3` + `jq` environment with no pip, and its missing-tool message does not mention pip — `test_type: integration`
- [ ] AC-02: repo resolution follows the documented order for `--repo`, env vars, https remote and ssh remote, and `--repo` beats the remote — `test_type: unit`
- [ ] AC-03: with no flag, env var or remote, the emitter warns on stderr, still emits valid JSON with `repo: "unknown"`, and exits 0 — `test_type: unit`
- [ ] AC-04: against a running uFawkesObs, an event emitted over OTLP is found in Loki by the documented LogQL query within the timeout; with the stack down the script exits 2 with a SKIP — `test_type: live-system`
- [ ] AC-05: the prerequisites and the LogQL query appear in `docs/UFAWKES_INTEGRATION.md`, and the stale "jsonschema" row in the dora-events plan is corrected — `test_type: unit` (checked by `grep` in the unit suite)

## Decisions

- **Unknown repo: warn and continue** (owner, 2026-10-01). REQ-002 stands as
  written: the emitter warns on stderr, emits `repo: "unknown"` and exits 0, so a
  misconfigured emitter can never break a pipeline. A `--strict` flag can be
  added later if a consumer needs it.

## Open questions

1. **Loki label mapping is unverified.** uFawkesObs's own docs query Loki by
   `{service_name="..."}`, but nobody has confirmed which labels our emitter's
   resource attributes become through the collector's Loki exporter. Plan
   step 0 settles this by running the stack; the LogQL in REQ-003 must come
   from that run, not from this spec.
2. **Loki's host port** (assumed `3100`) must be read from uFawkesObs's compose
   file, not assumed.

## Governance Alignment

| Requirement | Status  | Notes                                                                                |
| ----------- | ------- | ------------------------------------------------------------------------------------ |
| Security    | COVERED | No secrets; the script talks to `localhost` only and takes endpoints from env vars  |
| Testing     | COVERED | Behaviour changes (REQ-002) are test-first; live check isolated from the offline gate |
| Pipeline    | COVERED | Offline suite stays dependency-free; the live script is never wired into required CI |
| DORA AI Capability 7 (Quality internal platforms) | COVERED | Makes the delivery-events path verifiable by a newcomer on a clean machine |
