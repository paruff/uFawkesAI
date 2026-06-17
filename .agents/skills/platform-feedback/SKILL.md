---
name: platform-feedback
description: "Quarterly developer feedback collection and analysis for the fawkes platform. Use to measure whether the IDP actually reduces cognitive load for the product teams using it. Implements DORA AI Capability 7 (Quality internal platforms) — the measurement half."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Platform Feedback

> **Load trigger:** `"load platform-feedback skill"`
> **DORA:** AI Capability 7 (Quality internal platforms)
> **Token cost:** Low

## Purpose

Measure whether the fawkes platform actually delivers on its promise — reduced cognitive
load, faster time-to-running-service, trustworthy golden paths — from the perspective
of the product engineers and Dojo learners who use it.

DORA AI Capabilities Model v2025.1: A quality internal platform provides automated,
secure pathways that allow AI's benefits to scale. Without measurement, "quality" is
self-assessed by the builders. This skill is the mechanism that makes platform quality
externally validated.

**Scope boundary:** This skill collects feedback on the _platform_ from its _users_.
Feedback on the _product_ (what users are building on the platform) is handled by
the `discovery` skill and the learn agent.

## Cadence

| Feedback type       | Frequency                                   | Channel                                   |
| ------------------- | ------------------------------------------- | ----------------------------------------- |
| Quarterly survey    | Every 3 months                              | GitHub Discussion (pinned)                |
| Onboarding feedback | After first golden-path completion          | GitHub Discussion reply or issue          |
| Incident-triggered  | After any platform incident affecting users | GitHub issue (label: `platform-feedback`) |
| Dojo lab feedback   | After each belt completion                  | GitHub Discussion in Dojo repo            |

## The Four Survey Questions

Quarterly feedback uses exactly four questions. Not five. Not ten. Four questions that
a busy developer will actually answer in 3 minutes.

```markdown
## fawkes Platform Feedback — Q[N] YYYY

Thanks for taking 3 minutes to improve the platform.

**1. Task completion**
Did you complete your primary task (deploy a service, run the Dojo lab, set up
observability) without needing help outside the platform documentation?

- [ ] Yes, completely self-serve
- [ ] Yes, but I needed to look something up externally
- [ ] Partially — I got stuck at [describe briefly in comments]
- [ ] No — I couldn't complete it

**2. Hardest part**
What was the hardest or most confusing part of using the platform this quarter?
[Free text — 1-3 sentences]

**3. What to skip**
If you could remove one thing from the platform (docs, step, config, tool), what
would it be and why?
[Free text — 1-2 sentences]

**4. Recommendation**
Would you recommend the fawkes platform to a colleague building a similar system?

- [ ] Yes, without hesitation
- [ ] Yes, with caveats (describe in comments)
- [ ] Not yet — needs improvement first
- [ ] No

**Optional: Your role**

- [ ] Platform engineer
- [ ] Product engineer using golden paths
- [ ] Dojo learner
- [ ] Team lead evaluating fawkes
```

## Metric Mapping (H.E.A.R.T.-inspired)

Map survey responses to platform quality metrics:

| Survey question     | Metric                    | Formula                                              |
| ------------------- | ------------------------- | ---------------------------------------------------- |
| Q1: Task completion | **Task success rate**     | (Yes completely + Yes with lookup) / total responses |
| Q1: Got stuck       | **Task abandonment rate** | (Partially + No) / total responses                   |
| Q4: Recommend       | **NPS proxy**             | (Yes without hesitation) - (No) / total responses    |
| Q2: Hardest part    | **Top friction themes**   | Qualitative — categorize by component                |
| Q3: What to skip    | **Removal candidates**    | Qualitative — prioritize by frequency                |

## Baseline and Targets

| Metric                | Initial baseline | Target (12 months) | Elite benchmark |
| --------------------- | ---------------- | ------------------ | --------------- |
| Task success rate     | Establish in Q1  | >80%               | >90%            |
| Task abandonment rate | Establish in Q1  | <15%               | <5%             |
| NPS proxy             | Establish in Q1  | >40                | >70             |

## GitHub Discussion Template

Create quarterly via:

```bash
# Requires gh CLI with Discussions permissions
gh api graphql -f query='
mutation {
  createDiscussion(input: {
    repositoryId: "REPO_ID"
    categoryId: "CATEGORY_ID"
    title: "fawkes Platform Feedback — Q[N] YYYY"
    body: "[paste four-question survey above]"
  }) {
    discussion { url }
  }
}'
# Pin the discussion after creation
```

## Analysis Protocol

After the feedback window closes (2 weeks after posting):

1. **Tally Q1 and Q4** — compute task success rate and NPS proxy
2. **Categorize Q2 responses** into themes:
   - Documentation gaps
   - Golden path friction (missing steps, unclear config)
   - Tool/dependency issues (installation, version conflicts)
   - Performance issues (slow builds, slow tests)
   - Conceptual gaps (user didn't understand what the platform does)
3. **Count Q3 removal candidates** — anything mentioned by >1 respondent is a signal
4. **Compare to previous quarter** — trend matters more than absolute value

## Output → Plan Agent

Each analysis session produces at most 3 action items for the plan agent:

- One for the highest-friction theme (Q2)
- One for the most-requested removal (Q3)
- One for any metric below target

Each action item filed as a GitHub issue with:

- Label: `platform-feedback`, `capability-improvement`, tier label
- Body: links to specific Discussion responses as evidence
- DORA capability: Cap7 (Quality internal platforms)

## Output Format

```json
{
  "skill": "platform-feedback",
  "quarter": "YYYY-QN",
  "responses": 12,
  "task_success_rate": 0.75,
  "task_abandonment_rate": 0.17,
  "nps_proxy": 33,
  "top_friction_themes": [
    { "theme": "Golden path config unclear", "count": 5 },
    { "theme": "Dojo lab prerequisites missing", "count": 3 }
  ],
  "removal_candidates": [
    { "item": "Manual docker network setup step", "count": 4 }
  ],
  "vs_previous_quarter": {
    "task_success_rate": "+0.08",
    "nps_proxy": "+12"
  },
  "action_items_filed": [42, 43, 44],
  "next_survey_due": "YYYY-MM-DD"
}
```
