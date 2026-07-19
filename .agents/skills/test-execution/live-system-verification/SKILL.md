---
name: live-system-verification
description: "Stands up a real running instance of the affected component(s) and runs test_type:live-system acceptance criteria against it — real HTTP calls, real process behavior, real evidence. Not a mock, not a simulated environment. Use when tasks.json contains any acceptance criterion tagged test_type: live-system."
license: MIT
compatibility: "uFawkesAI"
metadata:
  author: paruff
  suite: uFawkesAI
---

# Live System Verification Skill

## Why this exists

`test.md` mocks at every boundary by default — a reasonable rule for unit and
integration tests, but it means those tests can pass while the actual deployed
system does not work. This skill is the deliberate exception: no mocks, real
running dependency, real evidence.

## ⚠️ Environment target — CONFIRM before using

This skill is written substrate-agnostic on purpose because the actual target
environment was not confirmed at time of writing:

- **If uFawkesPipe:** a `docker-compose.yml` was observed alongside its
  `.woodpecker.yml`/`Jenkinsfile` — this may be a usable substrate for
  standing up real dependencies. Confirm before relying on it.
- **If uFawkesObs:** no deploy-target evidence was available. Fill in Step 1
  below with your actual mechanism (docker-compose, kind/k3d ephemeral
  cluster, existing staging namespace, or something else) before using this
  skill for real.

**Do not run this skill until Step 1 is filled in for your actual stack.**

## Step 1 — Stand up the environment

`<FILL IN: the exact command(s) to bring up a real, running instance of the
component(s) under test for your stack. Examples of what this might look
like, NOT prescriptions — verify against your own infra before using any of
these:`docker compose -f docker-compose.yml up -d`, or applying GitOps
overlays to an ephemeral kind/k3d cluster, or a`kubectl apply -k
overlays/ephemeral/`. Do not guess at your own command from this list —
confirm it works locally before wiring it into this skill.>`

Wait for readiness (health check endpoint, `docker compose ps` showing
healthy, or equivalent) before proceeding. Record the readiness check and its
output as evidence.

## Step 2 — Run the tagged tests

Run only the tests placed in the `tests/live/` (or `tests_live/`) directory
per `test.md`'s file placement convention, against the real endpoints/services
now running from Step 1. Examples of what these assertions typically look
like — verify current syntax for whichever tool you actually adopt, do not
assume these exact names are installed:

- Real HTTP calls against a real running server (not a mock server)
- `kubectl exec`/`kubectl logs` checks against real pods, if applicable
- Real database reads/writes against the real (ephemeral) database instance

Categories of tooling commonly used for this purpose, for you to evaluate —
not a recommendation of any specific one, and not confirmation any of these
are already part of your stack: Testcontainers (real-dependency integration
without full mocks), k6 or Playwright (live HTTP/UI assertions), kind/k3d
(ephemeral Kubernetes clusters).

## Step 3 — Capture evidence

For every check, paste the raw command output inline in the resulting report
section — do not summarize or assert a status without it. This mirrors
`verification.md`'s existing rule: "every populated evidence field... MUST be
backed by actual command output run in this session."

## Step 4 — Tear down

Tear down the ephemeral environment (`docker compose down`, delete the
ephemeral namespace/cluster, etc.) once evidence is captured, so runs don't
accumulate orphaned infrastructure.

## Output

Feed the following into `test-execution`'s "Live System Verification" report
section:

```json
{
  "status": "PASS | FAIL | N/A",
  "environment": "<what was stood up and how>",
  "checks": [
    {
      "criterion": "<acceptance criterion text>",
      "command": "<exact command run>",
      "output": "<raw output, or the relevant portion>",
      "result": "PASS | FAIL"
    }
  ],
  "torn_down": true
}
```

## Rules

- No mocks. If a check used a mock or stub, it does not belong in this skill's
  output — it belongs back in `test.md`'s unit/integration tests.
- No evidence → FAIL, same as `verification.md`.
- If the environment cannot be stood up, that is itself a FAIL — report it as
  a blocker, not a skipped step.
- Always tear down, even on FAIL, unless torn-down state would destroy
  evidence needed for debugging — in that case, note explicitly why teardown
  was deferred.
