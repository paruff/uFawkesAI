---
name: spec
description: "Extract structured specification from human intent. Use when converting requirements into acceptance criteria, constraints, and governance alignment."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Spec

> **Load trigger:** `"load spec skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Extract structured specification from human intent.

## Responsibilities

- Convert human intent into requirements
- Define acceptance criteria
- Document constraints
- Align with governance policies
- Validate completeness

## Sub-Skills

| Skill                          | Purpose                                  |
| ------------------------------ | ---------------------------------------- |
| `spec/requirements-extraction` | Extract requirements from human intent   |
| `spec/acceptance-criteria`     | Define testable acceptance criteria      |
| `spec/policy-validation`       | Validate against organizational policies |
| `spec/pipeline-policy`         | Ensure pipeline compliance               |
| `spec/k8s-policy`              | Kubernetes policy alignment              |
| `spec/template-governance`     | Template compliance validation           |

## Dependencies

| Skill  | Relationship                               |
| ------ | ------------------------------------------ |
| (none) | Foundation skill, no upstream dependencies |

## Inputs

- Human intent (requirements, feature request, bug fix)
- Policy documents (if available)
- Existing specification (if updating)

## Outputs

- `specification.md`
- `acceptance-criteria.md`
- `constraints.md`

## Extraction Rules

### Requirements

- [ ] Requirements are clear and unambiguous
- [ ] Requirements are testable
- [ ] Requirements are prioritized
- [ ] Dependencies documented

### Acceptance Criteria

- [ ] Each requirement has acceptance criteria
- [ ] Acceptance criteria are specific and measurable
- [ ] Edge cases documented
- [ ] Error scenarios defined

### Governance

- [ ] Aligns with organizational policies
- [ ] Complies with security requirements
- [ ] Follows naming conventions
- [ ] Meets documentation standards

## Output Format

```json
{
  "skill": "spec",
  "status": "pass | fail",
  "requirements": [
    {
      "id": "REQ-1",
      "description": "User can login with email",
      "priority": "high",
      "acceptance_criteria": [
        "AC-1.1: User receives confirmation email",
        "AC-1.2: Account is activated within 24 hours"
      ]
    }
  ],
  "constraints": [
    "Must support iOS 15+ and Android 12+",
    "Must use existing authentication service"
  ],
  "governance_alignment": {
    "security": "pass",
    "compliance": "pass"
  }
}
```

## Success Criteria

- All requirements documented
- Acceptance criteria are testable
- Governance alignment confirmed
- No ambiguities identified
