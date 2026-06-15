---
name: delivery-plan-generation
description: "Generate a deterministic plan describing how delivery will proceed. Use when determining target environments, rollout strategy, promotion order, or validation steps."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Delivery Plan Generation

> **Load trigger:** `"load delivery-plan-generation skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Generate a deterministic plan describing how delivery will proceed.

## Responsibilities

- Determine target environments
- Determine rollout strategy per environment
- Determine promotion order
- Determine validation steps

## Inputs

- `pipeline-spec.yaml`
- `version.json`

## Outputs

- `delivery-plan.json`

## Plan Generation Rules

### Environment Detection

| Pipeline Spec | Target Environments |
|--------------|-------------------|
| `delivery.targets: [dev]` | dev |
| `delivery.targets: [dev, staging]` | dev → staging |
| `delivery.targets: [dev, staging, production]` | dev → staging → production |

### Strategy Selection

| Environment | Default Strategy | Override |
|-------------|-----------------|----------|
| dev | Rolling | — |
| staging | Canary (10%) | pipeline-spec |
| production | Canary (10%) | pipeline-spec |

### Validation Steps

| Environment | Validation |
|-------------|-----------|
| dev | Health probes, basic smoke |
| staging | Health probes, integration tests |
| production | Health probes, full test suite, SLO |

## Output Format

```json
{
  "skill": "delivery-plan-generation",
  "version": "v1.2.3",
  "environments": [
    {
      "name": "dev",
      "strategy": "rolling",
      "validation": ["health-probes", "smoke-tests"],
      "approval": "automated"
    },
    {
      "name": "staging",
      "strategy": "canary",
      "canary_percent": 10,
      "validation": ["health-probes", "integration-tests"],
      "approval": "automated"
    },
    {
      "name": "production",
      "strategy": "canary",
      "canary_percent": 10,
      "validation": ["health-probes", "full-tests", "slo-check"],
      "approval": "manual"
    }
  ]
}
```

## Success Criteria

- Valid delivery plan generated
- Environments in correct order
- Strategies appropriate for each environment
