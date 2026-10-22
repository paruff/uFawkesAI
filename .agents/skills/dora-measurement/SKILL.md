---
name: dora-measurement
description: "Compute the five DORA software delivery metrics from uFawkesObs (Prometheus and Loki), flag any proxy metric, and report the tier for each. Use for the monthly /measure snapshot."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: dora-measurement

> **Load trigger:** "load dora-measurement skill" · **DORA:** AI Capability 7, quality internal platforms

Turns uFawkesObs telemetry into the five DORA software delivery metrics. **Dependency:** uFawkesObs must be running.
Where deployment events are not wired yet, use the proxy metric and set `proxy_metrics: true`.
Never report a proxy as if it were the real metric.

## Pre-conditions

```bash
: "${PROMETHEUS_URL:?e.g. http://localhost:9090}"
: "${LOKI_URL:?e.g. http://localhost:3100}"
: "${REPO:?e.g. paruff/uFawkesObs}"
: "${MEASUREMENT_WINDOW_DAYS:=30}"
curl -s "${PROMETHEUS_URL}/-/healthy" | grep -q Prometheus || echo "ERROR: Prometheus not healthy"
curl -s "${LOKI_URL}/ready" | grep -q ready || echo "ERROR: Loki not ready"
```

If either check fails, stop and report; do not estimate.

## The five metrics

`W` is the window in days. Tiers: Elite / High / Medium / Low.

| # | Metric | Primary query | Proxy | Tiers |
| --- | --- | --- | --- | --- |
| 1 | Deployment frequency | `rate(deployment_events_total{repo=~"REPO",status="success"}[Wd]) * 604800` (per week) | `rate(github_pr_merged_total{repo=~"REPO"}[Wd]) * 604800` | on demand / 1 per week to 1 per day / 1 per month to 1 per week / under 1 per month |
| 2 | Change lead time | `histogram_quantile(0.5, rate(deployment_lead_time_seconds_bucket[Wd])) / 3600` (hours, p50) | `histogram_quantile(0.5, rate(github_pr_time_to_merge_seconds_bucket[Wd])) / 3600` | under 1 h / 1 day to 1 week / 1 week to 1 month / over 1 month |
| 3 | Change fail rate | `increase(deployment_events_total{repo=~"REPO",status="failed"}[Wd]) / increase(deployment_events_total{repo=~"REPO"}[Wd]) * 100` | same ratio over `github_pr_merged_total{label="hotfix"}` | 0-5% / 5-10% / 10-15% / over 15% |
| 4 | Failed deployment recovery time | `histogram_quantile(0.5, rate(incident_resolution_time_seconds_bucket[Wd])) / 3600` (hours, p50) | time from error-log spike to baseline: `{app=~"REPO"} \|= "ERROR"` rate, spike start and end read by hand | under 1 h / under 1 day / 1 day to 1 week / over 1 week |
| 5 | Deployment rework rate | `increase(deployment_events_total{repo=~"REPO",deployment_intent="unplanned_rework"}[Wd]) / increase(deployment_events_total{repo=~"REPO"}[Wd]) * 100` | hotfix PR ratio, as in 3 | 0-5% / 5-10% / 10-15% / over 15% |

For lead time without a histogram, join deployment timestamps from Loki
(`{app="uFawkesPipe",event="deployment_complete"} | json`) with commit timestamps from `git log`;
lead time is `deployed_at - commit_timestamp`. For recovery time, pair `incident_opened` with `incident_resolved`
events in Loki (`{app="uFawkesObs",event=~"incident_opened|incident_resolved"} | json`) by incident id.

## ROI signal

Add one plain-language line per dimension (cost efficiency, productivity, developer experience, user experience,
business growth). Say "unknown" where there is no data; do not invent numbers.

## Output

```json
{
  "skill": "dora-measurement",
  "period": "YYYY-MM",
  "window_days": 30,
  "proxy_metrics": false,
  "deployment_frequency_per_week": 3.2,
  "change_lead_time_p50_hours": 18.4,
  "change_fail_rate_pct": 8.0,
  "failed_deployment_recovery_time_p50_hours": 1.2,
  "deployment_rework_rate_pct": 4.0,
  "tiers": {"deployment_frequency": "High", "change_lead_time": "High", "change_fail_rate": "High",
            "recovery_time": "Elite", "rework_rate": "High"},
  "roi": {"cost_efficiency": "...", "productivity": "...", "developer_experience": "...",
          "user_experience": "...", "business_growth": "..."},
  "computed_at": "<ISO 8601>"
}
```
