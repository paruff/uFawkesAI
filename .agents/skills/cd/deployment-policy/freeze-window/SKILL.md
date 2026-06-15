---
name: freeze-window
description: "Block deployments during freeze windows. Use when reading freeze config, validating current time, or blocking/allowing deployments."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Deployment Freeze Window Enforcement

> **Load trigger:** `"load freeze-window skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Block deployments during freeze windows.

## Responsibilities

- Read freeze window configuration
- Validate current time against freeze windows
- Block or allow deployment

## Inputs

- `freeze-window.yaml`
- Current time

## Outputs

- `freeze-window.json`

## Freeze Window Config

```yaml
freeze_windows:
  - name: "holiday-freeze"
    start: "2025-12-24T00:00:00Z"
    end: "2025-12-26T23:59:59Z"
    environments: ["production"]
    
  - name: "monthly-maintenance"
    schedule: "first-saturday"
    start_time: "02:00"
    end_time: "06:00"
    environments: ["staging", "production"]
    
  - name: "weekend-freeze"
    schedule: "weekends"
    environments: ["production"]
```

## Freeze Types

| Type | Description | Bypass |
|------|-------------|--------|
| Hard freeze | No deployments allowed | Emergency only |
| Soft freeze | Deployments allowed with approval | Manual approval |
| Environment-specific | Freeze only certain envs | N/A |

## Validation Rules

- [ ] Current time checked against all freeze windows
- [ ] Environment-specific freezes checked
- [ ] Freeze status determined
- [ ] Bypass requires explicit approval

## Output Format

```json
{
  "skill": "freeze-window",
  "deployment_allowed": false,
  "active_freeze": {
    "name": "holiday-freeze",
    "start": "2025-12-24T00:00:00Z",
    "end": "2025-12-26T23:59:59Z",
    "environments": ["production"]
  },
  "reason": "Active freeze window: holiday-freeze"
}
```

## Success Criteria

- Freeze windows enforced
- Deployments blocked during freeze
- Bypass requires approval
