---
name: dora-measurement
description: "Compute the four DORA delivery metrics from uFawkesObs (Prometheus + Loki). Use when producing monthly DORA snapshots, validating post-release metric trends, or generating ROI evidence. Requires uFawkesObs running. Implements DORA AI Capabilities 2 and 7."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: DORA Measurement

> **Load trigger:** `"load dora-measurement skill"`
> **DORA:** AI Capability 2 (Healthy data ecosystems) + Capability 7 (Quality internal platforms)
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
|---|---|
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
|---|---|
| Elite | < 1 hour |
| High | 1 day to 1 week |
| Medium | 1 week to 1 month |
| Low | > 1 month |

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
|---|---|
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
|---|---|
| Elite | < 1 hour |
| High | < 1 day |
| Medium | 1 day to 1 week |
| Low | > 1 week |

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

        "business_growth": f"{sum(1 for m in metrics.values() if is_elite(m))}/4 metrics at Elite tier"
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
    df = query_prometheus(prometheus_url,
        f'rate(deployment_events_total{{repo=~"{repo}",status="success"}}[{w}]) * 604800')
    if df is None:
        df = query_prometheus(prometheus_url,
            f'rate(github_pr_merged_total{{repo=~"{repo}"}}[{w}]) * 604800')
        metrics["proxy_metrics"] = True
    metrics["deployment_frequency_per_week"] = df

    # Lead Time (simplified — hours)
    lt = query_prometheus(prometheus_url,
        f'histogram_quantile(0.50, rate(deployment_lead_time_seconds_bucket[{w}])) / 3600')
    if lt is None:
        lt = query_prometheus(prometheus_url,
            f'histogram_quantile(0.50, rate(github_pr_time_to_merge_seconds_bucket[{w}])) / 3600')
        metrics["proxy_metrics"] = True
    metrics["lead_time_p50_hours"] = lt

    # Change Failure Rate
    cfr = query_prometheus(prometheus_url,
        f'(increase(deployment_events_total{{repo=~"{repo}",status="failed"}}[{w}]) / '
        f'increase(deployment_events_total{{repo=~"{repo}"}}[{w}])) * 100')
    metrics["change_failure_rate_pct"] = cfr

    # MTTR (hours)
    mttr = query_prometheus(prometheus_url,
        f'histogram_quantile(0.50, rate(incident_resolution_time_seconds_bucket[{w}])) / 3600')
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
    for m in ["deployment_frequency_per_week", "lead_time_p50_hours",
              "change_failure_rate_pct", "mttr_p50_hours"]:
        metrics[f"{m}_tier"] = tier(m, metrics.get(m))

    metrics["computed_at"] = datetime.utcnow().isoformat() + "Z"
    metrics["period"] = (datetime.utcnow() - timedelta(days=args.window)).strftime("%Y-%m")

    output_path = Path(args.output)
    output_path.mkdir(parents=True, exist_ok=True)
    output_file = output_path / f"dora-snapshot-{metrics['period']}.json"

    with open(output_file, "w") as f:
        json.dump(metrics, f, indent=2)

    print(f"DORA snapshot written to {output_file}")
    if metrics["proxy_metrics"]:
        print("WARNING: proxy_metrics=true — deployment event sources not yet wired. "
              "Results approximate.")

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
