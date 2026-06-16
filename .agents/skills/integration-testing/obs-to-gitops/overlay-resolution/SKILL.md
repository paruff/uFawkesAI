---
name: overlay-resolution-testing
description: "Validate that OBS resolves environment overlays correctly. Use when validating dev/stage/prod overlays, configmap and secret references, or patch merging."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Overlay Resolution Testing

> **Load trigger:** `"load overlay-resolution-testing skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that OBS resolves environment overlays correctly.

## Responsibilities

- Validate dev/stage/prod overlays
- Validate configmap and secret references
- Validate patch merging

## Inputs

- `overlays/`
- OBS output

## Outputs

- `overlay-resolution.json`

## Overlay Structure

```
overlays/
├── dev/
│   ├── kustomization.yaml
│   ├── configmap.yaml
│   └── patches/
├── staging/
│   ├── kustomization.yaml
│   ├── configmap.yaml
│   └── patches/
└── prod/
    ├── kustomization.yaml
    ├── configmap.yaml
    └── patches/
```

## Validation Rules

- [ ] All overlays resolve cleanly
- [ ] Configmaps valid
- [ ] Secrets references valid
- [ ] Patches applied correctly
- [ ] No missing bases

## Output Format

```json
{
  "skill": "overlay-resolution-testing",
  "status": "pass | fail",
  "overlays": {
    "dev": {"resolve": "pass", "configmaps": "pass", "secrets": "pass", "patches": "pass"},  # pragma: allowlist secret
    "staging": {"resolve": "pass", "configmaps": "pass", "secrets": "pass", "patches": "pass"},  # pragma: allowlist secret
    "prod": {"resolve": "pass", "configmaps": "pass", "secrets": "pass", "patches": "pass"}  # pragma: allowlist secret
  }
}
```

## Success Criteria

- All overlays resolve cleanly
- No missing bases or overlays
