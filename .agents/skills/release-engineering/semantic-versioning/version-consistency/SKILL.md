---
name: version-consistency
description: "Ensure version.json matches Git tags, manifests, and artifacts. Use when validating version alignment across the release pipeline."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Version Consistency Validation

> **Load trigger:** `"load version-consistency skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Ensure version.json matches Git tags, manifests, and artifacts.

## Responsibilities

- Validate version.json
- Validate Git tag alignment
- Validate manifest version fields
- Validate image tags in overlays

## Inputs

- `version.json`
- Git tags
- Manifests
- Kustomize overlays

## Outputs

- `version-consistency.json`

## Validation Rules

- [ ] version.json version matches latest Git tag
- [ ] Manifest image tags match version.json
- [ ] Overlay image tags match version.json
- [ ] No stale versions in any artifact
- [ ] Version format valid semver

## Check Points

| Artifact | Field | Expected |
|----------|-------|----------|
| `version.json` | `version` | Matches Git tag |
| `deployment.yaml` | `image` tag | Matches version.json |
| `kustomization.yaml` | `newTag` | Matches version.json |
| `package.json` | `version` | Matches version.json |

## Output Format

```json
{
  "skill": "version-consistency",
  "status": "pass | fail",
  "version_json": "1.3.0",
  "git_tag": "1.3.0",
  "manifests": {
    "deployment.yaml": "pass",
    "kustomization.yaml": "pass"
  },
  "mismatches": []
}
```

## Success Criteria

- No version mismatches across all artifacts
