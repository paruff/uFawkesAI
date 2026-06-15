---
name: rbac-drift
description: "Detect unauthorized changes to RBAC roles or bindings. Use when comparing live cluster RBAC to GitOps RBAC definitions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: RBAC Drift Detection

> **Load trigger:** `"load rbac-drift skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Detect unauthorized changes to RBAC roles or bindings.

## Responsibilities

- Compare live RBAC to GitOps RBAC definitions
- Detect unauthorized changes
- Produce drift diff
- Alert on drift

## Inputs

- Live cluster RBAC (from `kubectl`)
- GitOps RBAC definitions

## Outputs

- `rbac-drift.json`

## Detection Rules

### Drift Indicators

- [ ] New roles added not in GitOps
- [ ] Roles modified not in GitOps
- [ ] Bindings added not in GitOps
- [ ] Bindings modified not in GitOps
- [ ] Roles/bindings deleted from GitOps but still live

### Severity Classification

| Drift Type | Severity |
|-----------|----------|
| New cluster-admin binding | CRITICAL |
| New wildcard role | HIGH |
| Modified role permissions | HIGH |
| New namespace role | MEDIUM |
| Deleted role (still live) | MEDIUM |

## Comparison Logic

```
1. Export live RBAC: kubectl get roles,rolebindings,clusterroles,clusterrolebindings
2. Load GitOps RBAC: parse YAML files
3. Diff: identify additions, modifications, deletions
4. Classify: determine severity of each change
```

## Output Format

```json
{
  "skill": "rbac-drift",
  "status": "clean | drift_detected",
  "drift": [
    {
      "type": "role_added",
      "resource": "Role/app-deploy",
      "namespace": "production",
      "severity": "HIGH",
      "details": "Role not defined in GitOps"
    }
  ]
}
```

## Success Criteria

- Accurate RBAC drift detection
- All drift classified by severity
- Alerts generated for high-severity drift
