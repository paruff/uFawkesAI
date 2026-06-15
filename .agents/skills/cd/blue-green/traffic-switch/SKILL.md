---
name: traffic-switch
description: "Switch traffic from blue to green. Use when updating service selectors, validating traffic routing, or monitoring post-switch health."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Traffic Switch Execution

> **Load trigger:** `"load traffic-switch skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Switch traffic from blue to green.

## Responsibilities

- Update service selectors
- Validate traffic routing
- Monitor post-switch health

## Inputs

- `green-validation.json`

## Outputs

- `traffic-switch.json`

## Switch Methods

### Service Selector Update

```yaml
# Before (blue)
spec:
  selector:
    app: my-app
    version: v1.2.2

# After (green)
spec:
  selector:
    app: my-app
    version: v1.2.3
```

### Ingress Update

```yaml
# Before
backend:
  serviceName: my-app-blue
  servicePort: 80

# After
backend:
  serviceName: my-app-green
  servicePort: 80
```

## Validation Rules

- [ ] Service selector updated
- [ ] Traffic routed to green pods
- [ ] No traffic reaching blue pods
- [ ] Health maintained after switch

## Post-Switch Monitoring

| Duration | Check | Action |
|----------|-------|--------|
| 0-5 min | Health probes | Continue |
| 5-15 min | Error rate, latency | Monitor |
| 15+ min | All metrics | Decommission blue |

## Output Format

```json
{
  "skill": "traffic-switch",
  "method": "service-selector",
  "from_version": "v1.2.2",
  "to_version": "v1.2.3",
  "switch_time": "2025-01-15T10:30:00Z",
  "validation": {
    "traffic_routed": true,
    "health_maintained": true
  }
}
```

## Success Criteria

- Successful traffic switch
- No downtime
- Health maintained
