---
name: discovery
description: "15-minute exercise before a spec: name the user, state the job to be done, find the riskiest assumption, write one testable acceptance criterion, and map it to a DORA metric. Produces discovery-brief.md. Use before any new feature."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: per-increment
---

# Skill: discovery

> **Load trigger:** "load discovery skill" · **DORA:** AI Capability 6, user-centric focus

Surfaces the real need behind a proposed change before a spec is written. The output,
`discovery-brief.md`, is the input to `spec.md`. Speed is irrelevant if the team is
moving in the wrong direction.

## When to run

| Change | Run it? |
| --- | --- |
| New feature | Always |
| Migration that changes a developer's workflow | Yes: the developer is the user |
| Bug fix | Only if the fix changes visible behavior |
| Dependency bump, doc fix, added test | No |

## The exercise

1. **Persona (2 min).** One user, the one with the highest stakes in this change. Write `Primary persona: <who>`.
2. **Job to be done (3 min).** Fill the template exactly: "When I `<situation>`, I want to `<action>`, so I can `<motivation>`."
   Reject vague forms such as "I want better observability" (no situation, no motivation).
3. **Riskiest assumption (3 min).** The one assumption that makes the work useless if wrong, as one falsifiable sentence.
   Prompts: "We assume users will X; what if they don't?", "We assume Y is the bottleneck; what if it isn't?"
4. **Acceptance criterion (5 min).** One statement, "Given `<state>`, when `<action>`, then `<observable outcome>`".
   It must be binary pass/fail and testable, for example: "Given a fresh clone, when `make up` runs, then the dashboard
   is reachable on localhost:3000 and shows data within 60 seconds."
5. **DORA outcome (2 min).** Name the DORA AI capability, the metric that should move (deployment frequency, change lead
   time, failed deployment recovery time, change fail rate, deployment rework rate), how it is measured, and the
   baseline (or "unknown: establish it first").

## Prior art (2 min)

Before the spec: does another repo, an open-source project, or an existing skill already cover this? If so, write it down
and compose rather than build.

## discovery-brief.md

```markdown
---
date: YYYY-MM-DD
persona: <who>
jtbd: "When I ..., I want to ..., so I can ..."
riskiest_assumption: "We assume ..."
acceptance_criterion: "Given ..., when ..., then ..."
dora_ai_capability: "6: User-centric focus"
metric: change_lead_time_hours
measurement_source: <where it is measured>
baseline: "<value and date, or unknown>"
prior_art: null
status: ready-for-spec
---

# Discovery Brief: <change name>

## Job to Be Done
## Riskiest Assumption
## Acceptance Criterion
## DORA Outcome Target
## Prior Art
## Notes
```

## Done when

The brief has all five parts, the acceptance criterion is testable, and `status` is `ready-for-spec`. If the riskiest
assumption can be tested cheaply (a spike, a query, a five-minute interview), test it now and record the result in Notes.
