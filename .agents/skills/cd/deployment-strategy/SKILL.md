---
name: deployment-strategy
description: "Select the appropriate rollout strategy for each environment. Use when reading strategy from pipeline-spec, validating compatibility, or generating strategy plans."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Deployment Strategy Selection

> **Load trigger:** `"load deployment-strategy skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Select the appropriate rollout strategy for each environment.

## Responsibilities

- Read strategy from pipeline-spec.yaml
- Validate strategy compatibility
- Select canary/blue-green/rolling
- Generate strategy plan

## Inputs

- `pipeline-spec.yaml`
- Environment config

## Outputs

- `strategy-selection.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `deployment-strategy/compatibility` | Validate strategy for environment |
| `deployment-strategy/plan-generation` | Generate rollout plan |

## Strategy Options

| Strategy | Description | Use When |
|----------|-------------|----------|
| Rolling | Replace pods gradually | Default, low risk |
| Canary | Route % traffic to new | Medium risk, need metrics |
| Blue-Green | Deploy alongside, switch | Zero-downtime critical |

## Strategy Selection Rules

| Environment | Default | Override |
|-------------|---------|----------|
| dev | Rolling | — |
| staging | Canary (10%) | pipeline-spec |
| production | Canary (10%) | pipeline-spec |

## Rules

- [ ] Strategy compatible with cluster capabilities
- [ ] Strategy compatible with controller (Argo Rollouts, Flagger)
- [ ] Strategy plan generated before execution

## Output Format

```json
{
  "skill": "deployment-strategy",
  "environment": "production",
  "strategy": "canary",
  "canary_percent": 10,
  "steps": [
    {"traffic": 10, "duration": "5m"},
    {"traffic": 25, "duration": "5m"},
    {"traffic": 50, "duration": "10m"},
    {"traffic": 100}
  ]
}
```

## Success Criteria

- Correct strategy selected
- Strategy compatible with environment
- Plan generated
