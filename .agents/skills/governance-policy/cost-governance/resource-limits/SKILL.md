---
name: resource-limits
description: "Ensure workloads define safe resource requests and limits. Use when validating CPU/memory requests, limits, and detecting overprovisioning."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Resource Limit Enforcement

> **Load trigger:** `"load resource-limits skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure workloads define safe resource requests and limits.

## Responsibilities

- Validate CPU/memory requests
- Validate CPU/memory limits
- Detect missing limits
- Detect overprovisioning

## Inputs

- Kubernetes manifests

## Outputs

- `resource-limits.json`

## Validation Rules

### Required Fields

- [ ] `resources.requests.cpu` defined
- [ ] `resources.requests.memory` defined
- [ ] `resources.limits.cpu` defined
- [ ] `resources.limits.memory` defined

### Limit Validity

- [ ] Limits >= Requests (for each resource)
- [ ] Requests > 0
- [ ] No extremely high limits without justification

### Overprovisioning Detection

| Workload Type | Typical CPU | Typical Memory |
|--------------|-------------|----------------|
| API Service | 100m-500m | 128Mi-512Mi |
| Worker | 200m-1000m | 256Mi-1Gi |
| CronJob | 100m-200m | 128Mi-256Mi |
| CLI Tool | 50m-200m | 64Mi-256Mi |

### Missing Limits

- [ ] Flag containers without limits
- [ ] Recommend appropriate limits based on workload type
- [ ] Block deployment if limits missing (optional)

## Output Format

```json
{
  "skill": "resource-limits",
  "status": "pass | fail",
  "resources_checked": 10,
  "violations": [
    {
      "severity": "high",
      "resource": "deployment/my-app",
      "container": "app",
      "issue": "No memory limit defined",
      "fix": "Add resources.limits.memory: 512Mi"
    }
  ],
  "overprovisioned": [
    {
      "resource": "deployment/simple-app",
      "container": "app",
      "current_cpu_limit": "4000m",
      "recommended_cpu_limit": "500m"
    }
  ]
}
```

## Success Criteria

- All workloads have valid resource limits
- No missing limits
- Overprovisioning detected and flagged
