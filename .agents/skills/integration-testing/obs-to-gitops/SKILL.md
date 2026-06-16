---
name: obs-to-gitops-integration
description: "Validate that OBS writes correct manifests to the GitOps repo. Use when validating commit structure, overlays, environment resolution, or manifest correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: OBS → GitOps Integration Testing

> **Load trigger:** `"load obs-to-gitops-integration skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate that OBS writes correct manifests to the GitOps repo.

## Responsibilities

- Validate commit structure
- Validate overlays
- Validate environment resolution
- Validate manifest correctness

## Inputs

- OBS output
- GitOps repo

## Outputs

- `obs-gitops-report.json`
- `manifest-diff.txt`

## Sub-Skills

| Skill                              | Purpose                       |
| ---------------------------------- | ----------------------------- |
| `obs-to-gitops/overlay-resolution` | Validate overlay resolution   |
| `obs-to-gitops/commit-validation`  | Validate Git commit structure |

## Validation Rules

- [ ] Valid GitOps commits
- [ ] Correct overlays
- [ ] No schema violations
- [ ] Commit message follows convention
- [ ] Files changed correctly

## Output Format

```json
{
  "skill": "obs-to-gitops-integration",
  "status": "pass | fail",
  "commit": {
    "sha": "abc123",
    "message": "chore: update image to v1.3.0",
    "files_changed": 3
  },
  "overlays": {
    "dev": "pass",
    "staging": "pass",
    "prod": "pass"
  },
  "manifests_valid": true
}
```

## Success Criteria

- Valid GitOps commits
- Correct overlays
- No schema violations
