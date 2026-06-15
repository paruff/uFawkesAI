---
name: kustomize-validation
description: "Validate Kustomize overlays for all environments. Use when building overlays, validating patches, validating resource merging, or detecting missing bases or overlays."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kustomize Validation

> **Load trigger:** `"load kustomize-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate Kustomize overlays for all environments.

## Responsibilities

- Build overlays
- Validate patches
- Validate resource merging
- Detect missing bases or overlays

## Inputs

- `kustomization.yaml`

## Outputs

- `kustomize-report.json`

## Required Overlays

| Overlay | Path | Required |
|---------|------|----------|
| dev | `overlays/dev/` | Yes |
| staging | `overlays/staging/` | Yes |
| prod | `overlays/prod/` | Yes |

## Build Command

```bash
kustomize build overlays/dev
```

## Validation Rules

- [ ] All overlays build successfully
- [ ] Patches applied correctly
- [ ] Resources merged correctly
- [ ] No missing bases
- [ ] Images tagged correctly

## Output Format

```json
{
  "skill": "kustomize-validation",
  "status": "pass | fail",
  "overlays": {
    "dev": {"build": "pass", "resources": 10, "patches": 2},
    "staging": {"build": "pass", "resources": 10, "patches": 3},
    "prod": {"build": "pass", "resources": 10, "patches": 4}
  },
  "issues": []
}
```

## Success Criteria

- All overlays build successfully
- No missing bases or overlays
