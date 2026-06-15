---
name: helm-validation
description: "Validate Helm charts used by OBS or PIPE. Use when linting charts, rendering templates, validating values files, or checking schema."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Helm Validation

> **Load trigger:** `"load helm-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate Helm charts used by OBS or PIPE.

## Responsibilities

- Lint charts
- Render templates
- Validate values files
- Validate schema

## Inputs

- `Chart.yaml`
- `values.yaml`

## Outputs

- `helm-report.json`

## Commands

```bash
# Lint
helm lint charts/my-app

# Render templates
helm template my-app charts/my-app -f values.yaml

# Validate against schema
helm lint charts/my-app --strict
```

## Validation Rules

- [ ] No lint errors
- [ ] Templates render correctly
- [ ] Values match schema
- [ ] No missing required values
- [ ] RBAC templates valid

## Output Format

```json
{
  "skill": "helm-validation",
  "status": "pass | fail",
  "chart": "my-app",
  "version": "1.0.0",
  "lint": {"errors": 0, "warnings": 0},
  "templates_rendered": 12,
  "values_valid": true
}
```

## Success Criteria

- No lint errors
- Valid rendered manifests
- Values match schema
