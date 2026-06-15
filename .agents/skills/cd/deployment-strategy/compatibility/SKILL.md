---
name: strategy-compatibility
description: "Ensure the chosen strategy is valid for the environment. Use when validating cluster capabilities, controller capabilities, or resource constraints."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Strategy Compatibility Validation

> **Load trigger:** `"load strategy-compatibility skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the chosen strategy is valid for the environment.

## Responsibilities

- Validate cluster capabilities
- Validate controller capabilities
- Validate resource constraints

## Inputs

- Environment config
- Cluster state

## Outputs

- `strategy-compatibility.json`

## Compatibility Checks

### Controller Requirements

| Strategy | Required Controller |
|----------|-------------------|
| Rolling | None (native K8s) |
| Canary | Argo Rollouts or Flagger |
| Blue-Green | Argo Rollouts or custom |

### Cluster Requirements

| Strategy | Requirements |
|----------|-------------|
| Rolling | Sufficient replicas for rollout |
| Canary | Load balancer or ingress supporting traffic split |
| Blue-Green | Double resource capacity |

### Resource Requirements

| Strategy | Extra Resources |
|----------|----------------|
| Rolling | 0% (replaces in-place) |
| Canary | +canary_percent capacity |
| Blue-Green | +100% capacity |

## Validation Rules

- [ ] Required controllers installed
- [ ] Sufficient cluster resources
- [ ] Traffic splitting capability available
- [ ] Health check endpoints configured

## Output Format

```json
{
  "skill": "strategy-compatibility",
  "strategy": "canary",
  "compatible": true,
  "checks": {
    "controller_available": true,
    "resources_sufficient": true,
    "traffic_splitting": true
  },
  "issues": []
}
```

## Success Criteria

- Strategy is compatible with environment
- All checks passed
- Issues documented
