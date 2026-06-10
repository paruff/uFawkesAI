# Skill: DORA Metrics

> **Load trigger:** `"load dora-metrics skill"`
> **DORA:** Cap 2 (Healthy Data Ecosystems)
> **Token cost:** Low

## The Four Key Metrics — Calculation Patterns

### Deployment Frequency

```bash
# From git log (proxy when ArgoCD not available)
git log --oneline --after="30 days ago" | grep -c "feat\|fix\|release"
# True source: ArgoCD sync events or uFawkesObs deployment spans
```

### Lead Time for Changes

```bash
# Time from first commit on branch to production merge
# Proxy: git log --pretty=format:"%H %ai" on merged PRs
# True source: GitHub API — PR created_at to merged_at
```

### Change Failure Rate

```bash
# (Hotfix PRs + rollback commits) / Total merged PRs * 100
git log --oneline --after="30 days ago" | grep -cE "hotfix|rollback|revert"
TOTAL=$(git log --oneline --after="30 days ago" --merges | wc -l)
echo "CFR: $((HOTFIX * 100 / TOTAL))%"
```

### Failed Deployment Recovery Time (FDRT)

- Source: uFawkesObs — time between `deployment.failed` span and `deployment.completed` span
- Proxy: time between incident label applied and resolved label on GitHub Issues

## uFawkesAI Additional Metrics

### Rework Rate (template-specific)

```bash
# scripts/weekly-metrics.sh produces this
# Definition: lines substantially changed within 14 days of AI authoring
# Threshold: < 10% target, > 20% stop-features
```

### PR Revision Rate

```bash
# PRs with > 1 push after review comment / total PRs
# GitHub CLI: gh pr list --state merged --json reviews,commits
```

## Metric Interpretation Quick Reference

| Rework Rate | Action                                         |
| ----------- | ---------------------------------------------- |
| < 10%       | Normal — continue                              |
| 10–20%      | Investigate — tighten AGENTS.md or issue ACs   |
| > 20%       | Stop features — fix context before adding more |

## Integration with uFawkesObs

DORA metrics flow: `scripts/weekly-metrics.sh` → `docs/METRICS.md` → Prometheus push gateway → Grafana DORA dashboard

Required env vars for push gateway integration:

```
METRICS_PUSH_GATEWAY_URL=http://prometheus-pushgateway:9091
OTEL_SERVICE_NAME=your-service-name
```
