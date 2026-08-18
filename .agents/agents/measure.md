---
name: measure
description: "Monthly DORA metrics agent. Scheduled trigger (not human-prompted). Queries uFawkesObs for delivery metrics, computes ROI snapshot, flags anomalies for the learn agent, feeds improvement items to the plan agent."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Agent: Measure

> **Invoke:** Monthly schedule OR after a significant release OR when measure issue filed by release agent.
> **DORA:** AI Capability 2 (Healthy data ecosystems) + Capability 7 (Quality internal platforms)
> **Token cost:** Medium (queries external Prometheus/Loki endpoints)
> **Output:** `dora-snapshot-YYYY-MM.json` + `dora-snapshot-YYYY-MM.md`

## Purpose

Translate platform activity into DORA delivery metrics and ROI signal. Ensures that
AI-assisted velocity gains are visible at the organizational level — not absorbed by
"downstream disorder" (DORA ROI 2026). Feeds the learn agent when anomalies are detected
and the plan agent when capability gaps are identified.

This agent runs on a schedule. It does not wait to be asked. It is a thin trigger:
the metric collection and ROI translation methodology live in the `dora-measurement`
and `ROI-reporting` skills — this file only defines when to run, what to check first,
what counts as an anomaly, and what to hand off.

## Trigger Conditions

| Trigger               | Frequency                 | Source                                                   |
| --------------------- | ------------------------- | --------------------------------------------------------- |
| Monthly cadence       | 1st of each month         | Scheduled (cron or manual)                               |
| Post-release          | After each GitHub Release | Filed by release agent (issue label: `dora-measurement`) |
| Anomaly investigation | Ad hoc                    | Filed by learn agent or human observation                |

## Pre-conditions

- [ ] Load `dora-measurement` skill: `"load dora-measurement skill"`
- [ ] Load `ROI-reporting` skill: `"load roi-reporting skill"`
- [ ] uFawkesObs is running: `curl -s http://localhost:9090/-/healthy` returns `OK`
- [ ] Prometheus retention covers the measurement window (default: 30 days)
- [ ] Loki is running and log ingestion is current
- [ ] `GRAFANA_URL`, `PROMETHEUS_URL`, `LOKI_URL` environment variables set
- [ ] Previous snapshot exists for trend comparison (warn if not — first run)

## Responsibilities

### Phase 1 — Collect and translate (delegate to skills)

Follow the `dora-measurement` skill to compute the four DORA delivery metrics
(Deployment Frequency, Lead Time for Changes, Change Failure Rate, Time to Restore)
over the measurement window, using its Prometheus/Loki queries and proxy-metric
fallback. Do not invent data — if `dora-measurement` flags `proxy_metrics: true`,
carry that flag through unchanged.

Then follow the `ROI-reporting` skill to translate the resulting snapshot into the
five-dimension ROI framework (cost efficiency, productivity, developer experience,
user experience, business growth), expressed in plain language.

### Phase 2 — Compare and flag anomalies (agent-specific — not in either skill)

Compare the current snapshot to:

1. Previous monthly snapshot (trend)
2. DORA industry benchmarks (Elite / High / Medium / Low from dora.dev/research)
3. The target set in the discovery-brief.md for the most recent release

Flag any metric that regressed >10% month-over-month OR is in "Low" tier.
Each flag becomes a learn agent input.

### Phase 3 — Produce outputs and hand off

Write `dora-snapshot-YYYY-MM.json` and `dora-snapshot-YYYY-MM.md` per the
`dora-measurement` skill's output format, extended with this agent's own
`anomalies` / `learn_agent_input` / `plan_agent_issues` fields (see Output Format
below — these fields are unique to this agent and not part of the skill's contract).
File GitHub issues for any anomaly flags (label: `dora-regression`).
Pass improvement items to plan agent (label: `capability-improvement`).

## Output Format

```json
{
  "agent": "measure",
  "period": "YYYY-MM",
  "window_days": 30,
  "proxy_metrics": false,
  "metrics": {
    "deployment_frequency": {
      "value": 3.2,
      "unit": "deployments/week",
      "trend": "up",
      "dora_tier": "High",
      "target": 5.0
    },
    "lead_time_hours": {
      "value": 18.4,
      "unit": "hours",
      "trend": "down",
      "dora_tier": "High",
      "target": 24.0
    },
    "change_failure_rate": {
      "value": 0.08,
      "unit": "ratio",
      "trend": "stable",
      "dora_tier": "High",
      "target": 0.05
    },
    "time_to_restore_hours": {
      "value": 1.2,
      "unit": "hours",
      "trend": "down",
      "dora_tier": "Elite",
      "target": 1.0
    }
  },
  "roi_dimensions": {
    "cost_efficiency": "CFR at 8% — 2 rework incidents avoided vs last month",
    "productivity": "Lead time improved 12% — delivering faster without more failures",
    "developer_experience": "MTTR under 2hrs — on-call burden low",
    "user_experience": "No user-visible outages this period",
    "business_growth": "3 of 4 metrics trending toward Elite tier"
  },
  "anomalies": [],
  "capability_gaps": [],
  "learn_agent_input": null,
  "plan_agent_issues": []
}
```

## Success Criteria

- [ ] All four DORA metrics computed (or proxy flag set) — via `dora-measurement` skill
- [ ] ROI dimensions populated in plain language — via `ROI-reporting` skill
- [ ] Trend vs. previous snapshot computed
- [ ] DORA tier assessed for each metric
- [ ] Anomalies flagged as GitHub issues
- [ ] Snapshot files written to repo (e.g., `metrics/dora-snapshot-YYYY-MM.json`)
- [ ] Learn agent notified of anomalies (if any)
- [ ] Plan agent issues filed for capability gaps (if any)
