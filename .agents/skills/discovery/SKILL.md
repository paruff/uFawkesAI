---
name: discovery
description: "15-minute JTBD + acceptance criterion exercise. Use before any spec session. Produces a discovery-brief.md that anchors the entire increment to a real user need and a measurable DORA outcome. Implements DORA AI Capability 6. Includes advanced methods for untested assumptions, persona deep-dives, and prior art search."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
  cadence: per-increment
---

# Skill: discovery

> **Load trigger:** "load discovery skill" > **DORA:** AI Capability 6: User-centric focus
> **Token cost:** Low

## Purpose

15-minute JTBD + acceptance criterion exercise. Use before any spec session. Produces a discovery-brief.md that anchors the entire increment to a real user need and a measurable DORA outcome. Implements DORA AI Capability 6.

This skill combines:
- **Core discovery** — 15-min JTBD + acceptance criteria
- **Advanced methods** — for untested assumptions, persona deep-dives, prior art search
- **Discover skill** — pre-spec user research agent

## When to Use

- Before any spec session begins
- When the riskiest assumption is untested
- When user segments disagree
- When a major capability is designed from scratch

## Sub-skills (now integrated)

### 1. Core Discovery

# Skill: Discovery

> **Load trigger:** `"load discovery skill"` > **DORA:** AI Capability 6: User-centric focus
> **Token cost:** Low

## Purpose

A 15-minute structured exercise that surfaces the real user need behind a proposed
change, the riskiest assumption embedded in it, and one testable acceptance criterion.
Output is `discovery-brief.md` — mandatory input to the `spec` skill.

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

- Testable by the `test-execution` skill (not just "user feels better")
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
dora_ai_capability: "6: User-centric focus"
dora_core_capability: "Core: Continuous delivery"
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

[Any context that will help the `spec` skill — constraints, dependencies, related issues]
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

### 2. Advanced Discovery

# Skill: Discovery Advanced

> **Load trigger:** `"load discovery-advanced skill"` > **DORA:** AI Capability 6: User-centric focus
> **Token cost:** Medium
> **Prerequisite:** `discovery` skill must have run first. This skill extends it.

## Purpose

When the 15-minute `discovery` exercise surfaces an assumption too risky to build on
without testing, this skill provides the methods to validate it before writing a line
of code. Designed for a solo entrepreneur with 2hrs/day: every method here fits
inside one session.

## When to Use This Skill (not the base `discovery` skill)

| Situation                                                              | Method                                     |
| ---------------------------------------------------------------------- | ------------------------------------------ |
| Riskiest assumption involves user behavior you've never observed       | Assumption mapping + lightweight interview |
| Two personas have conflicting needs for the same feature               | Persona priority matrix                    |
| Major capability being designed (new belt module, new golden path)     | Jobs-to-be-done interview protocol         |
| Previous release didn't get adopted despite solving the stated problem | Assumption autopsy                         |
| Platform feedback NPS dropped significantly without clear cause        | Friction log analysis                      |

## Method 1: Assumption Mapping (20 min)

Surface all assumptions embedded in a proposed change, rank by risk.

```markdown
## Assumption Map — [FEATURE_NAME]

For each assumption, assess:

- Importance: How critical is this to the feature working? (High/Med/Low)
- Certainty: How confident are we this is true? (High/Med/Low)
- Risk = High importance + Low certainty

| #   | Assumption                                           | Importance | Certainty | Risk    | Validation method    |
| --- | ---------------------------------------------------- | ---------- | --------- | ------- | -------------------- |
| 1   | Users will read the Quick Start before filing issues | High       | Low       | 🔴 High | Check issue patterns |
| 2   | Docker Compose up works on Mac ARM                   | High       | Med       | 🟡 Med  | CI matrix test       |
| 3   | Users prefer CLI over UI for config                  | Med        | Low       | 🟡 Med  | Friction log review  |

Prioritize: validate 🔴 High-risk assumptions before writing any spec.
```

## Method 2: Lightweight JTBD Interview Protocol (45 min)

One interview, one session. Use for major capabilities.

**Recruit:** One person from the target persona group. Can be a Dojo learner, a
colleague, or someone who filed a GitHub issue. Async is fine (written Q&A).

**Interview guide (8 questions, 30 min async or 20 min sync):**

```markdown
Context questions (understand the situation):

1. Tell me about the last time you tried to [relevant task]. What were you doing
   right before that moment?
2. What made you decide to do it at that point rather than earlier or later?

Motivation questions (understand the deeper goal): 3. What were you hoping to accomplish? 4. What would "done" look like for you?

Struggle questions (surface the real friction): 5. What was the hardest part? 6. What did you try that didn't work?

Outcome questions (understand the value): 7. How did it turn out? What did you end up doing? 8. If this had worked perfectly, what would have been different for you afterward?
```

**Analysis (15 min):**

- Extract the JTBD from questions 3-4: "When [Q1 situation], I want to [Q3 motivation], so I can [Q8 outcome]."
- Extract the real friction from questions 5-6: update `riskiest_assumption` in discovery-brief.md
- Compare against the assumption map: which assumptions did this validate or invalidate?

## Method 3: Persona Priority Matrix (20 min)

When two personas want conflicting things from the same feature.

```markdown
## Persona Priority Matrix — [FEATURE_NAME]

| Capability              | platform-engineer | product-engineer | dojo-learner | team-lead  |
| ----------------------- | ----------------- | ---------------- | ------------ | ---------- |
| Zero-config quick start | Nice to have      | Must have        | Must have    | Don't care |
| Full configurability    | Must have         | Nice to have     | Don't care   | Don't care |
| Built-in DORA metrics   | Must have         | Nice to have     | Nice to have | Must have  |
| CLI-first interface     | Must have         | Nice to have     | Nice to have | Don't care |

Resolution rule: If primary persona says "Must have" and secondary says "Don't care" or
"Nice to have" — build for the primary persona. If both say "Must have" and they conflict:
build the primary persona's version first, design for extensibility so secondary can be
served in a future increment.

Primary persona for this increment: [persona-id from discovery-brief.md]
Decision: [what you're building and why]
```

## Method 4: Assumption Autopsy (30 min)

When a previous release didn't get adopted. Use the `learn` skill's discovery accuracy
record as the starting point.

```markdown
## Assumption Autopsy — [RELEASE_VERSION]

1. Original riskiest assumption: [from discovery-brief.md]
2. Was it validated before building? [Yes / No / Partially]
3. What actually happened after release: [from `learn` skill retrospective]
4. The assumption that was actually wrong: [identify the real failure]
5. What we should have done differently: [updated assumption + validation method]
6. Impact on next increment: [how this changes the discovery brief for the next version]
```

## Method 5: Friction Log Analysis (30 min)

When platform-feedback NPS dropped without a clear cause.

```bash
# Collect friction signals from multiple sources
echo "=== GitHub Issues (user-feedback label) ==="
gh issue list --repo paruff/fawkes --label "user-feedback" --state open \
  --json number,title,createdAt --jq '.[] | "\(.createdAt[:10]): \(.title)"'

echo "=== Discussion threads with most replies ==="
# Manual: review pinned platform-feedback Discussion thread

echo "=== README 'Getting Help' section issues ==="
# Manual: check if any issues mention specific doc sections

echo "=== CI failures that users might have hit ==="
gh run list --repo paruff/REPO_NAME --status failure --limit 20
```

Categorize findings into friction themes (same categories as `platform-feedback` skill).
Each theme with >2 data points becomes an `@planner` action item.

## Output: Updated Discovery Brief

All methods produce updates to `discovery-brief.md`. Add a section:

```markdown
## Advanced Discovery Findings

### Method used

[assumption-mapping | jtbd-interview | persona-matrix | assumption-autopsy | friction-log]

### Key finding

[One sentence: what you learned that wasn't in the original brief]

### Assumption updates

- Original riskiest assumption: [original]
- Revised riskiest assumption: [updated based on findings]
- Assumptions invalidated: [list]
- Assumptions confirmed: [list]

### Impact on spec

[How this changes what gets built — or whether it gets built at all]
```

## Output Format

```json
{
  "skill": "discovery-advanced",
  "method": "jtbd-interview",
  "time_spent_minutes": 45,
  "discovery_brief_updated": true,
  "assumptions_invalidated": 1,
  "assumptions_confirmed": 2,
  "spec_impact": "Narrowed scope to CLI-only for v0.2; UI deferred to v0.3",
  "build_decision": "proceed | descope | defer | cancel"
}
```

### 3. Discover Agent

# Skill: Discover

> **Load trigger:** `"load discover skill"`
**Invoke when:** A new feature, capability, or change is proposed — before `spec.md` begins. > **DORA:** AI Capability 6: User-centric focus > **Token cost:** Low

> Migrated from the former `discover` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

> **Invoke when:** A new feature, capability, or change is proposed — before `spec.md` begins.
> **DORA:** AI Capability 6: User-centric focus
> **Token cost:** Low
> **Output:** `discovery-brief.md` → consumed by `spec` skill

## Purpose

Ensure every increment starts from a real user need, not an assumed one. Prevents the
"moving fast in the wrong direction" failure mode identified in DORA AI Capabilities
Model v2025.1. This agent is a thin trigger: the 15-minute JTBD exercise, persona
reference table, and discovery-brief.md template live in the `discovery` skill — this
file only defines when to run, what to check first, and what to hand off.

## Trigger Conditions

| Trigger              | Description                                                       |
| -------------------- | ------------------------------------------------------------------- |
| New feature proposed | Any item moving from Backlog → This Week on the project board     |
| Migration planned    | Before any infrastructure change that affects developer workflow  |
| User complaint filed | Issue labeled `ux` or `developer-experience`                      |
| Dojo module planned  | Before authoring a new belt module (maps to a user learning need) |

## Pre-conditions

- [ ] Load `discovery` skill: `"load discovery skill"`
- [ ] Load `dev-experience` skill: `"load dev-experience skill"`
- [ ] AI_STANCE.md exists and is current (load `ai-stance` skill to verify)
- [ ] context-report.json shows no placeholder or missing-file findings

## Responsibilities

Run the `discovery` skill's 5-step exercise (persona → JTBD → riskiest assumption →
acceptance criterion → DORA outcome mapping) and its Prior Art Check in full — see
that skill for the exact templates, persona reference table, and worked examples.

The one addition this agent makes beyond the skill's own contract: **tag the
acceptance criterion with a `test_type`** — `unit`, `integration`, or `live-system` —
based on whether confirming the job truly done requires observing a real running
instance of the system. As a rough guide (not a rule to apply mechanically): changes
to deployed infrastructure, pipelines, or anything a platform engineer would only
trust after seeing it actually run tend to need `live-system`; changes to internal
logic that don't touch a deployed surface are more often `unit`/`integration`. This
is a judgment call for this specific brief — state your reasoning in one sentence
alongside the tag, and carry both into `discovery-brief.md`'s frontmatter and the
Output Format below.

## Handoff

Produces `discovery-brief.md` (per the `discovery` skill's template, extended with
`test_type` / `test_type_reasoning`) and passes it to the `spec` agent as mandatory
input. The `spec` skill MUST NOT begin without a discovery brief.

## Output Format

```json
{
  "agent": "discover",
  "status": "complete | blocked",
  "brief_path": "discovery-brief.md",
  "persona": "string",
  "jtbd": "string",
  "riskiest_assumption": "string",
  "acceptance_criterion": "string",
  "test_type": "unit | integration | live-system",
  "test_type_reasoning": "string — one sentence on why this tag was chosen",
  "dora_capability": "string",
  "dora_metric": "string",
  "prior_art_found": true,
  "prior_art_reference": "string | null",
  "ready_for_spec": true
}
```

## Success Criteria

- [ ] All `discovery` skill success criteria met (persona, JTBD, assumption,
      testable acceptance criterion, DORA mapping, prior art check)
- [ ] Acceptance criterion tagged with a `test_type` and a one-sentence reasoning
- [ ] discovery-brief.md written and passed to `spec` skill

### 4. Sub-skills

### assumption-test

# Sub-Skill: Discovery — Assumption Test

> **Load trigger:** `"load discovery/assumption-test skill"` > **DORA:** AI Capability 6: User-centric focus + AI Capability 5: Working in small batches
> **Token cost:** Low
> **When to use:** Riskiest assumption is high-stakes and currently unvalidated.

## Purpose

Design the smallest possible experiment to confirm or refute the riskiest assumption
before committing to building. DORA's "working in small batches" principle applies
here: validate assumptions in small batches before scaling to implementation.

A 2-hour assumption test that invalidates a bad assumption saves 10+ hours of
building something nobody needed.

## Assumption Type → Test Method

| Assumption type                                | Example                                                          | Recommended test                                          |
| ---------------------------------------------- | ---------------------------------------------------------------- | --------------------------------------------------------- |
| **Behavioral** — user will do X                | "Users will run `make up` rather than following manual steps"    | Observation or written walkthrough with one real user     |
| **Technical** — system can do Y                | "`docker compose up` works on ARM Mac without modification"      | CI matrix test on the relevant platform                   |
| **Adoption** — users will find/use feature     | "Dojo learners will discover the new lab before asking for help" | Check GitHub Discussion for help requests in similar area |
| **Performance** — system will do Y fast enough | "Grafana dashboard loads in <3 seconds with 30 days of data"     | Benchmark test with synthetic data                        |
| **Integration** — component A works with B     | "uFawkesPipe events reach uFawkesObs Prometheus within 30s"      | Integration smoke test                                    |
| **Preference** — users prefer X over Y         | "Users prefer CLI config over UI config"                         | Prior-art search + friction log analysis                  |

## Test Design Protocol

### Step 1 — State the assumption precisely

From the discovery brief:

> `riskiest_assumption: "We assume [specific claim]"`

Convert to falsifiable form: "If we [run test X], we expect [observable outcome Y].
If we observe [different outcome Z], the assumption is false."

### Step 2 — Choose the cheapest test

Order of preference (cheapest first):

1. **Check existing data** — GitHub issues, platform-feedback history, CI logs. Costs 15 min.
2. **Prior-art search** — Does someone else's project prove or disprove this? Costs 20 min.
3. **Automated check** — Write a script or CI job that tests the claim directly. Costs 30-60 min.
4. **Manual walkthrough** — Do the thing yourself in a clean environment. Costs 30-60 min.
5. **User interview** — Ask one person from the target persona. Costs 45 min async.

Never jump to option 5 if options 1-3 would answer the question.

### Step 3 — Define the pass/fail criteria before running

Write the criteria _before_ you run the test, not after. Confirmation bias is real.

```markdown
## Assumption Test Protocol

**Assumption:** [exact text from discovery-brief.md]
**Test method:** [chosen method from Step 2]
**Pass criterion:** [observable outcome that confirms the assumption]
**Fail criterion:** [observable outcome that refutes the assumption]
**Time budget:** [minutes — must be ≤120]
**Test environment:** [clean install / existing environment / CI / etc.]
```

### Step 4 — Run the test and record raw output

Don't interpret while running. Record exactly what happened, then interpret.

### Step 5 — Update the discovery brief

```markdown
## Assumption Test Result (from assumption-test sub-skill)

**Assumption tested:** [text]
**Test run:** YYYY-MM-DD
**Result:** Confirmed / Refuted / Inconclusive

**What we observed:** [factual description of what happened]

**Interpretation:**

- If confirmed: proceed with the spec as written
- If refuted: [what changes — scope, approach, or decision to not build]
- If inconclusive: [what additional evidence would resolve it, and whether it's worth getting]

**Impact on spec:** [one sentence]
```

## Example Tests for Common uFawkes Assumptions

**"Users will successfully run `docker compose up` without external help"**
→ Test: Fresh VM, no prior knowledge of the repo, follow only README Quick Start. Pass if service is up and healthy check passes in <10 min. Fail if any step requires googling.

**"Grafana dashboard shows data within 60 seconds of `make up`"**
→ Test: Time from `make up` to Grafana panel showing non-empty data. Pass if <60s. Fail if >60s or requires manual steps.

**"The Dojo lab prerequisites are sufficient for a new learner"**
→ Test: Check the 5 most recent GitHub issues or Discussions in the Dojo area for questions about prerequisites. Pass if 0 questions in the last 30 days. Fail if any prerequisite questions found.

**"Tekton pipelines behave equivalently to Jenkins pipelines for the existing test suite"**
→ Test: Run existing test suite through both Tekton and Jenkins. Pass if all tests pass in Tekton. Fail if any test fails that passes in Jenkins. (This is the j-curve-navigation pre-flight check applied here.)

## Output Format

```json
{
  "sub-skill": "discovery/assumption-test",
  "assumption": "string",
  "test_method": "existing-data | prior-art | automated | manual | user-interview",
  "time_spent_minutes": 25,
  "pass_criterion": "string",
  "fail_criterion": "string",
  "result": "confirmed | refuted | inconclusive",
  "observation": "string",
  "spec_impact": "proceed | descope | pivot | cancel",
  "discovery_brief_updated": true
}
```

### persona-deep-dive

# Sub-Skill: Discovery — Persona Deep Dive

> **Load trigger:** `"load discovery/persona-deep-dive skill"` > **DORA:** AI Capability 6: User-centric focus
> **Token cost:** Low
> **When to use:** Persona is ambiguous, or two personas have equally strong claims.

## Purpose

Resolve persona ambiguity before writing a JTBD statement. An ambiguous persona
produces an ambiguous JTBD, which produces an untestable acceptance criterion, which
produces a feature nobody actually needed. Spend 10 minutes here to avoid that cascade.

## The Ambiguity Signals

Run this sub-skill when any of these are true:

- The proposed change description uses "users" generically without naming a role
- Two different personas would use the same feature in fundamentally different ways
- A previous release was under-adopted — the persona assumption may have been wrong
- The change spans multiple stack repos (different stacks have different primary personas)

## Persona Disambiguation Protocol

### Step 1 — List all personas who touch this change

From the discovery skill's Persona Reference Table, identify every persona who
would interact with this change — not just benefit from it. Include:

- Who triggers the change (initiates the action)
- Who is affected by the change (receives the outcome)
- Who configures or maintains the change (ongoing responsibility)

For most uFawkes\* changes, the triggering persona is the most important one.

### Step 2 — Apply the stakes test

For each candidate persona, answer:

| Question                                          | Answer    |
| ------------------------------------------------- | --------- |
| If this change doesn't ship, who is most blocked? | [persona] |
| If this change ships wrong, who is most harmed?   | [persona] |
| Who will file an issue if this breaks?            | [persona] |
| Who has the clearest definition of "done"?        | [persona] |

The persona who answers the most of these questions is the primary persona.

### Step 3 — Check GitHub issue history

```bash
# Find issues filed by users that relate to this area
gh issue list --repo paruff/REPO_NAME --state all --label "user-feedback" \
  --json number,title,body,labels \
  --jq '.[] | {number, title, body: .body[0:200]}'

# Look for patterns: are issues about platform complexity (platform-engineer persona)
# or about golden path gaps (product-engineer persona)?
```

### Step 4 — Check platform-feedback history

If a quarterly platform-feedback survey has been run, check the Q2 "hardest part"
responses for this area. The persona who reported friction is the primary persona.

### Step 5 — State the selection rationale

Write one paragraph:

- Primary persona selected: [name]
- Why: [the stakes-test answer that was clearest]
- Secondary persona: [name] — their needs will be addressed via [how, e.g., "configuration option in v0.2"]
- Conflicting needs: [if any — how the conflict is resolved]

Add this paragraph to `discovery-brief.md` under a "Persona Selection" section.

## Common Ambiguity Patterns and Resolutions

| Ambiguity                                              | Resolution                                                                                                                                                               |
| ------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| "Is this for platform-engineer or product-engineer?"   | Platform-engineer if it changes how the IDP works; product-engineer if it changes what a team can build with it                                                          |
| "Is this a Dojo learner change or platform change?"    | Dojo learner if the primary outcome is learning; platform change if the primary outcome is a running system                                                              |
| "Is this for current users or new users?"              | Current users if it fixes a pain point; new users if it enables adoption. Current users win if unsure — don't break what works to attract people who haven't arrived yet |
| "Is this for fawkes itself or for teams using fawkes?" | fawkes itself = platform-engineer persona; teams using fawkes = product-engineer or team-lead persona                                                                    |

## Output

Append to `discovery-brief.md`:

```markdown
## Persona Selection (from persona-deep-dive sub-skill)

**Candidates considered:** platform-engineer, product-engineer
**Primary persona selected:** platform-engineer
**Selection rationale:** The change modifies how the CI pipeline runs — a concern
the platform-engineer configures, not a concern the product-engineer experiences
directly. Product-engineers are secondary; they benefit from the change but don't
trigger it or define "done."
**Secondary persona:** product-engineer — their need (faster feedback) addressed
via the deployment frequency metric improvement this change enables.
**Conflicting needs:** None identified.
```

## Output Format

```json
{
  "sub-skill": "discovery/persona-deep-dive",
  "candidates_considered": ["platform-engineer", "product-engineer"],
  "primary_persona": "platform-engineer",
  "selection_confidence": "high | medium | low",
  "selection_rationale": "string",
  "secondary_persona": "product-engineer",
  "conflict_identified": false,
  "discovery_brief_updated": true
}
```

### prior-art-search

# Sub-Skill: Discovery — Prior Art Search

> **Load trigger:** `"load discovery/prior-art-search skill"` > **DORA:** AI Capability 5: Working in small batches + AI Capability 3: AI-accessible internal data
> **Token cost:** Low
> **When to use:** End of every discovery session, before writing spec.

## Purpose

"Compose rather than build" is the highest-leverage YAGNI principle in a solo-contributor
portfolio. If the capability already exists — in another uFawkes\* repo, in the Dojo,
or in a well-maintained open-source project — the right move is to integrate it,
not rebuild it.

Spending 15 minutes here can eliminate an entire sprint of unnecessary work.

## Search Layers (run in order — stop when you find a match)

### Layer 1 — Internal: uFawkes\* repos (5 min)

```bash
# Search all local uFawkes* repos for relevant functionality
QUERY="SEARCH_TERM"  # replace with key terms from the JTBD

for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesDORA uFawkesSec uFawkesAI; do
  REPO_PATH="../${repo}"
  [ -d "$REPO_PATH" ] || continue
  echo "=== ${repo} ==="
  # Search README for capability description
  grep -in "${QUERY}" "${REPO_PATH}/README.md" 2>/dev/null | head -3
  # Search any architecture docs
  grep -rin "${QUERY}" "${REPO_PATH}/ARCHITECTURE.md" "${REPO_PATH}/docs/" 2>/dev/null | head -3
  # Search skill files
  grep -rin "${QUERY}" "${REPO_PATH}/.agents/" 2>/dev/null | head -3
done

# Also check the current repo's own test suite and scripts
grep -rn "${QUERY}" tests/ scripts/ .agents/ 2>/dev/null | head -5
```

**Match criteria:** If any repo has a documented feature, skill, or script that
covers >70% of the JTBD, it's prior art. Document it and propose composition.

### Layer 2 — Internal: Dojo content (3 min)

```bash
# Check if this capability is already taught in the Dojo
grep -rin "${QUERY}" docs/dojo/ 2>/dev/null | head -5
# Check ufawkes.dev if accessible
# gh issue list --repo paruff/ufawkes.dev --search "${QUERY}" --state all | head -5
```

If the capability is already in the Dojo, the right move is usually to extend the
existing lab, not create a parallel implementation.

### Layer 3 — GitHub: uFawkes issues and PRs (3 min)

```bash
# Check if this was already proposed, attempted, or closed as won't-fix
for repo in fawkes uFawkesObs uFawkesPipe uFawkesDevX uFawkesAI; do
  gh issue list --repo "paruff/${repo}" --search "${QUERY}" --state all \
    --json number,title,state,labels \
    --jq ".[] | \"[${repo}] #\(.number) [\(.state)]: \(.title)\"" 2>/dev/null
done
```

A closed issue with `wont-fix` or `duplicate` is signal. Understand why before
proposing the same thing again.

### Layer 4 — Open source (4 min)

Search these sources in order. Stop at the first credible match.

```bash
# 1. CNCF landscape (for platform/infra capabilities)
echo "Check: https://landscape.cncf.io/ for [capability]"

# 2. GitHub search for active projects
gh search repos "${QUERY} stars:>100 pushed:>2025-01-01" --limit 5 \
  --json fullName,description,stargazersCount,updatedAt \
  --jq '.[] | "\(.fullName) ★\(.stargazersCount): \(.description)"'

# 3. Known reference implementations for common capabilities
KNOWN_PRIOR_ART=(
  "observability stack: grafana/grafana, prometheus/prometheus, grafana/loki, open-telemetry/opentelemetry-collector"
  "CI pipeline: woodpecker-ci/woodpecker, tektoncd/pipeline"
  "GitOps: fluxcd/flux2, argoproj/argo-cd"
  "CDE: coder/coder, coder/code-server, devcontainers/spec"
  "golden paths: backstage/backstage, roadie-gg/roadie-backstage-plugins"
  "DORA metrics: dora-team/fourkeys, LinearB, Sleuth"
  "security policy: open-policy-agent/opa, kyverno/kyverno"
)
echo "Known prior art for related domains:"
for item in "${KNOWN_PRIOR_ART[@]}"; do echo "  - $item"; done
```

## Composition Decision Matrix

| Finding                                             | Decision                                                                         |
| --------------------------------------------------- | -------------------------------------------------------------------------------- |
| Exact match in uFawkes\* suite                      | **Compose:** use existing skill/feature; open issue to improve it if it has gaps |
| Partial match in uFawkes\* suite                    | **Extend:** build on existing, don't create parallel implementation              |
| Exact match in open source (maintained, MIT/Apache) | **Integrate:** wrap or reference it; document the dependency                     |
| Partial match in open source                        | **Extend or fork:** evaluate maintenance burden before deciding                  |
| No match anywhere                                   | **Build:** proceed to spec; document why existing solutions don't apply          |

## Output Section for Discovery Brief

```markdown
## Prior Art Search (from prior-art-search sub-skill)

**Search terms:** [terms used]
**Date:** YYYY-MM-DD

### Internal (uFawkes\* suite)

- [repo]: [what exists, why it doesn't fully cover the need]
- No match found / [match description]

### Dojo

- [existing module or no match]

### Open source

- [project name + URL]: [what it does, why it does/doesn't fit]
- No credible match found

### Decision

[Build from scratch | Compose with X | Extend X | Integrate X]

**Rationale:** [one sentence — why this is the right composition decision]

**Composition approach:** [if not build-from-scratch — how exactly to use the existing solution]
```

## Output Format

```json
{
  "sub-skill": "discovery/prior-art-search",
  "query_terms": ["string"],
  "internal_matches": [
    {
      "repo": "uFawkesObs",
      "component": "observability skill",
      "coverage": 0.7
    }
  ],
  "dojo_matches": [],
  "open_source_matches": [],
  "decision": "extend | compose | integrate | build",
  "selected_prior_art": "uFawkesObs/observability skill",
  "composition_approach": "string",
  "discovery_brief_updated": true
}
```

## Usage

```bash
# Standard 15-min discovery
load discovery skill

# When assumptions are untested
load discovery/assumption-test skill

# For deep persona work
load discovery/persona-deep-dive skill

# For competitive analysis
load discovery/prior-art-search skill
```

## Enforcement

- **Discovery brief** required before any spec.md
- **DORA vocabulary** validates Capability 6 references
- **AI stance audit** validates user-centric focus
