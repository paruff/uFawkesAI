---
name: artifact-flow-validation
description: "Ensure PIPE produces correct artifacts and OBS consumes them correctly. Use when validating SBOM presence, Cosign signatures, provenance, or image digest resolution."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Artifact Flow Validation

> **Load trigger:** `"load artifact-flow-validation skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Ensure PIPE produces correct artifacts and OBS consumes them correctly.

## Responsibilities

- Validate SBOM presence
- Validate Cosign signatures
- Validate provenance
- Validate image digest resolution

## Inputs

- `version.json`
- Build artifacts

## Outputs

- `artifact-flow.json`

## Required Artifacts

| Artifact | Producer | Consumer | Validation |
|----------|----------|----------|------------|
| `version.json` | PIPE | OBS | Valid semver |
| `sbom.json` | PIPE | OBS | Valid SPDX/CycloneDX |
| `signature` | PIPE | OBS | Valid Cosign |
| `provenance.json` | PIPE | OBS | Valid SLSA |
| `image_digest` | PIPE | OBS | sha256 match |

## Validation Rules

- [ ] All artifacts present
- [ ] All artifacts valid
- [ ] Artifacts flow correctly from PIPE to OBS
- [ ] No missing artifacts

## Output Format

```json
{
  "skill": "artifact-flow-validation",
  "status": "pass | fail",
  "artifacts": {
    "version_json": {"present": true, "valid": true},
    "sbom": {"present": true, "valid": true},
    "signature": {"present": true, "valid": true},
    "provenance": {"present": true, "valid": true},
    "image_digest": {"present": true, "valid": true}
  }
}
```

## Success Criteria

- All artifacts present and valid
- Correct flow from PIPE to OBS
