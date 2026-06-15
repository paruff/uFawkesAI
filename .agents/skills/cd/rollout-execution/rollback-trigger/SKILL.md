---
name: rollback-trigger
description: "Trigger rollback when rollout health degrades. Use when detecting failure conditions, triggering rollback, or validating rollback success."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Automated Rollback Trigger

> **Load trigger:** `"load rollback-trigger skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Trigger rollback when rollout health degrades.

## Responsibilities

- Detect failure conditions
- Trigger rollback
- Validate rollback success

## Inputs

- `rollout-health.json`

## Outputs

- `rollback-report.json`

## Failure Conditions

| Condition | Severity | Action |
|-----------|----------|--------|
| Health check failure | HIGH | Rollback |
| Error rate > 5% | HIGH | Rollback |
| Latency p99 > 1s | MEDIUM | Pause, then rollback |
| OOMKilled | HIGH | Rollback |
| CrashLoopBackOff | HIGH | Rollback |

## Rollback Methods

### GitOps Rollback

```bash
# Flux - revert to previous commit
git revert HEAD
git push origin main

# ArgoCD - rollback app
argocd app rollback <app-name>
```

### Kubectl Rollback

```bash
kubectl rollout undo deployment/<name> -n <namespace>
kubectl rollout undo deployment/<name> --to-revision=<N>
```

## Rollback Rules

- [ ] Rollback triggered within 1 minute of failure
- [ ] Rollback validated after execution
- [ ] Health confirmed after rollback
- [ ] Incident logged

## Output Format

```json
{
  "skill": "rollback-trigger",
  "triggered": true,
  "reason": "Health check failure",
  "method": "kubectl-rollout-undo",
  "from_version": "v1.2.3",
  "to_version": "v1.2.2",
  "rollback_duration_seconds": 30,
  "post_rollback_health": "healthy"
}
```

## Success Criteria

- Safe rollback
- Health restored
- Incident logged
