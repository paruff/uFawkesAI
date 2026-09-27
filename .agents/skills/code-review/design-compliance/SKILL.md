---
name: design-compliance
description: "Verify that build output matches the design. Use when validating architecture alignment, component boundaries, interfaces, and integration points."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Design Compliance Validation

> **Load trigger:** `"load design-compliance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Verify that the build output matches the design.

## Responsibilities

- Validate architecture alignment
- Validate component boundaries
- Validate interfaces and data models
- Validate integration points

## Inputs

- `design.md`
- Build output (code, manifests)

## Outputs

- `design-compliance.json`

## Validation Rules

### Architecture Alignment

- [ ] Layer structure follows design (UI → Service → Data)
- [ ] No circular dependencies between layers
- [ ] Dependency direction matches design
- [ ] Shared libraries used as intended

### Component Boundaries

- [ ] Components match design decomposition
- [ ] No cross-component coupling beyond what design specifies
- [ ] API contracts between components match design

### Interfaces and Data Models

- [ ] Public interfaces match design
- [ ] Data models match design schemas
- [ ] Request/response shapes match design
- [ ] Error types match design

### Integration Points

- [ ] External service integrations match design
- [ ] Database access patterns match design
- [ ] Messaging patterns match design
- [ ] Authentication flow matches design

## Output Format

```json
{
  "skill": "design-compliance",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Architecture alignment",
      "status": "pass | fail",
      "details": "Description of compliance or violation"
    }
  ],
  "violations": []
}
```

## Success Criteria

- Build output matches the design
- Component boundaries respected
- Interfaces and data models correct
