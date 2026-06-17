---
name: roi-reporting
description: "Monthly DORA ROI snapshot using the 2026 DORA ROI report five-dimension framework. Use when producing board-readable ROI evidence, quarterly LinkedIn posts, or Dojo 'proof it works' content. Requires dora-measurement snapshot. Tier 3: Phase 2."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: ROI Reporting

> **Load trigger:** `"load roi-reporting skill"`
> **DORA:** AI Capability 2 (Healthy data ecosystems) + AI Capability 7 (Quality internal platforms)
> **Token cost:** Low–Medium
> **Prerequisite:** `dora-measurement` snapshot for the period must exist.

## Purpose

Translate DORA metric numbers into business language that answers the question
every stakeholder actually asks: "Is this platform investment worth it?"

DORA ROI 2026: ROI is measured by how much latent human creativity is unlocked by
offloading systemic toil — not by headcount reduction. This skill operationalizes
that framing into a one-page monthly report and a quarterly content piece.

## The Five ROI Dimensions (2026 DORA Report)

| Dimension                | What it measures                            | Primary DORA metric driver       |
| ------------------------ | ------------------------------------------- | -------------------------------- |
| **Cost efficiency**      | Rework cost avoided, incident cost reduced  | Change Failure Rate ↓            |
| **Productivity**         | Features shipped per unit time              | Lead Time ↓ + Deploy Frequency ↑ |
| **Developer experience** | Cognitive load, on-call burden, flow state  | MTTR ↓ + Deploy Frequency ↑      |
| **User experience**      | Platform stability visible to end users     | Change Failure Rate ↓            |
| **Business growth**      | Platform velocity enabling product velocity | All four metrics → Elite         |

## Report Types

### Type 1: Monthly one-pager (for personal tracking and dev.to longitudinal story)

5 numbers. 5 plain-language sentences. One trend line per metric. Fits on one screen.

### Type 2: Quarterly LinkedIn post (public proof of platform improvement)

Hook sentence + 3 paragraphs. One chart (DORA metric trend over 3 months). Call to action.

### Type 3: Annual capability review (for Dojo "proof it works" content)

Full-year metric trends mapped to the DORA tier progression (Low → Medium → High → Elite).
Identifies which capabilities improved and which investments drove the improvement.

## Monthly One-Pager Template

```markdown
---
period: YYYY-MM
generated: YYYY-MM-DD
source: dora-snapshot-YYYY-MM.json
---

# uFawkes Platform ROI — [MONTH YYYY]

## The numbers

| Metric              | This month | Last month | Trend | DORA tier          |
| ------------------- | ---------- | ---------- | ----- | ------------------ |
| Deploy frequency    | X/week     | Y/week     | ↑/↓/→ | Elite/High/Med/Low |
| Lead time           | X hrs      | Y hrs      | ↑/↓/→ | Elite/High/Med/Low |
| Change failure rate | X%         | Y%         | ↑/↓/→ | Elite/High/Med/Low |
| Time to restore     | X hrs      | Y hrs      | ↑/↓/→ | Elite/High/Med/Low |

_[proxy_metrics: true — deployment events not yet wired from uFawkesPipe. Values approximate.]_

## What the numbers mean

**Cost efficiency:** [One sentence. e.g., "CFR at 8% — 2 rework incidents this month,
down from 4 last month. ~4 hours of engineering time recovered."]

**Productivity:** [One sentence. e.g., "Lead time improved 12% — from idea to deployed
feature in 18hrs on average, vs 21hrs last month."]

**Developer experience:** [One sentence. e.g., "MTTR under 2hrs all month — no
late-night incidents. On-call burden effectively zero."]

**User experience:** [One sentence. e.g., "No user-visible outages. Change failure rate
improvements are translating to stability end users can feel."]

**Business growth:** [One sentence. e.g., "3 of 4 metrics now at High or Elite tier.
Platform is performing at the level DORA research associates with high-performing teams."]

## One thing that improved this month

[Named capability investment → metric improvement. e.g., "Added uFawkesObs smoke test
to CI → CFR dropped from 15% to 8% because config errors are now caught before deploy."]

## One thing to improve next month

[The metric most below target → the intervention planned.
Sourced from measure agent anomaly flags and learn agent action items.]
```

## Quarterly LinkedIn Post Template

```
[Hook sentence — a number, a question, or a counterintuitive observation]
Example: "We shipped 47 deployments last quarter with a 6% change failure rate.
Here's what actually moved that needle."

[Paragraph 1: The problem we were solving]
[1-2 sentences: what was broken or slow before the investment]

[Paragraph 2: What we built / changed]
[2-3 sentences: the specific platform capability added, in plain language.
No tool names unless they're well-known. Focus on what it enables, not what it is.]

[Paragraph 3: The result in DORA terms + call to action]
[1 sentence: the metric improvement. 1 sentence: what this means for the team.
1 sentence: link to ufawkes.dev or the specific repo.]

#devops #platformengineering #dora #opensource
```

## Calculating "Hours Recovered"

Use this simple model from the 2026 DORA ROI report framework to express
cost efficiency in concrete terms (avoid inventing specific dollar figures):

```python
def hours_recovered(
    prev_cfr: float,          # previous change failure rate (0–1)
    curr_cfr: float,          # current change failure rate (0–1)
    deploys_per_month: int,   # deployment count
    rework_hours_per_incident: float = 4.0  # conservative estimate
) -> float:
    """
    Hours recovered = reduction in failure incidents × avg rework hours per incident.
    Does not convert to dollars — that requires loaded cost assumptions we don't make.
    """
    prev_incidents = prev_cfr * deploys_per_month
    curr_incidents = curr_cfr * deploys_per_month
    return (prev_incidents - curr_incidents) * rework_hours_per_incident
```

**Note:** Do not state specific dollar amounts. Express ROI as recovered engineering
hours and what those hours were reinvested in (features, learning, rest). The 2026
DORA report's framing is explicit: the value is unlocked human creativity, not headcount
savings. Framing it as cost reduction leads to the wrong conversations.

## Annual Capability Review Structure

```markdown
# uFawkes Platform — Annual Capability Review YYYY

## DORA Tier Progression

| Metric           | Jan | Apr | Jul  | Oct   | Dec   | Change   |
| ---------------- | --- | --- | ---- | ----- | ----- | -------- |
| Deploy frequency | Low | Low | Med  | High  | High  | +2 tiers |
| Lead time        | Med | Med | Med  | High  | High  | +1 tier  |
| CFR              | Low | Med | Med  | High  | High  | +2 tiers |
| MTTR             | Med | Med | High | Elite | Elite | +2 tiers |

## What drove each improvement

[One paragraph per metric: the specific capability investment that moved the needle.
Reference the skill or agent that enabled it.]

## What didn't work

[One paragraph: capability investments that didn't improve metrics. What did we learn?]

## DORA AI Capabilities coverage (self-assessment)

| Capability            | Jan status | Dec status                        | Key investment            |
| --------------------- | ---------- | --------------------------------- | ------------------------- |
| 1. Clear AI stance    | ❌ None    | ✅ AI_STANCE.md live              | ai-stance skill           |
| 2. Healthy data       | ⚠ Partial  | ✅ uFawkesObs + dora-measurement  | Obs v0.1.0 + v0.2         |
| 3. AI-accessible data | ❌ None    | ✅ graphify + context-engineering | context-engineering skill |
| ...                   |            |                                   |                           |

## Next year focus

[Top 2 capability gaps remaining. The plan agent's input for the next annual roadmap.]
```

## Output Format

```json
{
  "skill": "roi-reporting",
  "report_type": "monthly | quarterly | annual",
  "period": "YYYY-MM",
  "source_snapshot": "metrics/dora-snapshot-YYYY-MM.json",
  "proxy_metrics": false,
  "five_dimensions": {
    "cost_efficiency": "string",
    "productivity": "string",
    "developer_experience": "string",
    "user_experience": "string",
    "business_growth": "string"
  },
  "hours_recovered": 8.0,
  "elite_metrics_count": 1,
  "report_path": "reports/roi-YYYY-MM.md",
  "linkedin_draft_path": "drafts/linkedin-roi-YYYY-QN.md"
}
```
