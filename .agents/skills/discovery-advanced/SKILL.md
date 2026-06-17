---
name: discovery-advanced
description: "Full user research methods for uFawkes product decisions. Use when the 15-minute discovery exercise is insufficient — when the riskiest assumption is untested, when user segments disagree, or when a major capability is being designed from scratch. Tier 3: Phase 2."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Discovery Advanced

> **Load trigger:** `"load discovery-advanced skill"` > **DORA:** AI Capability 6 (User-centric focus)
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

When a previous release didn't get adopted. Use the learn agent's discovery accuracy
record as the starting point.

```markdown
## Assumption Autopsy — [RELEASE_VERSION]

1. Original riskiest assumption: [from discovery-brief.md]
2. Was it validated before building? [Yes / No / Partially]
3. What actually happened after release: [from learn agent retrospective]
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
Each theme with >2 data points becomes a plan agent action item.

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
