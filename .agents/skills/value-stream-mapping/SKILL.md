---
name: value-stream-mapping
description: "Map the product value stream to identify bottlenecks consuming AI productivity gains. Use when DORA metrics plateau, when lead time is high despite fast coding, or when planning a major capability investment. Based on DORA AI Capabilities Model v2025.1 VSM chapter. Tier 3: Phase 2."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Value Stream Mapping

> **Load trigger:** `"load value-stream-mapping skill"`
> **DORA:** AI Capability 2 (Healthy data ecosystems) + AI Capability 7 (Quality internal platforms)
> **Token cost:** Medium
> **Prerequisite:** At least one dora-measurement snapshot must exist.

## Purpose

Identify which stage of the product delivery value stream is absorbing the productivity
gains from AI assistance — so investment goes to clearing the actual bottleneck, not
the assumed one.

DORA ROI 2026: "Individual productivity gains from AI are often absorbed by downstream
disorder — gains in coding speed are swallowed by bottlenecks in testing, security reviews,
and complex deployment processes." VSM makes the downstream disorder visible.

**Scope boundary:** This skill maps the _product_ value stream (idea → user value).
The platform value stream (platform change → fawkes improvement → user benefit) is
handled by `fawkes/.agents/skills/value-stream-mapping/` when that skill is written.

## When to Use

| Trigger                                             | Signal                                                                |
| --------------------------------------------------- | --------------------------------------------------------------------- |
| Lead time high despite fast coding                  | `lead_time_p50_hours` > 24hrs but `deployment_frequency_per_week` < 1 |
| DORA metrics plateau                                | Two consecutive monthly snapshots show no improvement                 |
| AI tool adoption not improving throughput           | opencode sessions frequent but deploy frequency unchanged             |
| Planning a major capability                         | Before investing in a new stack (uFawkesDevX, uFawkesDORA)            |
| Measure agent files `capability-improvement` issues | >2 issues in same area in one quarter                                 |

## The Seven Value Stream Stages

Map each stage for the product being built. Time estimates come from DORA measurement
data where available; direct observation otherwise.

| Stage           | Definition                             | Data source                                 |
| --------------- | -------------------------------------- | ------------------------------------------- |
| 1. **Discover** | Idea to validated user need            | discover agent time + learn agent anomalies |
| 2. **Define**   | Validated need to accepted spec        | spec agent sessions                         |
| 3. **Build**    | Spec to passing tests                  | build + test agent sessions (opencode logs) |
| 4. **Review**   | Tests passing to review approved       | PR open to review approved (GitHub API)     |
| 5. **Release**  | Review approved to deployed            | deploy time (uFawkesObs deployment events)  |
| 6. **Verify**   | Deployed to "no regressions confirmed" | change failure rate \* time to detect       |
| 7. **Learn**    | User feedback received to next spec    | platform-feedback cycle time                |

## Mapping Protocol (one session, ~60 min)

### Step 1 — Collect stage times (20 min)

```bash
# Stage 3: Build time (from opencode session logs if available)
# Approximate: time from issue "In Progress" to "tests passing"
gh issue list --repo paruff/REPO_NAME --state closed \
  --json number,title,createdAt,closedAt,labels \
  --jq '.[] | select(.labels[].name == "In Progress") | {number, days_open: ((.closedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 86400}'

# Stage 4: Review time
gh pr list --repo paruff/REPO_NAME --state closed \
  --json number,createdAt,mergedAt \
  --jq '.[] | {number, review_hours: ((.mergedAt | fromdateiso8601) - (.createdAt | fromdateiso8601)) / 3600}'

# Stage 5: Deploy time (from uFawkesObs if wired, else GitHub release timestamps)
gh release list --repo paruff/REPO_NAME --json tagName,publishedAt \
  --jq '.[] | {tag: .tagName, published: .publishedAt}'
```

### Step 2 — Draw the current state map

```
[Discover] → [Define] → [Build] → [Review] → [Release] → [Verify] → [Learn]
  ?hrs          ?hrs      ?hrs      ?hrs        ?hrs         ?hrs       ?days

Value-add time:  [  ] hrs
Total lead time: [  ] hrs
Efficiency:      [  ]%  (value-add / total)
```

For each stage, note:

- **Process time** (time spent actively working)
- **Wait time** (time waiting for something external — review, CI, feedback)
- **Rework time** (time fixing failures at this stage)

### Step 3 — Identify the biggest bottleneck

Apply Little's Law intuitively: the stage with the longest _wait time_ (not process time)
is the constraint. AI assistance addresses process time; wait time is a system problem.

Common bottleneck patterns in solo-entrepreneur IDP work:

| Pattern                                        | Root cause                      | Intervention                                           |
| ---------------------------------------------- | ------------------------------- | ------------------------------------------------------ |
| Review stage is the bottleneck                 | No reviewers — solo contributor | Automate review with review agent + code-quality skill |
| Release stage is the bottleneck                | Manual release steps            | Automate with release skill                            |
| Verify stage is the bottleneck                 | Thin test suite, high CFR       | j-curve-navigation + test investment                   |
| Learn stage is the bottleneck                  | No feedback mechanism           | platform-feedback skill + quarterly cadence            |
| Build stage is the bottleneck despite AI tools | Context re-discovery tax        | context-engineering skill + graphify                   |

### Step 4 — Design the future state

For the top bottleneck, propose one intervention:

- What is the target stage time after the intervention?
- Which DORA metric improves and by how much?
- Which skill or agent implements the intervention?
- What is the estimated investment (sessions at 2hrs each)?

### Step 5 — Update the plan agent

File one GitHub issue per identified bottleneck intervention:

- Label: `value-stream`, `capability-improvement`, tier label
- Body: current state time, target state time, DORA metric impact, intervention

## Output Format

```json
{
  "skill": "value-stream-mapping",
  "date": "YYYY-MM-DD",
  "product": "REPO_NAME",
  "stages": {
    "discover": { "process_hours": 0.5, "wait_hours": 0, "rework_hours": 0 },
    "define": { "process_hours": 1.0, "wait_hours": 0, "rework_hours": 0.5 },
    "build": { "process_hours": 4.0, "wait_hours": 0, "rework_hours": 1.0 },
    "review": { "process_hours": 0.5, "wait_hours": 24.0, "rework_hours": 0 },
    "release": { "process_hours": 2.0, "wait_hours": 0, "rework_hours": 0 },
    "verify": { "process_hours": 0.5, "wait_hours": 4.0, "rework_hours": 0 },
    "learn": { "process_hours": 1.0, "wait_hours": 720.0, "rework_hours": 0 }
  },
  "total_lead_time_hours": 759.0,
  "value_add_time_hours": 9.5,
  "efficiency_pct": 1.25,
  "primary_bottleneck": "learn",
  "primary_bottleneck_type": "wait",
  "intervention": "platform-feedback quarterly cadence + learn agent monthly",
  "dora_metric_target": "lead_time_p50_hours",
  "current_value": 759.0,
  "target_value": 36.0,
  "investment_sessions": 2,
  "issues_filed": [55, 56]
}
```
