---
name: gitops-drift-detection
description: "Detect differences between desired state (Git) and actual state (cluster). Use when comparing manifests, detecting unauthorized changes, or validating reconciliation status."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: GitOps Drift Detection

> **Load trigger:** `"load gitops-drift-detection skill"` > **DORA:** Cap 5 (Operational Resilience)
> **Token cost:** Low

## Purpose

Detect differences between desired state (Git) and actual state (cluster).

## Responsibilities

- Compare manifests in Git with live cluster state
- Detect unauthorized changes
- Detect missing or extra resources
- Validate reconciliation status

## Inputs

- GitOps repo
- Live cluster

## Outputs

- `drift-report.json`
- `drift-diff.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `gitops-drift-detection/snapshot` | Capture cluster state |
| `gitops-drift-detection/diff` | Compute drift diff |

## Drift Categories

| Category | Description | Severity |
|----------|-------------|----------|
| Missing resource | Resource in Git but not in cluster | High |
| Extra resource | Resource in cluster but not in Git | High |
| Modified resource | Resource differs from Git | Critical |
| Unreconciled | GitOps controller hasn't synced | Medium |

## Validation Rules

- [ ] All Git resources present in cluster
- [ ] No extra resources in cluster
- [ ] No unauthorized modifications
- [ ] Reconciliation status healthy

## Tools

- kubectl
- Flux CLI
- Argo CLI

## Output Format

```json
{
  "skill": "gitops-drift-detection",
  "status": "clean | drift",
  "total_resources": 50,
  "in_sync": 48,
  "drift": {
    "missing": 1,
    "extra": 0,
    "modified": 1
  },
  "details": [
    {"resource": "deployment/my-app", "type": "modified", "field": "replicas"}
  ]
}
```

## Success Criteria

- Drift detected accurately
- No false positives
