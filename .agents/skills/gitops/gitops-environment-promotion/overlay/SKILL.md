---
name: overlay-promotion
description: "Promote environment-specific overlays. Use when updating configmaps, secrets references, or environment variables."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Overlay Promotion

> **Load trigger:** `"load overlay-promotion skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Promote environment-specific overlays.

## Responsibilities

- Update configmaps
- Update secrets references
- Update environment variables

## Inputs

- Overlay files

## Outputs

- `overlay-promotion.json`

## Overlay Fields

| Field | Dev | Staging | Prod |
|-------|-----|---------|------|
| replicas | 1 | 2 | 3 |
| resources.cpu | 0.5 | 1 | 2 |
| resources.memory | 512Mi | 1Gi | 2Gi |
| log_level | debug | info | warn |
| autoscaling | false | false | true |

## Validation Rules

- [ ] Configmaps updated
- [ ] Secrets references valid
- [ ] Environment variables correct
- [ ] Manifests build successfully

## Output Format

```json
{
  "skill": "overlay-promotion",
  "status": "success",
  "overlay": "staging",
  "updates": [
    {"field": "replicas", "value": 2},
    {"field": "resources.cpu", "value": "1"},
    {"field": "log_level", "value": "info"}
  ],
  "build": "pass"
}
```

## Success Criteria

- Correct overlay updated
- Manifests build successfully
