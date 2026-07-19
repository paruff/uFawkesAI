---
name: discovery
description: "15-minute JTBD + acceptance criterion exercise. Use before any spec session. Produces a discovery-brief.md that anchors the entire increment to a real user need and a measurable DORA outcome. Implements DORA AI Capability 6."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Discovery

> **Load trigger:** `"load discovery skill"` > **DORA:** AI Capability 6 (User-centric focus)
> **Token cost:** Low

## Purpose

A 15-minute structured exercise that surfaces the real user need behind a proposed
change, the riskiest assumption embedded in it, and one testable acceptance criterion.
Output is `discovery-brief.md` — mandatory input to the spec agent.

DORA AI Capabilities Model v2025.1: Teams adopting AI without user-centric focus see
harm to team performance. Speed is irrelevant if moving in the wrong direction.

## When to Run

| Situation                                                | Run discovery?                                  |
| -------------------------------------------------------- | ----------------------------------------------- |
| New feature proposed                                     | ✅ Always                                       |
| Infrastructure migration that affects developer workflow | ✅ Yes — the developer _is_ the user            |
| Bug fix                                                  | ⚠ Only if the fix changes user-visible behavior |
| Dependency update, doc fix, test addition                | ❌ Skip — no user behavior change               |
| New Dojo belt module                                     | ✅ Yes — the learner is the user                |

## Persona Reference Table

| Persona ID          | Role                                            | Primary job                                | Pain points                                                  |
| ------------------- | ----------------------------------------------- | ------------------------------------------ | ------------------------------------------------------------ |
| `platform-engineer` | You (paruff)                                    | Ship reliable IDP improvements in 2hrs/day | Context switching, migration blast radius, scope creep       |
| `product-engineer`  | Dev using fawkes golden paths                   | Get from idea to running service           | Unclear golden paths, config complexity, slow feedback loops |
| `dojo-learner`      | Developer learning DevOps/platform skills       | Learn by doing, not reading                | Labs that don't run, missing prerequisites, unclear outcomes |
| `team-lead`         | Engineering manager adopting fawkes             | Know if the platform investment pays off   | No DORA visibility, unclear ROI, onboarding friction         |
| `solo-entrepreneur` | Small-team founder using uFawkesPipe/uFawkesObs | Ship product, not manage infra             | Operational overhead, complex setup, limited time            |

## The 5-Step Exercise (15 minutes)

### Step 1 — Name the persona (2 min)

Pick one from the Persona Reference Table. If the change affects multiple personas,
pick the one with the _highest stakes_ in this increment.

Write: `Primary persona: [persona-id]`

### Step 2 — State the JTBD (3 min)

Complete this template precisely — do not paraphrase:

> _"When I [concrete situation triggering the need], I want to [desired action or outcome],
> so I can [deeper motivation or business goal]."_

Examples:

- ✅ "When I deploy a new uFawkesObs release, I want `docker compose up` to succeed
  without manual config steps, so I can verify DORA metrics are flowing within 5 minutes."
- ❌ "As a user, I want better observability." (Too vague — no situation, no motivation)
- ❌ "I want the CI pipeline to be faster." (No situation, no deeper goal)

### Step 3 — Surface the riskiest assumption (3 min)

What is the one assumption in this proposal that, if wrong, makes the whole increment
useless or harmful?

Prompts to find it:

- "We assume users will [X]. What if they don't?"
- "We assume this takes [Y hours]. What if it takes 10x longer?"
- "We assume [Z] is the bottleneck. What if the real bottleneck is somewhere else?"

Write: `Riskiest assumption: [one sentence, falsifiable]`

### Step 4 — Write the acceptance criterion (5 min)

One given/when/then statement. Must be:

- Testable by the test-execution agent (not just "user feels better")
- Specific enough that a binary pass/fail is possible
- Grounded in the JTBD from Step 2

Template:

> _"Given [starting state], when [user action or system trigger], then [observable outcome]."_

Examples:

- ✅ "Given uFawkesObs is cloned on a fresh machine, when `make up` is run, then
  Grafana is accessible at localhost:3000 and the DORA Deployment Frequency panel
  shows data within 60 seconds."
- ❌ "Given the system is running, when the user uses it, then it works." (Not testable)

### Step 5 — Map to DORA outcome (2 min)

| Field                         | Answer                                                          |
| ----------------------------- | --------------------------------------------------------------- |
| DORA AI Capability improved   | [which of the 7 capabilities]                                   |
| DORA Core Capability improved | [which core DevOps capability, if applicable]                   |
| Metric that should improve    | [deployment frequency / lead time / CFR / MTTR]                 |
| How measured                  | [uFawkesObs Prometheus query / uFawkesDORA dashboard / manual]  |
| Baseline (current value)      | [current metric value, or "unknown — establish baseline first"] |

## Prior Art Check

Before writing the spec, spend 2 minutes checking:

- Does this already exist in another uFawkes\* stack?
- Does a well-known open-source project already solve this? (Compose rather than build)
- Does the uFawkesAI skill suite already cover this?

If prior art exists: document it and propose composition over construction.

## discovery-brief.md Template

```markdown
---
date: YYYY-MM-DD
persona: platform-engineer
jtbd: "When I ..., I want to ..., so I can ..."
riskiest_assumption: "We assume ..."
acceptance_criterion: "Given ..., when ..., then ..."
dora_ai_capability: "Cap6: User-centric focus"
dora_core_capability: "Continuous Delivery"
metric: "lead_time_hours"
measurement_source: "uFawkesObs"
baseline: "18.4 hours (2026-06-01)"
prior_art: null
status: ready-for-spec
---

# Discovery Brief: [FEATURE_OR_CHANGE_NAME]

## Job to Be Done

[JTBD statement]

## Riskiest Assumption

[One sentence]

## Acceptance Criterion

[Given/When/Then]

## DORA Outcome Target

- Capability: [capability]
- Metric: [metric name]
- Current baseline: [value]
- Target: [value]
- Measurement: [how/where]

## Prior Art

[None found | Link to existing solution]

## Notes

[Any context that will help the spec agent — constraints, dependencies, related issues]
```

## Output Format

```json
{
  "skill": "discovery",
  "status": "complete | blocked | skipped",
  "skip_reason": null,
  "brief_path": "discovery-brief.md",
  "persona": "platform-engineer",
  "jtbd_complete": true,
  "assumption_stated": true,
  "acceptance_criterion_testable": true,
  "dora_capability_mapped": true,
  "prior_art_found": false,
  "ready_for_spec": true,
  "time_spent_minutes": 14
}
```

## Sub-Skills

| Sub-skill                     | Purpose                                                                         |
| ----------------------------- | ------------------------------------------------------------------------------- |
| `discovery/persona-deep-dive` | Extended persona research when primary persona is unclear                       |
| `discovery/assumption-test`   | Design a lightweight experiment to test the riskiest assumption before building |
| `discovery/prior-art-search`  | Structured search across uFawkes\* repos and open source for existing solutions |
