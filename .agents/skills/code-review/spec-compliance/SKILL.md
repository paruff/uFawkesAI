---
name: spec-compliance
description: "Verify that build output satisfies the specification. Use when comparing implementation against functional and non-functional requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Specification Compliance Validation

> **Load trigger:** `"load spec-compliance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Verify that the build output satisfies the specification.

## Responsibilities

- Compare implementation to functional requirements
- Compare implementation to non-functional requirements
- Identify missing or incomplete features
- Identify deviations from the specification

## Inputs

- `specification.md`
- Build output (code, manifests, pipelines)

## Outputs

- `spec-compliance.json`

## Validation Rules

### Functional Requirements

- [ ] Each functional requirement has a corresponding implementation
- [ ] Implementation matches the requirement's intent
- [ ] No extra features added without spec justification
- [ ] Edge cases from spec are handled

### Non-Functional Requirements

- [ ] Performance requirements met (response times, throughput)
- [ ] Scalability requirements addressed
- [ ] Availability requirements addressed
- [ ] Security requirements implemented

### Completeness

- [ ] No requirements skipped
- [ ] No partial implementations
- [ ] No placeholder or stub implementations left in place

### Deviation Tracking

- [ ] Any deviation from spec is documented
- [ ] Deviation has justification
- [ ] Deviation does not violate core requirements

## Output Format

```json
{
  "skill": "spec-compliance",
  "status": "pass | fail",
  "requirements": [
    {
      "id": "REQ-001",
      "description": "Requirement description",
      "status": "pass | fail | partial",
      "implementation": "How it was implemented",
      "notes": "Any deviations or issues"
    }
  ],
  "missing": [],
  "deviations": []
}
```

## Success Criteria

- Build output fully satisfies the specification
- All requirements accounted for
- Deviations documented and justified
