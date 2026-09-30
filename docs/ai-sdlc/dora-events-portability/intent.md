# Intent — dora-events-portability

Status: DRAFT — from Dojo feedback on `white-belt/module-02-dora-metrics/lab-02` (`docs/ai-sdlc/dora-events/dojo-feedback.md`); built from
`docs/ai-sdlc/dora-events` @ `09886a83a031`. Due: 2026-10-04.

## Problem

The delivery-events feature passes CI but does not survive first contact
outside it: its own verification needs an undeclared dependency that
standard Debian/Ubuntu Pythons can't install the suggested way (GAP-01), the
emitter silently loses the repo and PR when run from a checkout (GAP-02),
and nothing has ever shown an event actually arriving in uFawkesObs's Loki
(GAP-03). A Dojo learner hit all three in a 25-minute lab.

## Gaps this cycle addresses

- GAP-01: Verification command has an undeclared Python dependency
- GAP-02: The emitter only works inside CI
- GAP-03: "uFawkesObs can ingest" is never verified against uFawkesObs

Details and evidence: `docs/ai-sdlc/dora-events/dojo-feedback.md`.

## Desired outcome

- `scripts/test-emit-dora-event.sh` runs on a clean machine with only the
  documented prerequisites, and those prerequisites are written down.
- `scripts/emit-dora-event.sh` works from a checkout with no CI variables
  (repo inferred or `--repo`), and warns instead of emitting `unknown`.
- A verification step shows a real event queryable in uFawkesObs's Loki,
  with the LogQL query documented; Lab 02 can then drop its workarounds and
  add a "see it in Grafana" step.

## Out of scope

- OpenCode support for `Agent-Tokens` footers (not observed in this lab run)
- Changes to uFawkesObs itself
