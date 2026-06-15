---
name: full-stack-integration
description: "Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end. Use when running full pipeline, validating GitOps update, reconciliation, deployment, or smoke tests."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Full Stack Integration Testing

> **Load trigger:** `"load full-stack-integration skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate the entire OBS + PIPE + GitOps + K8s flow end-to-end.

## Responsibilities

- Run full pipeline
- Validate GitOps update
- Validate reconciliation
- Validate deployment
- Validate smoke tests

## Inputs

- Full system

## Outputs

- `full-integration-report.json`
- `cluster-state.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `full-stack/cluster-state` | Validate cluster state matches Git |
| `full-stack/smoke-tests` | Validate deployed application |

## Full Stack Flow

```
1. Code change triggers PIPE
2. PIPE builds, tests, scans
3. PIPE produces artifacts (image, SBOM, signature)
4. OBS receives artifacts
5. OBS updates GitOps repo
6. Controller reconciles
7. K8s deploys
8. Smoke tests validate
```

## Validation Rules

- [ ] Full pipeline completes
- [ ] GitOps update valid
- [ ] Reconciliation successful
- [ ] Deployment healthy
- [ ] Smoke tests pass

## Output Format

```json
{
  "skill": "full-stack-integration",
  "status": "pass | fail",
  "pipeline": {"status": "pass", "time_s": 300},
  "gitops_update": {"status": "pass", "commit": "abc123"},
  "reconciliation": {"status": "pass", "time_s": 60},
  "deployment": {"status": "pass", "replicas": 3},
  "smoke_tests": {"status": "pass", "tests": 10}
}
```

## Success Criteria

- End-to-end correctness
- Healthy deployment
