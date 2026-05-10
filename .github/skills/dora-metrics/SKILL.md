# DORA Metrics Skill

## When to activate
When working on metrics collection, dashboards, reporting, or any code that tracks
deployment frequency, lead time, change failure rate, failed deployment recovery time,
or rework rate.

## The six DORA metrics (2025 definitions)

**Deployment Frequency** — How often the team deploys to production.
Elite: on-demand (multiple times/day). High: daily to weekly.

**Lead Time for Changes** — Time from first commit to production deployment.
Elite: < 1 hour. High: < 1 day.

**Change Failure Rate** — % of deployments causing incidents requiring hotfix.
Elite: 0–5%. High: 5–10%.

**Failed Deployment Recovery Time** — (renamed from MTTR in 2025)
Time to recover from a failed deployment. Elite: < 1 hour. High: < 1 day.

**Rework Rate** — (new in 2025) % of work that re-does previously completed work.
Target: < 10%. > 20%: stop features, update AGENTS.md.

**Reliability** — (new quasi-metric 2025) System stability under AI-accelerated delivery.
Monitor: change failure rate trend over 90 days of AI adoption.

## Implementation patterns
- Calculate deployment frequency from git tags or CI deployment events, not commit frequency
- Lead time: from branch creation (not first commit) to production merge
- Rework rate: PRs with title prefix `fix:` or `revert:` / total PRs, rolling 30 days
- FDRT: time from incident label on issue to `resolved` label, rolling average

## Connecting to uFawkesObs
If uFawkesObs is running, write metrics to OTEL endpoint:
`OTEL_EXPORTER_OTLP_ENDPOINT=http://localhost:4318`
Use `gen_ai.*` spans for AI-assisted work attribution.
