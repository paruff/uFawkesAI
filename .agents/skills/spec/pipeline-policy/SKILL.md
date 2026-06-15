---
name: spec-pipeline-policy
description: "Ensure the specification aligns with pipeline governance rules. Use when validating CI/CD stages, SBOM, signing, and test coverage requirements in the spec."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Pipeline Policy Validation (Spec)

> **Load trigger:** `"load spec-pipeline-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the specification aligns with pipeline governance rules.

## Responsibilities

- Validate required CI/CD stages are noted
- Validate SBOM requirements are noted
- Validate signing requirements are noted
- Validate test coverage requirements are noted

## Inputs

- `specification.md`
- Existing `pipeline-spec.yaml` (if exists)

## Outputs

- `pipeline-policy.json`

## Validation Rules

### Required Stages

- [ ] Lint/format stage noted in spec
- [ ] Unit test stage noted in spec
- [ ] Integration test stage noted (if applicable)
- [ ] Security scan stage noted
- [ ] Build stage noted
- [ ] Deploy stage noted (with approval requirement)

### Security Gates

- [ ] SAST requirements noted
- [ ] SCA/dependency scan requirements noted
- [ ] Image signing requirements noted (if containers)
- [ ] SBOM generation requirements noted

### Test Coverage

- [ ] Minimum coverage threshold specified
- [ ] Coverage types specified (line, branch, function)

### Artifact Requirements

- [ ] Container image requirements noted (if applicable)
- [ ] Binary artifact requirements noted (if applicable)
- [ ] Release artifact requirements noted

## Output Format

```json
{
  "skill": "spec-pipeline-policy",
  "status": "pass | fail",
  "stages_noted": {
    "lint": true,
    "unit_test": true,
    "integration_test": true,
    "security_scan": true,
    "build": true,
    "deploy": true
  },
  "gates_noted": {
    "sast": true,
    "sca": true,
    "signing": true,
    "sbom": true
  },
  "violations": []
}
```

## Success Criteria

- Specification aligns with pipeline governance
- All required stages and gates noted
