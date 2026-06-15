---
name: pipeline-policy
description: "Validate CI/CD pipeline correctness. Use when reviewing pipeline definitions for required stages, security gates, SBOM, and signing."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Policy Validation

> **Load trigger:** `"load pipeline-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate CI/CD pipeline correctness.

## Responsibilities

- Validate required stages present
- Validate security gates included
- Validate SBOM and signing stages
- Validate test coverage thresholds enforced

## Inputs

- `pipeline-spec.yaml`
- Governance rules

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

### Security Gates

- [ ] SAST scan stage present
- [ ] SCA/dependency scan stage present
- [ ] Image signing stage present (if containers)
- [ ] SBOM generation stage present (if release artifacts)

### Gating

- [ ] Test failures block merge
- [ ] Security scan failures block merge
- [ ] Deployment requires manual approval
- [ ] Coverage thresholds enforced

### Hardening

- [ ] Actions pinned to commit SHAs
- [ ] Secrets accessed via `${{ secrets.NAME }}`
- [ ] No secrets logged
- [ ] Least privilege permissions

## Tools

- `yq` for YAML parsing
- Policy engine (OPA, Kyverno) for validation
- `gh api` for GitHub Actions inspection

## Output Format

```json
{
  "skill": "pipeline-policy",
  "status": "pass | fail",
  "stages": {
    "lint": { "present": true, "required": true },
    "unit_test": { "present": true, "required": true },
    "integration_test": { "present": true, "required": true },
    "security_scan": { "present": true, "required": true },
    "build": { "present": true, "required": true },
    "deploy": { "present": true, "required": true, "approval_required": true }
  },
  "gates": {
    "sast": true,
    "sca": true,
    "signing": true,
    "sbom": true
  },
  "violations": []
}
```

## Success Criteria

- Pipeline complies with governance rules
- All required stages present
- Security gates enforced
