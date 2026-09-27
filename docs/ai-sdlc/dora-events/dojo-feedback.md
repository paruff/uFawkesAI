---
lab: white-belt/module-02-dora-metrics/lab-02
lab_ref: https://github.com/paruff/uFawkesDojo/pull/15
source_feature: docs/ai-sdlc/dora-events
source_commit: 09886a83a031ff0afc6af0f5d390dd39ab8ffaf9
completed_at: 2026-09-27
learners: 1
proposed_feature: dora-events-portability
---

# Dojo Feedback: dora-events

Facilitator dry run (the lab author, an AI agent) of uFawkesDojo White Belt
Module 2 Lab 02, in a fresh clone with only the lab's stated tools. Every
step was run for real; the evidence below is the output as it appeared.

## Lab Results

| AC    | Rubric check (validate.sh)                                     | Passed | Failed | Notes |
| ----- | -------------------------------------------------------------- | ------ | ------ | ----- |
| AC-01 | own events are single-line JSON with dora-log.sh's fields      | 1      | 0      | only after setting `GITHUB_REPOSITORY` by hand (GAP-02) |
| AC-02 | own job-finish carries agent_tokens and a PR cycle time        | 1      | 0      | same workaround (GAP-02) |
| AC-03 | real deploy-marker `dora_event` validates against the schema   | 1      | 0      | failed first: no `jsonschema` (GAP-01) |
| AC-04 | emitter test suite passes, incl. OTLP export                   | 1      | 0      | failed first: no `jsonschema` (GAP-01); proves a local listener only (GAP-03) |
| AC-05 | real pipeline artifact has deploy-marker with tokens + cycle   | 1      | 0      | run 36314948159: 44415 output tokens, 257 s cycle time |

## Gaps

### GAP-01: Verification command has an undeclared Python dependency

- **Type:** plan
- **Evidence:** on a clean checkout, `bash scripts/test-emit-dora-event.sh` printed `FAIL: python3 has no jsonschema module (pip install jsonschema)`; the suggested fix then failed: `pip: command not found`, `python3 -m pip` → `No module named pip`, and `python3 -m venv` → `ensurepip is not available … apt install python3.13-venv`. CI passes only because `ci-quality.yml` runs `pip install 'jsonschema==4.25.1'` itself. The lab had to add a `uv` workaround.
- **Affected:** `scripts/test-emit-dora-event.sh`, `docs/ai-sdlc/dora-events/plan.md` (Verification Strategy)
- **Proposed change:** declare the dependency where learners and agents look (prerequisites in the plan and docs), and give the test a path that works without system pip — e.g. run the schema check via a pinned `uv`/`uvx` tool, or in the DevSecOps image, which already ships `jsonschema`
- **Severity:** medium

### GAP-02: The emitter only works inside CI

- **Type:** spec
- **Evidence:** in a plain checkout, `scripts/emit-dora-event.sh job-finish` emitted `"repo":"unknown"`, `"pr":null`, `"agent_tokens":null` with no warning; with `--pr 84` it printed `GitHub API lookup for PR #84 failed; PR metadata omitted`. It worked only after `export GITHUB_REPOSITORY=paruff/uFawkesAI`, which no doc mentions. The spec's REQ-002 only considers CI context.
- **Affected:** `scripts/emit-dora-event.sh`, `docs/ai-sdlc/dora-events/spec.md`
- **Proposed change:** infer the repo from `git remote get-url origin`, add a `--repo` flag, and warn loudly (not silently emit `unknown`) when the repo can't be determined; add an AC for local use
- **Severity:** medium

### GAP-03: "uFawkesObs can ingest" is never verified against uFawkesObs

- **Type:** plan
- **Evidence:** the plan proves AC-04 with a local HTTP listener only; no Verification Strategy row exercises a running uFawkesObs collector → Loki. The lab therefore could not include a "see your event in Loki" step (uFawkesDojo's rule: no step that hasn't been run for real), and `docs/UFAWKES_INTEGRATION.md` still says the Loki label mapping "depends on your collector's Loki exporter settings".
- **Affected:** `docs/ai-sdlc/dora-events/plan.md`, `docs/UFAWKES_INTEGRATION.md`
- **Proposed change:** add a live-system verification: start uFawkesObs (`make up-dora`, as in Lab 01), emit with `OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`, and assert the event is queryable in Loki with a documented LogQL query
- **Severity:** medium

## Proposed Intent

### Problem

The delivery-events feature passes CI but does not survive first contact
outside it: its own verification needs an undeclared dependency that
standard Debian/Ubuntu Pythons can't install the suggested way (GAP-01), the
emitter silently loses the repo and PR when run from a checkout (GAP-02),
and nothing has ever shown an event actually arriving in uFawkesObs's Loki
(GAP-03). A Dojo learner hit all three in a 25-minute lab.

### Desired outcome

- `scripts/test-emit-dora-event.sh` runs on a clean machine with only the
  documented prerequisites, and those prerequisites are written down.
- `scripts/emit-dora-event.sh` works from a checkout with no CI variables
  (repo inferred or `--repo`), and warns instead of emitting `unknown`.
- A verification step shows a real event queryable in uFawkesObs's Loki,
  with the LogQL query documented; Lab 02 can then drop its workarounds and
  add a "see it in Grafana" step.

### Out of scope

- OpenCode support for `Agent-Tokens` footers (not observed in this lab run)
- Changes to uFawkesObs itself
