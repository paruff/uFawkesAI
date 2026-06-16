---
name: pipe-to-obs-integration
description: "Validate artifact flow and GitOps updates triggered by PIPE. Use when executing a full PIPE build, validating OBS receives correct artifacts, or validating OBS updates GitOps manifests correctly."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: PIPE → OBS Integration Testing

> **Load trigger:** `"load pipe-to-obs-integration skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Validate artifact flow and GitOps updates triggered by PIPE.

## Responsibilities

- Execute a full PIPE build
- Validate that OBS receives correct artifacts
- Validate that OBS updates GitOps manifests correctly
- Validate version.json, SBOM, signatures, and image digests

## Inputs

- Pipeline run
- `version.json`
- GitOps repo

## Outputs

- `pipe-obs-report.json`
- `manifest-diff.txt`

## Sub-Skills

| Skill                         | Purpose                                      |
| ----------------------------- | -------------------------------------------- |
| `pipe-to-obs/artifact-flow`   | Validate artifact production and consumption |
| `pipe-to-obs/manifest-update` | Validate manifest updates                    |

## Integration Flow

```
PIPE build → artifacts → OBS receives → OBS updates GitOps → manifests validated
```

## Validation Rules

- [ ] Correct image tag passed to OBS
- [ ] Correct image digest passed to OBS
- [ ] OBS creates valid Git commit
- [ ] Manifests valid YAML
- [ ] No schema violations

## Output Format

```json
{
  "skill": "pipe-to-obs-integration",
  "status": "pass | fail",
  "pipeline_run": "123",
  "artifacts": {
    "version_json": "present",
    "sbom": "present",
    "signature": "present",
    "image_digest": "present"
  },
  "obs_update": {
    "commit": "abc123",
    "files_changed": 3,
    "manifests_valid": true
  }
}
```

## Success Criteria

- Correct image tag and digest passed to OBS
- Correct GitOps update created
- No invalid manifests
