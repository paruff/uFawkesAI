---
name: learn
description: "Product retrospective. Runs after a release, after a /measure anomaly flag, or at end of sprint. Maps findings to DORA AI capabilities and produces action items for @planner. Distinct from fawkes learn.md which handles platform incident postmortems."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  migrated_from: agent/learn
---

# Skill: Learn

> **Load trigger:** `"load learn skill"`
**Invoke when:** Post-release review, `/measure` command anomaly flag, sprint end, or user feedback received. > **DORA:** AI Capability 6: User-centric focus + Cultural: Learning from failures > **Token cost:** Low

> Migrated from the former `learn` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

> **Invoke when:** Post-release review, `/measure` command anomaly flag, sprint end, or user feedback received.
> **DORA:** AI Capability 6: User-centric focus + Cultural: Learning from failures
> **Token cost:** Low
> **Output:** `retrospective-YYYY-MM-DD.md` + action items for `@planner`

## Purpose

Close the product improvement loop. Translate delivery experience and metric signals
into DORA capability gaps, then into concrete `@planner` inputs. Keeps the suite
self-improving rather than self-repeating.

**Scope boundary:** This agent handles _product_ retrospectives — what did we learn
about the product, user needs, and team effectiveness? Platform incident postmortems
(what failed in the IDP infrastructure and why) are handled by `fawkes/.agents/agents/learn.md`.
If an incident affected both product and platform, run both agents and cross-reference outputs.

## Trigger Conditions

| Trigger                    | Source                                               | Priority                      |
| -------------------------- | ---------------------------------------------------- | ----------------------------- |
| `/measure` anomaly flag     | `dora-regression` GitHub issue                       | High — run within 48hrs       |
| Post-release review        | Filed by release agent                               | Medium — run within 1 week    |
| Sprint end                 | Weekly cadence                                       | Low — run Friday of each week |
| User feedback received     | Issue labeled `user-feedback` or `platform-feedback` | Medium                        |
| Dojo learner stuck         | Issue or discussion flagged in Dojo repo             | Medium                        |

## Pre-conditions

- [ ] Load `discovery` skill (for persona reference): `"load discovery skill"`
- [ ] Gather inputs: dora-snapshot for the period, release agent output, any user feedback issues
- [ ] Previous retrospective loaded for trend awareness (warn if none exists — first run)

## Responsibilities

### Phase 1 — Gather signals (10 min)

Collect all available signals from the period under review:

| Signal type              | Source                                | What to look for                         |
| ------------------------ | ------------------------------------- | ---------------------------------------- |
| DORA metrics             | `dora-snapshot-YYYY-MM.json`          | Regressions, stalled improvements        |
| Release outcome          | Release agent output                  | Blockers encountered, manual steps taken |
| User feedback            | GitHub issues labeled `user-feedback` | Pain points, feature requests            |
| Dojo engagement          | Dojo repo discussions/issues          | Where learners got stuck                 |
| Discovery brief accuracy | `discovery-brief.md` from the period  | Was the riskiest assumption wrong?       |
| AI assistance quality    | opencode session logs (if available)  | Where agent help was insufficient        |

### Phase 2 — Identify findings (15 min)

For each signal, produce a finding:

```
Finding format:
- What happened: [one sentence, factual]
- Impact: [who was affected and how]
- DORA capability gap: [which of the 7 AI capabilities or core DevOps capabilities this reveals]
- Recurrence risk: High / Medium / Low
```

Cap findings at 5 per retrospective. If more than 5 signals exist, prioritize by
recurrence risk then by DORA capability impact. A 15-minute retrospective with
3 good findings beats a 2-hour one with 15 marginal ones.

### Phase 3 — Map to DORA capabilities

For each finding, identify the DORA AI Capability or Core DevOps Capability it reveals
a gap in. Use this to frame the action item — not as "fix the bug" but as
"improve capability X so this class of problem doesn't recur."

| Finding type                                       | Likely capability gap                                               |
| -------------------------------------------------- | ------------------------------------------------------------------- |
| User adopted the feature differently than expected | AI Capability 6: User-centric focus                                           |
| AI-generated code introduced a regression          | AI Capability 4: Strong version control practices / AI Capability 5: Working in small batches                |
| Metric data was unavailable or stale               | AI Capability 2: Healthy data ecosystems                                      |
| Agent didn't have enough internal context          | AI Capability 3: AI-accessible internal data                                  |
| Release took longer than 2hrs                      | Core: CD / `release` skill needs improvement                        |
| Dojo learner couldn't complete a lab               | Dojo content quality / AI Capability 7: Quality internal platforms                      |
| Riskiest assumption was wrong                      | AI Capability 6: User-centric focus — `discover` skill needs earlier validation |

### Phase 4 — Produce action items for `@planner`

Each finding produces at most one action item. An action item must be:

- Small enough to complete in one 2-hour session
- Phrased as a GitHub issue title (`type(scope): description`)
- Tagged with the DORA capability it improves
- Assigned a tier (1 = this week, 2 = next 2 weeks, 3 = Phase 2)

### Phase 5 — Update the discovery brief accuracy record

Compare the `riskiest_assumption` from the most recent `discovery-brief.md` against
what actually happened. Was it right? Wrong? Partially right?

This feedback improves the `discover` skill's assumption-surfacing quality over time.
Log in `retrospective.md` under "Discovery accuracy."

## Output Format

```json
{
  "agent": "learn",
  "type": "product-retrospective",
  "date": "YYYY-MM-DD",
  "period": "YYYY-MM-DD to YYYY-MM-DD",
  "trigger": "post-release | anomaly | sprint-end | user-feedback",
  "signals_reviewed": 4,
  "findings": [
    {
      "id": 1,
      "what_happened": "string",
      "impact": "string",
      "dora_capability_gap": "string",
      "recurrence_risk": "High | Medium | Low"
    }
  ],
  "action_items": [
    {
      "issue_title": "feat(discovery): add assumption-validation step before spec",
      "dora_capability": "6: User-centric focus",
      "tier": 2,
      "gh_issue_number": null
    }
  ],
  "discovery_accuracy": {
    "assumption_stated": "string",
    "assumption_correct": true,
    "notes": "string"
  },
  "plan_agent_notified": true,
  "retrospective_path": "retrospectives/retrospective-YYYY-MM-DD.md"
}
```

## Success Criteria

- [ ] All available signals reviewed
- [ ] ≤5 findings produced, each with DORA capability gap named
- [ ] Each finding has one action item (or explicit "no action needed")
- [ ] Action items filed as GitHub issues with correct labels and tier
- [ ] Discovery brief accuracy logged
- [ ] `@planner` notified via issue labels (`capability-improvement`, tier label)
- [ ] `retrospective-YYYY-MM-DD.md` written to `retrospectives/` directory

### 5. Token Budget (from token-budget skill)

# Skill: Token Budget

> **Load trigger:** `"load token-budget skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low (meta: about token cost itself)

## Purpose

Audit and manage the token footprint of agent sessions to stay within
AGENTS.md §4 budget protocols and avoid runaway Copilot billing.

## Token Cost Tiers (approximate — verify with current billing)

| Tier        | Use                                   | Context size   |
| ----------- | ------------------------------------- | -------------- |
| Low         | Routing, quick lookups, preflight     | < 8K tokens    |
| Medium      | Feature implementation, docs          | 8K–20K tokens  |
| High        | Complex refactors, full file rewrites | 20K–32K tokens |
| Over-budget | Multi-file architectural changes      | > 32K tokens   |

Note: these are approximate estimates. Actual token counts depend on model,
context management, and billing plan. Verify current rates at github.com/features/copilot
and anthropic.com/pricing before planning large agent workloads.

## Context Footprint Sources (in descending size order)

1. AGENTS.md (always-on) — target: ≤ 88 lines ≈ ~2K tokens
2. Loaded skill files — each ≈ 500–800 tokens
3. Files read from context index — varies by file size
4. Conversation history — grows each turn
5. PR diff being reviewed — varies

## Audit Protocol

Before a long session, estimate context size:

```bash
# Count lines in always-on context
wc -l AGENTS.md .agents/README.md

# Estimate token count (rough: 1 line ≈ 20–25 tokens)
echo "Estimated always-on tokens: $(($(wc -l < AGENTS.md) * 25))"

# Check which skills are loaded in this session
# (manual tracking — list them here)
```

## Cost Control Strategies

**Strategy 1 — Keep AGENTS.md lean**
Every line added to AGENTS.md costs tokens on every agent turn.
The 88-line target is a billing control, not just an aesthetic preference.
Offload project-specific details to skill files loaded on demand.

**Strategy 2 — Scope context files**
Do not read entire files when only a section is needed.
Instruct agents: "Read only the `services/` section of AGENTS.md §3"
rather than loading the full context index.

**Strategy 3 — One skill at a time**
Load only the skill file needed for the current task.
Do not pre-load all skills at session start.

**Strategy 4 — Checkpoint long sessions**
For sessions likely to exceed 20K tokens, create a checkpoint issue:
"Continue from: [state summary]" and start a fresh session.
Small local models will drift on chains > 4–5 steps — verify context window and behavior for your specific model.

**Strategy 5 — Use the right model**

- Routing, preflight, quick checks → small local model
- Complex code generation → hosted agent, mid/frontier tier
- Orchestration and planning → Claude Code via Anthropic API
- Never use Copilot Business for simple lookups — it costs per token.

## Weekly Token Audit

Run `npm run token-audit` (scripts/token-audit.sh) to see:

- Sessions in the last 7 days
- Estimated token cost per session
- Sessions that exceeded budget threshold
- Most expensive files by inclusion frequency

Report is written to `docs/METRICS.md` under the token-usage section.

### 6. Agent Observability (from agent-observability skill)

# Skill: Agent Observability

> **Load trigger:** `"load agent-observability skill"` > **DORA:** Core: Observability + Core: Reliability
> **Token cost:** Low

## Purpose

Instrument the agent system itself with the same observability standards applied to application code. Agent actions become observable, measurable, and improvable.

## Agent Telemetry Span Types

| Span Name                    | When to Emit                      | Attributes                                                   |
| ---------------------------- | --------------------------------- | ------------------------------------------------------------ |
| `agent.invocation.started`   | Agent begins its task             | `agent.name`, `session_id`, `mode`                           |
| `agent.skill.loaded`         | Skill file is loaded for context  | `skill.name`, `skill.domain`                                 |
| `agent.finding.produced`     | A finding is identified           | `severity`, `category`, `actionable`, `manual_review_needed` |
| `agent.decision.made`        | Agent produces its final decision | `decision`, `blocker_count`, `finding_count`                 |
| `agent.invocation.completed` | Agent finishes its task           | `duration_ms`, `total_skills_loaded`, `total_findings`       |
| `agent.invocation.failed`    | Agent encounters an error         | `error`, `stage`                                             |

## Relation to Phase 0 Logging

Phase 0 logs (`.agents/logs/YYYY-MM-DD.jsonl`) are the data source. Agent telemetry spans are the OTEL representation of the same events.

Mapping:

- `agent.invocation.started` + `agent.invocation.completed` → one log entry
- `agent.skill.loaded` → `skills_loaded[]` array in log entry
- `agent.finding.produced` → each item in `findings[]` array
- `agent.decision.made` → `decision` and `blockers` fields

## Sub-Skills

| Skill                                     | Purpose                                     |
| ----------------------------------------- | ------------------------------------------- |
| `agent-observability/invocation-tracking` | Track agent start, completion, and duration |
| `agent-observability/skill-load-events`   | Track which skills are loaded and how often |
| `agent-observability/finding-quality`     | Measure finding actionability and accuracy  |
| `agent-observability/decision-logging`    | Log agent decisions for post-hoc analysis   |

### 7. Dojo Feedback (from dojo-feedback skill)

# Skill: Dojo Feedback

> **Load trigger:** `"load dojo-feedback skill"` > **DORA:** AI Capability 7: Quality internal platforms + Core: Learning culture
> **Token cost:** Low

## Purpose

Close the Dojo learning loop (`docs/ai-sdlc/dojo-handoff.md`):

```
intent.md → spec.md → plan.md → code → Dojo lab → dojo-feedback.md → new intent.md
```

A lab built from a feature's `plan.md` (exercise) and `spec.md` (rubric) is
the first time someone who did not build the feature has to make it work.
Wherever they got stuck, the guardrails, prompts, spec, plan, or lab missed
something. This skill captures those gaps as evidence and packages them as a
proposed intent, so the next cycle fixes them.

**Scope boundary:** feedback about the _platform_ from its users is
`platform-feedback`; authoring/verifying Dojo modules is `dojo-content`.
This skill is only the lab → feedback → intent step.

## When to Run

| Situation                                                  | Run? |
| ---------------------------------------------------------- | ---- |
| A cohort (or one facilitator run) completed a handed-off lab | Yes  |
| `validate.sh` failed for a learner on a rubric check        | Yes  |
| A learner needed help outside the lab instructions          | Yes  |
| Lab completed cleanly, nobody got stuck, no gaps            | Yes — record "no gaps"; do **not** invent any. CI opens no issue without a gap. |

## Inputs (read before writing)

1. The lab in uFawkesDojo: `instructions.md`, `validate.sh`, `solution/`.
2. Every learner's `validate.sh` output (the per-check PASS/FAIL lines).
3. Facilitator/learner notes: where they stalled, what they asked, what they
   looked up outside the lab.
4. The source chain in uFawkesAI: `docs/ai-sdlc/<feature>/intent.md`,
   `spec.md`, `plan.md` (the lab header names the feature and commit).
5. The guardrails and prompts the feature was built under: `AGENTS.md`,
   `.agents/skills/{spec,design,build}/SKILL.md`, hooks
   (`scripts/hooks/protected-paths.json`), CI gates (`.github/workflows/`).

## Gap Types

Classify each gap by where the fix belongs — this decides who acts on it:

| Type        | Meaning                                                              | Typical fix location                       |
| ----------- | -------------------------------------------------------------------- | ------------------------------------------ |
| `guardrail` | A hook, CI gate, or policy let something wrong through (or blocked something right) | `scripts/hooks/`, `.github/workflows/`, `AGENTS.md` (human) |
| `prompt`    | An agent prompt or skill produced an artifact that misled the learner | `.agents/agents/*.md`, `.agents/skills/`   |
| `spec`      | An acceptance criterion was ambiguous, untestable, or missing        | the feature's `spec.md` (via a new intent) |
| `plan`      | The Verification Strategy didn't actually prove the AC               | the feature's `plan.md`                    |
| `lab`       | Only the lab's wording/setup was wrong — the feature was fine        | uFawkesDojo (fix there; no intent needed)  |

A gap is only real with **evidence**: a failing check line, a quoted
learner question, a command that didn't behave as the lab said. No
evidence, no gap.

## Output — `docs/ai-sdlc/<feature>/dojo-feedback.md`

Write it next to the source chain, on a branch, and open a PR. The format
is parsed by `scripts/dojo-feedback-intent.sh` — keep the front matter keys,
headings, and `GAP-NN` bullets exactly as shown.

````markdown
---
lab: white-belt/module-03-delivery-events/lab-01   # path in paruff/uFawkesDojo
lab_ref: <uFawkesDojo commit or PR URL>
source_feature: docs/ai-sdlc/<feature>
source_commit: <uFawkesAI commit the lab was built from>
completed_at: YYYY-MM-DD
learners: <number>
proposed_feature: <kebab-case slug for the new docs/ai-sdlc/<slug>/intent.md>
---

# Dojo Feedback: <feature>

## Lab Results

| AC    | Rubric check (validate.sh) | Passed | Failed | Notes |
| ----- | -------------------------- | ------ | ------ | ----- |
| AC-01 | ...                        | 3      | 0      |       |

## Gaps

### GAP-01: <short title>

- **Type:** guardrail | prompt | spec | plan | lab
- **Evidence:** <failing check line, quoted question, observed behaviour>
- **Affected:** `<path>`
- **Proposed change:** <what should change>
- **Severity:** high | medium | low

## Proposed Intent

### Problem

<Why the next cycle is needed, citing GAP-NN ids.>

### Desired outcome

<What "fixed" looks like, testable.>

### Out of scope

- <Explicitly excluded>
````

If there are no gaps, keep `## Gaps` with the single line `None.` and write
`None — no follow-up cycle needed.` under `### Problem`; CI then opens no
issue.

## What happens next (automated)

1. Merging the PR to `main` runs `.github/workflows/dojo-feedback-intent.yml`,
   which validates the file and opens an issue labelled **`intent`** with the
   gaps and a ready-to-commit draft of
   `docs/ai-sdlc/<proposed_feature>/intent.md`.
2. Someone commits that `intent.md` in a PR whose body says `Closes #<issue>`
   — the cycle restarts at the `spec` stage.
3. The issue is due **one sprint** after it opens (7 days by default; repo
   variable `DOJO_SPRINT_DAYS`). A daily check labels it `intent-overdue` and
   comments if it is still open after that.

## Validation

```bash
scripts/dojo-feedback-intent.sh docs/ai-sdlc/<feature>/dojo-feedback.md --out-dir /tmp/dojo
```

Exit 0 = well-formed (and `/tmp/dojo/{issue-title.txt,issue.md,intent.md}`
show exactly what CI will open). Fix any reported problem before opening the PR.

## Hard Rules

- Never record a gap without evidence from the lab run.
- Never invent gaps to justify a new cycle — "None." is a valid result.
- Never edit `AGENTS.md` to fix a `guardrail` gap; propose it for a human.
- `lab`-type gaps are fixed in uFawkesDojo; they do not need an intent unless
  they reveal a gap of another type too.

### 8. DOJO Content (from DOJO-content skill)

# Skill: DOJO Content

> **Load trigger:** `"load dojo-content skill"` > **DORA:** AI Capability 3: AI-accessible internal data
> **Token cost:** Low

## Purpose

Create educational content for DOJO sessions focused on platform engineering best practices, DORA metrics, and developer experience.

## When to Run

| Situation                                  | Run DOJO content? |
| ------------------------------------------ | ----------------- |
| New platform capability launched           | Yes               |
| DORA metrics show regression               | Yes               |
| Developer feedback indicates knowledge gap | Yes               |
| Quarterly DOJO session scheduled           | Yes               |

## Content Structure

```markdown
## Title

[One-line description]

## Learning Objective

[What developers will know/do after this session]

## Prerequisites

- [Required knowledge]

## Content

[Main material - 500-1000 words]

## Hands-on Exercise

[Practical activity]

## Key Takeaways

- [3-5 bullet points]
```

## Output Format

```json
{
  "skill": "dojo-content",
  "topic": "string",
  "target_audience": "string",
  "content_path": "dojo/YYYY-MM-DD-topic.md",
  "slides_path": "dojo/slides/YYYY-MM-DD-topic.md",
  "exercise_path": "dojo/exercises/YYYY-MM-DD-topic.md"
}
```

### 9. DOJO Sub-skills

- Audit: # Sub-Skill: Dojo Content — Audit

> **Load trigger:** `"load dojo-content/audit skill"` > **DORA:** AI Capability 7: Quality internal platforms
> **Token cost:** Low
> **When to use:** Learner reports a broken lab, new belt release, or quarterly Dojo maintenance.

## Purpose

Verify that every published Dojo module meets the 7-section gold standard from the
parent `dojo-content` skill. A module that doesn't run on a clean environment, has
no evidence artifact, or is missing a DORA capability mapping is not ready to publish —
regardless of how well-written the prose is.

## Audit Checklist (per module)

### Section 1: Module Header

- [ ] Frontmatter present and complete: `belt`, `module`, `title`, `duration`, `dora_ai_capability`, `dora_core_capability`, `lab_stack`, `prerequisite_modules`, `lab_verified`
- [ ] `lab_verified` date is within the last 6 months
- [ ] `duration` is realistic (≤ 120 min for a single lab)

### Section 2: Why This Matters

- [ ] Present (not missing, not stub)
- [ ] Contains at least one DORA research citation with year
- [ ] States concrete consequence of not having the capability

### Section 3: What You'll Build

- [ ] States a specific, concrete deliverable (not "understand X")
- [ ] Deliverable is verifiable by the evidence artifact in Section 6

### Section 4: Prerequisites

- [ ] Lists all required prior modules by belt/number
- [ ] Lists all tools with install commands
- [ ] Time estimate present

### Section 5: The Lab

- [ ] Steps are numbered
- [ ] Every command is in a code block
- [ ] Checkpoints every 3-5 steps
- [ ] Each checkpoint states expected output AND what to do if it doesn't match
- [ ] No step requires credentials the learner won't have

### Section 6: Evidence of Completion

- [ ] Evidence artifact type defined (screenshot / URL / JSON output / file)
- [ ] Evidence artifact is produceable by following the lab steps
- [ ] Evidence is binary-verifiable (either present or not — no "looks about right")

### Section 7: What's Next

- [ ] Links to next module
- [ ] Links to the uFawkes\* repo implementing this capability in production
- [ ] One external "dig deeper" resource (link verified not broken)

## Audit Script

````bash
#!/usr/bin/env bash
# Run from the repo root
# Usage: bash .agents/skills/dojo-content/audit/run-audit.sh [module-path]

MODULE_PATH="${1}"
[ -z "$MODULE_PATH" ] && echo "Usage: $0 <path/to/module.md>" && exit 1
[ -f "$MODULE_PATH" ] || { echo "Module not found: $MODULE_PATH"; exit 1; }

echo "# Dojo Module Audit — $(basename $MODULE_PATH)"
echo "Date: $(date +%Y-%m-%d)"
echo ""

FAIL=0

# Section 1 — Frontmatter
echo "## Section 1: Module Header"
for field in belt module title duration dora_ai_capability lab_stack lab_verified; do
  if grep -q "^${field}:" "$MODULE_PATH"; then
    echo "✅ $field present"
  else
    echo "❌ $field missing from frontmatter"
    FAIL=1
  fi
done

# lab_verified recency
LAB_VERIFIED=$(grep "^lab_verified:" "$MODULE_PATH" | grep -oE "[0-9]{4}-[0-9]{2}-[0-9]{2}" || echo "")
if [ -n "$LAB_VERIFIED" ]; then
  DAYS=$(python3 -c "from datetime import datetime; \
    print((datetime.utcnow() - datetime.strptime('${LAB_VERIFIED}', '%Y-%m-%d')).days)")
  [ "$DAYS" -gt 180 ] && echo "⚠  lab_verified is ${DAYS} days old — re-verify recommended" \
                       || echo "✅ lab_verified is ${DAYS} days old"
fi
echo ""

# Section 2 — Why This Matters
echo "## Section 2: Why This Matters"
grep -q "## Why\|## Why This\|## The Problem" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
grep -qi "DORA\|dora\|state of devops" "$MODULE_PATH" \
  && echo "✅ DORA citation found" || echo "⚠  No DORA citation found"
echo ""

# Section 3 — What You'll Build
echo "## Section 3: What You'll Build"
grep -q "## What You'll Build\|## What You Will Build\|## Outcome" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
# Anti-pattern: "understand" or "learn about" suggests non-concrete deliverable
grep -iE "you will (understand|learn about|explore|get familiar)" "$MODULE_PATH" \
  && echo "⚠  Possible non-concrete deliverable — check 'What You'll Build' section"
echo ""

# Section 4 — Prerequisites
echo "## Section 4: Prerequisites"
grep -q "## Prerequisites\|## Before You Start\|## Requirements" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Section 5 — The Lab
echo "## Section 5: The Lab"
STEP_COUNT=$(grep -cE "^[0-9]+\." "$MODULE_PATH" || echo 0)
CHECKPOINT_COUNT=$(grep -ci "you should see\|expected output\|checkpoint\|verify\|✅" "$MODULE_PATH" || echo 0)
CODE_BLOCK_COUNT=$(grep -c '```' "$MODULE_PATH" || echo 0)
echo "  Steps found: ${STEP_COUNT}"
echo "  Code blocks found: $((CODE_BLOCK_COUNT / 2))"
echo "  Checkpoint signals found: ${CHECKPOINT_COUNT}"
[ "$STEP_COUNT" -gt 0 ] && echo "✅ Has numbered steps" || { echo "❌ No numbered steps"; FAIL=1; }
[ "$CODE_BLOCK_COUNT" -gt 0 ] && echo "✅ Has code blocks" || { echo "⚠  No code blocks — commands should be in code blocks"; }
[ "$CHECKPOINT_COUNT" -gt 0 ] && echo "✅ Has checkpoints" || { echo "❌ No checkpoints found"; FAIL=1; }
echo ""

# Section 6 — Evidence of Completion
echo "## Section 6: Evidence of Completion"
grep -q "## Evidence\|## Proof\|## Verification\|## You're Done" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Section 7 — What's Next
echo "## Section 7: What's Next"
grep -q "## What's Next\|## Next Steps\|## Continue" "$MODULE_PATH" \
  && echo "✅ Present" || { echo "❌ Missing"; FAIL=1; }
echo ""

# Summary
echo "## Audit Result"
if [ $FAIL -eq 0 ]; then
  echo "✅ PASS — Module meets gold standard"
else
  echo "❌ FAIL — Module has required gaps (see above)"
fi
exit $FAIL
````

## Output Format

```json
{
  "sub-skill": "dojo-content/audit",
  "module_path": "docs/dojo/white-belt/module-01.md",
  "belt": "white",
  "module": 1,
  "lab_verified_days_ago": 45,
  "sections_present": [1, 2, 3, 4, 5, 6, 7],
  "sections_missing": [],
  "warnings": ["No DORA citation found in Why This Matters"],
  "audit_passed": true,
  "issues_to_file": 0
}
```
- Lab Verify: # Sub-Skill: Dojo Content — Lab Verify

> **Load trigger:** `"load dojo-content/lab-verify skill"` > **DORA:** AI Capability 7: Quality internal platforms + Core: Test automation
> **Token cost:** Low
> **When to use:** Before publishing any new or updated module. Required — not optional.

## Purpose

A module that doesn't work on a clean environment is worse than no module —
it erodes trust and causes learners to abandon the Dojo. This sub-skill is the
quality gate. Every module must pass lab verification before `lab_verified` is set.

**The rule:** If the lab fails verification, fix it before setting `lab_verified`.
No exceptions. No "it mostly works." The learner will hit the same failure you hit.

## Verification Environment Requirements

The lab must be verified from a state that approximates a learner's first encounter:

| Requirement                                       | Why                                                   |
| ------------------------------------------------- | ----------------------------------------------------- |
| Clean directory (no prior runs of this lab)       | Eliminates "works because cache exists" failures      |
| Only prerequisite tools installed (nothing extra) | Learner may not have additional tools                 |
| No existing config files from previous sessions   | Real first-run experience                             |
| Recorded in a new terminal with timing            | Produces the evidence artifact for the module         |
| Same OS as stated in Prerequisites                | Mac ARM, Linux x86, etc. — matters for Docker/compose |

Fastest way to achieve this: a new Docker container, a fresh VM snapshot, or
a new Coder/VS Code Server workspace from a base image.

## Verification Protocol

### Step 1 — Pre-verification setup (5 min)

```bash
# Record start time
VERIFY_START=$(date +%s)
VERIFY_DATE=$(date +%Y-%m-%d)

# Confirm clean environment
echo "=== Environment check ==="
echo "OS: $(uname -a)"
echo "Docker: $(docker --version 2>/dev/null || echo 'not installed')"
echo "Compose: $(docker compose version 2>/dev/null || echo 'not installed')"
echo "git: $(git --version)"
# Add other prerequisite checks based on the module

# Confirm no leftover state
docker ps -a | grep -i "MODULE_NAME" && echo "⚠ Found existing containers — remove before verifying"
```

### Step 2 — Follow the module exactly as written (no shortcuts)

Do not:

- Skip steps because "obviously that will work"
- Use credentials or config you happen to have
- Fix things inline without noting them

Do:

- Time each step with `time` or manually
- Record every command that fails — even if you know the fix
- Record every place where you needed to look something up externally

### Step 3 — Record the verification run

```bash
# Create a verification log
cat > /tmp/lab-verify-log.md << EOF
# Lab Verification Log — [MODULE TITLE]
Date: ${VERIFY_DATE}
Verifier: paruff
Environment: [OS, relevant tool versions]

## Step-by-step timing

| Step | Expected time | Actual time | Result | Notes |
|---|---|---|---|---|
| 1 | X min | Y min | ✅/❌ | |
| 2 | X min | Y min | ✅/❌ | |

## Issues found
[List every failure, confusion, or external lookup required]

## Evidence artifact produced
[Description of what was produced — screenshot taken, URL accessed, JSON output]

## Total time
Expected: [stated in module] min
Actual: [measured] min
Variance: [Actual - Expected] min ([percentage]% over/under)
EOF
```

### Step 4 — Evaluate pass/fail

| Outcome                                                    | Action                                                                    |
| ---------------------------------------------------------- | ------------------------------------------------------------------------- |
| All steps complete, evidence produced, no external lookups | ✅ PASS — set `lab_verified` date                                         |
| Steps complete but required one external lookup            | ⚠ CONDITIONAL — update module to include the missing info, then re-verify |
| Any step failed                                            | ❌ FAIL — fix the module, do not set `lab_verified` until re-verified     |
| Actual time > 120% of stated time                          | ❌ FAIL — update time estimate and re-verify                              |

### Step 5 — Update the module

If PASS:

```bash
# Update lab_verified date in frontmatter
sed -i "s/^lab_verified:.*/lab_verified: ${VERIFY_DATE}/" MODULE_PATH

# If time estimate changed, update duration
# sed -i "s/^duration:.*/duration: ACTUAL_MINUTES min/" MODULE_PATH

git add MODULE_PATH
git commit -m "docs(dojo): verify lab $(basename MODULE_PATH) — lab_verified ${VERIFY_DATE}"
```

If FAIL: fix issues, then run verification again from Step 1.

## Evidence Artifact Record

After a successful verification, add this block to the module's Section 6:

```markdown
## Evidence of Completion

To confirm you've completed this lab successfully:

**Expected output:**
[Paste actual output from your verification run — not what you think it should be]

**Screenshot target:**
[Describe exactly what should be visible — which URL, which panel, which metric]

**Verification command:**
\`\`\`bash

# Run this to self-check your completion

[command that produces binary pass/fail output]
\`\`\`
```

## Output Format

```json
{
  "sub-skill": "dojo-content/lab-verify",
  "module": "docs/dojo/white-belt/module-01.md",
  "verification_date": "YYYY-MM-DD",
  "environment": "Ubuntu 24.04, Docker 26.1, Compose v2.27",
  "result": "pass | fail | conditional",
  "steps_passed": 12,
  "steps_failed": 0,
  "external_lookups_required": 0,
  "expected_duration_minutes": 60,
  "actual_duration_minutes": 58,
  "evidence_artifact_produced": true,
  "issues_found": [],
  "module_updated": true,
  "lab_verified_date_set": "YYYY-MM-DD"
}
```
