---
name: dora-measurement
description: "Compute the four DORA delivery metrics from uFawkesObs. Implements DORA AI Capability 7 (the platform feedback loop)."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: dora-measurement

> **Load trigger:** "load dora-measurement skill" > **DORA:** AI Capability 7: Quality internal platforms
> **Token cost:** Medium

## Purpose

Compute the four DORA delivery metrics from uFawkesObs (Prometheus + Loki). Use when producing monthly DORA snapshots, validating post-release metric trends, or generating ROI evidence. Requires uFawkesObs running. Implements DORA AI Capability 7: Quality internal platforms — measurement is the platform's feedback loop, not a data ecosystem (Cap 2).

## When to Use

- Producing monthly DORA snapshots
- Validating post-release metric trends
- Generating ROI evidence

## Sub-skills (now integrated)

### 1. Core Dora Measurement

# Skill: DORA Measurement

> **Load trigger:** `"load dora-measurement skill"` > **DORA:** AI Capability 2: Healthy data ecosystems + AI Capability 7: Quality internal platforms
> **Token cost:** Medium (queries external endpoints)

## Purpose

Translate uFawkesObs telemetry into the four DORA delivery metrics and a plain-language
ROI signal. Bridges the gap between "substrate is running" and "we have DORA numbers."

**Dependency:** uFawkesObs must be running and ingesting events. If deployment event
sources are not yet wired from uFawkesPipe, proxy metrics are used and flagged explicitly.
Never produce metrics without flagging proxy usage — that would be misleading data.

## Pre-conditions

```bash
# Verify uFawkesObs is running
curl -s "${PROMETHEUS_URL}/-/healthy" | grep -q "Prometheus" || echo "ERROR: Prometheus not healthy"
curl -s "${LOKI_URL}/ready" | grep -q "ready" || echo "ERROR: Loki not ready"
curl -s "${GRAFANA_URL}/api/health" | jq '.database' | grep -q "ok" || echo "ERROR: Grafana not healthy"

# Required environment variables
: "${PROMETHEUS_URL:?Set PROMETHEUS_URL (e.g. http://localhost:9090)}"
: "${LOKI_URL:?Set LOKI_URL (e.g. http://localhost:3100)}"
: "${GRAFANA_URL:?Set GRAFANA_URL (e.g. http://localhost:3000)}"
: "${MEASUREMENT_WINDOW_DAYS:=30}"
: "${REPO:?Set REPO (e.g. paruff/uFawkesObs)}"
```

## The Four DORA Delivery Metrics

### 1. Deployment Frequency

How often code is successfully deployed to production.

**Primary query (Prometheus):**

```promql
# Deployments per week over the measurement window
rate(deployment_events_total{repo=~"REPO", status="success"}[${WINDOW}d]) * 604800
```

**Proxy metric** (if deployment events not yet wired — flag proxy_metrics: true):

```promql
# PR merge rate as proxy for deployment frequency
rate(github_pr_merged_total{repo=~"REPO"}[${WINDOW}d]) * 604800
```

**DORA tier thresholds:**

| Tier | Value |
| --- | --- |
| Elite | On-demand (multiple deploys/day) |
| High | 1/week to 1/day |
| Medium | 1/month to 1/week |
| Low | Less than 1/month |

### 2. Lead Time for Changes

Time from code committed to running in production.

**Primary query (Loki + Prometheus):**

```logql
# Get deployment timestamps from Loki
{app="uFawkesPipe", event="deployment_complete"} | json | line_format "{{.commit_sha}} {{.deployed_at}}"
# Cross-reference with git commit timestamps (requires git log or GitHub API)
# Lead time = deployed_at - commit_timestamp
```

**Prometheus histogram** (if instrumented):

```promql
histogram_quantile(0.50, rate(deployment_lead_time_seconds_bucket[${WINDOW}d])) / 3600
# Result in hours. Use p50 for median, p95 for tail.
```

**Proxy metric:**

```promql
# Time from PR open to merge as proxy
histogram_quantile(0.50, rate(github_pr_time_to_merge_seconds_bucket[${WINDOW}d])) / 3600
```

**DORA tier thresholds:**

| Tier | Value |
| --- | --- |
| Elite | < 1 hour |
| High | 1 day to 1 week |
| Medium | 1 week to 1 month |
| Low    | > 1 month         |

### 3. Change Failure Rate

Percentage of deployments causing a production failure requiring remediation.

**Primary query (Prometheus):**

```promql
# Ratio of failed deployments to total deployments
(
  increase(deployment_events_total{repo=~"REPO", status="failed"}[${WINDOW}d])
  /
  increase(deployment_events_total{repo=~"REPO"}[${WINDOW}d])
) * 100
```

**Proxy metric:**

```promql
# Hotfix PR rate as proxy
(
  increase(github_pr_merged_total{repo=~"REPO", label="hotfix"}[${WINDOW}d])
  /
  increase(github_pr_merged_total{repo=~"REPO"}[${WINDOW}d])
) * 100
```

**DORA tier thresholds:**

| Tier | Value |
| --- | --- |
| Elite | 0–5% |
| High | 5–10% |
| Medium | 10–15% |
| Low | 15–100% |

### 4. Time to Restore (MTTR)

How long it takes to recover from a production failure.

**Primary query (Loki):**

```logql
# Find incident open and resolve pairs
{app="uFawkesObs", event=~"incident_opened|incident_resolved"} | json
# Calculate duration between matching incident IDs
```

**Prometheus histogram** (if instrumented):

```promql
histogram_quantile(0.50, rate(incident_resolution_time_seconds_bucket[${WINDOW}d])) / 3600
```

**Proxy metric:**

```logql
# Time from error log spike to return to baseline
{app=~"REPO"} |= "ERROR" | rate()
# Manual identification of spike start/end if no incident instrumentation
```

**DORA tier thresholds:**

| Tier | Value |
| --- | --- |
| Elite | < 1 hour |
| High | < 1 day |
| Medium | 1 day to 1 week |
| Low    | > 1 week        |

## ROI Translation (2026 DORA ROI Report Framework)

Map metric values to five ROI dimensions. Produce plain-language interpretation
for each — no metric jargon in the output summary.

```python
# Pseudocode for ROI translation
def translate_roi(metrics: dict, previous: dict) -> dict:
    return {
        "cost_efficiency": f"CFR at {metrics['cfr']:.0%} — "
        f"~{estimate_rework_incidents(metrics['cfr'], metrics['deploy_freq'])} "
        f"rework incidents avoided vs last period",
        "productivity": f"Lead time {direction(metrics['lead_time'], previous['lead_time'])} "
        f"{abs_change(metrics['lead_time'], previous['lead_time']):.0%} — "
        f"delivering {'faster' if improved else 'slower'} than last period",
        "developer_experience": f"MTTR {metrics['mttr']:.1f}hrs — "
        f"{'low' if metrics['mttr'] < 4 else 'moderate' if metrics['mttr'] < 24 else 'high'} "
        f"on-call burden",
        "user_experience": f"{'No user-visible outages' if metrics['cfr'] < 0.05 else str(incidents) + ' user-visible incidents'} this period",
        "business_growth": f"{sum(1 for m in metrics.values() if is_elite(m))}/4 metrics at Elite tier",
    }
```

## Reference Script

Save as `scripts/compute_dora_metrics.py` in any uFawkes\* repo that produces DORA data:

```python
#!/usr/bin/env python3
"""
Compute DORA delivery metrics from uFawkesObs.
Usage: python scripts/compute_dora_metrics.py --window 30 --output metrics/
"""

import argparse
import json
import os
import sys
from datetime import datetime, timedelta
from pathlib import Path

import requests


def query_prometheus(url: str, query: str) -> float | None:
    """Execute a Prometheus instant query, return scalar value or None."""
    try:
        resp = requests.get(f"{url}/api/v1/query", params={"query": query}, timeout=10)
        resp.raise_for_status()
        result = resp.json()["data"]["result"]
        return float(result[0]["value"][1]) if result else None
    except Exception as e:
        print(f"WARNING: Prometheus query failed: {e}", file=sys.stderr)
        return None


def compute_metrics(prometheus_url: str, window_days: int, repo: str) -> dict:
    w = f"{window_days}d"
    metrics = {"proxy_metrics": False, "window_days": window_days, "repo": repo}

    # Deployment Frequency
    df = query_prometheus(
        prometheus_url,
        f'rate(deployment_events_total{{repo=~"{repo}",status="success"}}[{w}]) * 604800',
    )
    if df is None:
        df = query_prometheus(
            prometheus_url,
            f'rate(github_pr_merged_total{{repo=~"{repo}"}}[{w}]) * 604800',
        )
        metrics["proxy_metrics"] = True
    metrics["deployment_frequency_per_week"] = df

    # Lead Time (simplified — hours)
    lt = query_prometheus(
        prometheus_url,
        f"histogram_quantile(0.50, rate(deployment_lead_time_seconds_bucket[{w}])) / 3600",
    )
    if lt is None:
        lt = query_prometheus(
            prometheus_url,
            f"histogram_quantile(0.50, rate(github_pr_time_to_merge_seconds_bucket[{w}])) / 3600",
        )
        metrics["proxy_metrics"] = True
    metrics["lead_time_p50_hours"] = lt

    # Change Failure Rate
    cfr = query_prometheus(
        prometheus_url,
        f'(increase(deployment_events_total{{repo=~"{repo}",status="failed"}}[{w}]) / '
        f'increase(deployment_events_total{{repo=~"{repo}"}}[{w}])) * 100',
    )
    metrics["change_failure_rate_pct"] = cfr

    # MTTR (hours)
    mttr = query_prometheus(
        prometheus_url,
        f"histogram_quantile(0.50, rate(incident_resolution_time_seconds_bucket[{w}])) / 3600",
    )
    metrics["mttr_p50_hours"] = mttr

    return metrics


def tier(metric_name: str, value: float | None) -> str:
    if value is None:
        return "unknown"
    thresholds = {
        "deployment_frequency_per_week": [(7, "Elite"), (1, "High"), (0.25, "Medium")],
        "lead_time_p50_hours": [(1, "Elite"), (24, "High"), (168, "Medium")],
        "change_failure_rate_pct": [(5, "Elite"), (10, "High"), (15, "Medium")],
        "mttr_p50_hours": [(1, "Elite"), (24, "High"), (168, "Medium")],
    }
    for freq_metrics in ["deployment_frequency_per_week"]:
        if metric_name == freq_metrics:
            for threshold, label in thresholds[metric_name]:
                if value >= threshold:
                    return label
            return "Low"
    for threshold, label in thresholds.get(metric_name, []):
        if value <= threshold:
            return label
    return "Low"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--window", type=int, default=30)
    parser.add_argument("--output", default="metrics")
    parser.add_argument("--repo", default=os.getenv("REPO", ".*"))
    args = parser.parse_args()

    prometheus_url = os.getenv("PROMETHEUS_URL", "http://localhost:9090")
    metrics = compute_metrics(prometheus_url, args.window, args.repo)

    # Add DORA tiers
    for m in [
        "deployment_frequency_per_week",
        "lead_time_p50_hours",
        "change_failure_rate_pct",
        "mttr_p50_hours",
    ]:
        metrics[f"{m}_tier"] = tier(m, metrics.get(m))

    metrics["computed_at"] = datetime.utcnow().isoformat() + "Z"
    metrics["period"] = (datetime.utcnow() - timedelta(days=args.window)).strftime(
        "%Y-%m"
    )

    output_path = Path(args.output)
    output_path.mkdir(parents=True, exist_ok=True)
    output_file = output_path / f"dora-snapshot-{metrics['period']}.json"

    with open(output_file, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"DORA snapshot written to {output_file}")
    if metrics["proxy_metrics"]:
        print(
            "WARNING: proxy_metrics=true — deployment event sources not yet wired. "
            "Results approximate."
        )


if __name__ == "__main__":
    main()
```

## Output Format

```json
{
  "skill": "dora-measurement",
  "period": "YYYY-MM",
  "window_days": 30,
  "proxy_metrics": false,
  "deployment_frequency_per_week": 3.2,
  "deployment_frequency_per_week_tier": "High",
  "lead_time_p50_hours": 18.4,
  "lead_time_p50_hours_tier": "High",
  "change_failure_rate_pct": 8.0,
  "change_failure_rate_pct_tier": "High",
  "mttr_p50_hours": 1.2,
  "mttr_p50_hours_tier": "Elite",
  "roi_dimensions": {
    "cost_efficiency": "string",
    "productivity": "string",
    "developer_experience": "string",
    "user_experience": "string",
    "business_growth": "string"
  },
  "elite_count": 1,
  "computed_at": "2026-06-16T00:00:00Z"
}
```

### 2. ROI Reporting

# Skill: ROI Reporting

> **Load trigger:** `"load roi-reporting skill"` > **DORA:** AI Capability 2: Healthy data ecosystems + AI Capability 7: Quality internal platforms
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
Sourced from `/measure` command anomaly flags and `learn` skill action items.]
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
    prev_cfr: float,  # previous change failure rate (0–1)
    curr_cfr: float,  # current change failure rate (0–1)
    deploys_per_month: int,  # deployment count
    rework_hours_per_incident: float = 4.0,  # conservative estimate
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
| 3. AI-accessible data | ❌ None    | ✅ context-engineering           | context-engineering skill |
| ...                   |            |                                   |                           |

## Next year focus

[Top 2 capability gaps remaining. `@planner`'s input for the next annual roadmap.]
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

### 3. Platform Feedback

# Skill: Platform Feedback

> **Load trigger:** `"load platform-feedback skill"` > **DORA:** AI Capability 7: Quality internal platforms
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
the `discovery` skill and the `learn` skill.

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

## Output → `@planner`

Each analysis session produces at most 3 action items for `@planner`:

- One for the highest-friction theme (Q2)
- One for the most-requested removal (Q3)
- One for any metric below target

Each action item filed as a GitHub issue with:

- Label: `platform-feedback`, `capability-improvement`, tier label
- Body: links to specific Discussion responses as evidence
- DORA capability: 7: Quality internal platforms

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

### 4. Value Stream Mapping

# Skill: Value Stream Mapping

> **Load trigger:** `"load value-stream-mapping skill"` > **DORA:** AI Capability 2: Healthy data ecosystems + AI Capability 7: Quality internal platforms
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
| `/measure` files `capability-improvement` issues     | >2 issues in same area in one quarter                                 |

## The Seven Value Stream Stages

Map each stage for the product being built. Time estimates come from DORA measurement
data where available; direct observation otherwise.

| Stage           | Definition                             | Data source                                 |
| --------------- | -------------------------------------- | ------------------------------------------- |
| 1. **Discover** | Idea to validated user need            | `discover` skill time + `learn` skill anomalies |
| 2. **Define**   | Validated need to accepted spec        | `spec` skill sessions                         |
| 3. **Build**    | Spec to passing tests                  | build + `test` skill sessions (opencode logs) |
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
| Review stage is the bottleneck                 | No reviewers — solo contributor | Automate review with `code-review` skill + code-quality skill |
| Release stage is the bottleneck                | Manual release steps            | Automate with release skill                            |
| Verify stage is the bottleneck                 | Thin test suite, high CFR       | j-curve-navigation + test investment                   |
| Learn stage is the bottleneck                  | No feedback mechanism           | platform-feedback skill + quarterly cadence            |
| Build stage is the bottleneck despite AI tools | Context re-discovery tax        | context-engineering skill                                |

### Step 4 — Design the future state

For the top bottleneck, propose one intervention:

- What is the target stage time after the intervention?
- Which DORA metric improves and by how much?
- Which skill or agent implements the intervention?
- What is the estimated investment (sessions at 2hrs each)?

### Step 5 — Hand findings to `@planner`

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
  "intervention": "platform-feedback quarterly cadence + `learn` skill monthly",
  "dora_metric_target": "lead_time_p50_hours",
  "current_value": 759.0,
  "target_value": 36.0,
  "investment_sessions": 2,
  "issues_filed": [55, 56]
}
```

## Usage

```bash
# Monthly DORA snapshot
load dora-measurement skill

# ROI reporting
load dora-measurement/ROI-reporting skill

# Platform feedback
load dora-measurement/platform-feedback skill

# Value stream mapping
load dora-measurement/value-stream-mapping skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 2, 7 references
- **AI stance audit** validates relevant clarity dimensions
