---
name: spec-policy-validation
description: "Validate the specification against organizational policies. Use when checking required stages, security gates, naming conventions, and compliance rules in the spec."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Policy-as-Code Validation (Spec)

> **Load trigger:** `"load spec-policy-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate the specification against organizational policies.

## Responsibilities

- Validate required stages are noted in spec
- Validate required security gates are noted
- Validate naming conventions are specified
- Validate compliance rules are addressed

## Inputs

- `specification.md`
- Policy definitions (from `AGENTS.md`, policy files)

## Outputs

- `policy-report.json`
- `violations.txt`

## Validation Rules

### Pipeline Requirements

- [ ] CI/CD stages noted in spec (if build artifact)
- [ ] SBOM generation noted (if release artifact)
- [ ] Signing requirements noted (if containers)
- [ ] Test coverage expectations noted

### Security Requirements

- [ ] Authentication mechanism specified
- [ ] Authorization model specified
- [ ] Data protection requirements noted
- [ ] Secret handling requirements noted

### Naming Conventions

- [ ] Service naming conventions specified
- [ ] Resource naming conventions specified
- [ ] Label conventions specified

### Compliance

- [ ] Regulatory requirements addressed
- [ ] Audit requirements noted
- [ ] Data retention requirements noted

## Output Format

```json
{
  "skill": "spec-policy-validation",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Pipeline requirements",
      "status": "pass | fail | na",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- No policy violations in the specification
- All governance requirements addressed
