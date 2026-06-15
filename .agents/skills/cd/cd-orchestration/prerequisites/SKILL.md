---
name: delivery-prerequisites
description: "Ensure all conditions are met before delivery begins. Use when validating CI success, artifact signatures, SBOM presence, or version.json correctness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Delivery Prerequisite Validation

> **Load trigger:** `"load delivery-prerequisites skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all conditions are met before delivery begins.

## Responsibilities

- Validate CI success
- Validate artifact signatures
- Validate SBOM presence
- Validate version.json correctness
- Validate environment readiness

## Inputs

- CI outputs
- `version.json`
- Artifact signatures

## Outputs

- `delivery-prereq.json`

## Prerequisites

### CI Validation

| Check | Required |
|-------|----------|
| CI pipeline passed | Yes |
| All tests passed | Yes |
| Security scans passed | Yes |
| Build artifacts produced | Yes |

### Artifact Validation

| Check | Required |
|-------|----------|
| Image signed (Cosign) | Yes |
| SBOM generated (Syft) | Yes |
| Image in registry | Yes |
| Digest recorded | Yes |

### Version Validation

| Check | Required |
|-------|----------|
| version.json exists | Yes |
| version.json valid JSON | Yes |
| Version follows semver | Yes |
| Changelog updated | Yes |

### Environment Validation

| Check | Required |
|-------|----------|
| Target cluster reachable | Yes |
| Target namespace exists | Yes |
| Resource quota available | Yes |
| No active freeze window | Yes |

## Validation Rules

- [ ] All prerequisites checked
- [ ] Failure blocks delivery
- [ ] Prerequisites logged

## Output Format

```json
{
  "skill": "delivery-prerequisites",
  "status": "pass | fail",
  "checks": {
    "ci_passed": true,
    "image_signed": true,
    "sbom_generated": true,
    "version_json_valid": true,
    "environment_ready": true
  },
  "blockers": []
}
```

## Success Criteria

- All prerequisites satisfied
- Failure blocks delivery
- Checks logged
