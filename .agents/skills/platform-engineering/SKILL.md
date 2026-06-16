---
name: platform-engineering
description: "Platform engineering enforcement covering golden path validation, pipeline-spec compliance, template drift detection, and skill dependency management."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Platform Engineering

> **Load trigger:** `"load platform-engineering skill"`
> **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Enforce platform engineering standards including golden path validation, pipeline-spec compliance, template drift detection, and skill dependency management.

## Responsibilities

- Validate projects follow golden paths
- Enforce pipeline-spec compliance
- Detect template drift from standards
- Manage skill dependency graph
- Ensure consistent project structure

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `platform-engineering/golden-path-validation` | Ensure projects follow Fawkes conventions |
| `platform-engineering/pipeline-spec-enforcement` | Ensure pipeline-spec.yaml compliance |
| `platform-engineering/skill-dependency-graph` | Define and validate skill dependencies |
| `platform-engineering/template-drift-detection` | Detect drift from templates |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `golden-paths` | Uses golden path definitions |
| `pipeline-spec` | Uses pipeline-spec rules |

## Output Format

```json
{
  "skill": "platform-engineering",
  "status": "pass | fail",
  "golden_paths": {
    "testing": "pass",
    "security": "pass",
    "observability": "pass"
  },
  "pipeline_spec": {
    "stages_valid": true,
    "gates_present": true
  },
  "template_drift": {
    "drift_score": 5,
    "recommendations": []
  }
}
```
