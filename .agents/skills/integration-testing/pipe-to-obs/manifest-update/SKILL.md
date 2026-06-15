---
name: manifest-update-validation
description: "Validate that OBS updates manifests correctly based on PIPE output. Use when validating tag replacement, digest replacement, or environment overlays."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Manifest Update Validation

> **Load trigger:** `"load manifest-update-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that OBS updates manifests correctly based on PIPE output.

## Responsibilities

- Validate tag replacement
- Validate digest replacement
- Validate environment overlays

## Inputs

- GitOps repo
- `version.json`

## Outputs

- `manifest-update.json`

## Update Targets

| Field | Location | Expected Value |
|-------|----------|----------------|
| `newTag` | `kustomization.yaml` | `v1.3.0` |
| `image` | `deployment.yaml` | `my-app:v1.3.0@sha256:abc123` |
| `version` | `version.json` | `1.3.0` |

## Validation Rules

- [ ] Tag replaced correctly
- [ ] Digest replaced correctly
- [ ] All environment overlays updated
- [ ] Manifests build successfully

## Output Format

```json
{
  "skill": "manifest-update-validation",
  "status": "pass | fail",
  "updates": {
    "dev": {"tag": "pass", "digest": "pass", "build": "pass"},
    "staging": {"tag": "pass", "digest": "pass", "build": "pass"},
    "prod": {"tag": "pass", "digest": "pass", "build": "pass"}
  },
  "total_updates": 9,
  "failures": 0
}
```

## Success Criteria

- Correct tag and digest applied
- All overlays updated
