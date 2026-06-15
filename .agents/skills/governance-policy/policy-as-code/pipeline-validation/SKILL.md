---
name: pipeline-policy-validation
description: "Validate pipeline-spec.yaml against organizational rules. Use when checking required stages, quality gates, artifact signing, and SBOM generation."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Policy Validation

> **Load trigger:** `"load pipeline-policy-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate `pipeline-spec.yaml` against organizational rules.

## Responsibilities

- Validate required stages present
- Validate required quality gates
- Validate artifact signing
- Validate SBOM generation

## Inputs

- `pipeline-spec.yaml`

## Outputs

- `pipeline-policy.json`

## Validation Rules

### Required Stages

- [ ] Lint/format stage present
- [ ] Unit test stage present
- [ ] Integration test stage present (or justified N/A)
- [ ] Security scan stage present
- [ ] Build stage present
- [ ] Deploy stage present (with approval gate)

### Quality Gates

- [ ] Test failures block merge
- [ ] Security scan failures block merge
- [ ] Coverage thresholds enforced
- [ ] No critical/high findings allowed

### Artifact Requirements

- [ ] Image signing stage present (if containers)
- [ ] SBOM generation stage present (if release artifacts)
- [ ] Provenance attestation present

### Pipeline Hardening

- [ ] Actions pinned to commit SHAs
- [ ] Secrets accessed via `${{ secrets.NAME }}`
- [ ] No secrets logged
- [ ] Least privilege permissions

## Tools

- `yq` for YAML parsing
- Policy engine for validation

## Output Format

```json
{
  "skill": "pipeline-policy-validation",
  "status": "pass | fail",
  "stages": {
    "lint": { "present": true },
    "unit_test": { "present": true },
    "security_scan": { "present": true },
    "build": { "present": true },
    "deploy": { "present": true, "approval_required": true }
  },
  "violations": []
}
```

## Success Criteria

- No pipeline policy violations
- All required stages present
- Security gates enforced
