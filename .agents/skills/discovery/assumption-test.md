---
name: discovery/assumption-test
description: "Design a lightweight experiment to test the riskiest assumption from the discovery brief before any code is written. Produces a test protocol that fits inside one 2-hour session. Use when the riskiest assumption is behavioral (user will do X) or technical (system can do Y) and the cost of being wrong is high."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: discovery
---

# Sub-Skill: Discovery — Assumption Test

> **Load trigger:** `"load discovery/assumption-test skill"`
> **DORA:** AI Capability 6 (User-centric focus) + AI Capability 5 (Working in small batches)
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
