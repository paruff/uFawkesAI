---
name: spec-template-governance
description: "Ensure the specification aligns with platform templates and golden paths. Use when validating naming, directory structure, service layout, and GitOps structure in the spec."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Template Governance (Spec)

> **Load trigger:** `"load spec-template-governance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure the specification aligns with platform templates and golden paths.

## Responsibilities

- Validate naming conventions are specified
- Validate directory structure is specified
- Validate service layout follows patterns
- Validate GitOps structure is specified

## Inputs

- `specification.md`
- Template rules (from golden-path templates)

## Outputs

- `template-governance.json`

## Validation Rules

### Naming Conventions

- [ ] Service names follow DNS naming rules
- [ ] Resource names follow project conventions
- [ ] Label values are specified

### Directory Structure

- [ ] Source code location specified
- [ ] Test file location specified
- [ ] Manifest location specified
- [ ] Pipeline location specified

### Service Layout

- [ ] Service type specified (API, worker, CLI, etc.)
- [ ] Entry point specified
- [ ] Configuration approach specified

### GitOps Structure

- [ ] Base/overlay structure specified (if K8s)
- [ ] Environment separation specified
- [ ] Image management approach specified

## Golden Path Templates

| Service Type | Expected Structure |
|-------------|-------------------|
| API Service | `src/routes/`, `src/services/`, `src/models/` |
| Worker | `src/handlers/`, `src/processors/` |
| CLI Tool | `src/commands/`, `src/utils/` |
| Library | `src/index.ts`, `src/types/` |

## Output Format

```json
{
  "skill": "spec-template-governance",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Naming conventions",
      "status": "pass | fail",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- Specification follows golden path templates
- Naming and structure conventions specified
