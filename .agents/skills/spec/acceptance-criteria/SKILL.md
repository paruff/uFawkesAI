---
name: acceptance-criteria
description: "Generate clear, testable acceptance criteria for the specification. Use when converting requirements into binary pass/fail assertions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Acceptance Criteria Generation

> **Load trigger:** `"load acceptance-criteria skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Generate clear, testable acceptance criteria for the specification.

## Responsibilities

- Convert requirements into binary pass/fail criteria
- Ensure criteria are measurable
- Ensure criteria align with governance rules
- Ensure criteria can be validated by the Review agent

## Inputs

- `requirements.json` (from requirements-extraction skill)
- `specification.md`

## Outputs

- `acceptance-criteria.json`

## Generation Rules

### Atomicity

- [ ] Each AC tests one specific behavior
- [ ] Each AC is independently verifiable
- [ ] No combined ACs ("and", "also", "plus")

### Clarity

- [ ] No ambiguous language ("should work", "fast enough")
- [ ] Specific inputs and expected outputs defined
- [ ] Edge cases covered where relevant
- [ ] Error cases covered where relevant

### Measurability

- [ ] Quantitative targets where possible (ms, %, count)
- [ ] Binary pass/fail possible (no "mostly", "generally")
- [ ] Test method identifiable (unit, integration, manual)

### Completeness

- [ ] Every requirement has at least one AC
- [ ] Non-functional requirements have measurable ACs
- [ ] Edge cases have ACs
- [ ] Error handling has ACs

## AC Format

```json
{
  "ac_id": "AC-01",
  "requirement_id": "REQ-001",
  "description": "Given [context], when [action], then [expected result]",
  "priority": "must-have | should-have | nice-to-have",
  "test_method": "unit | integration | e2e | manual",
  "measurable": true
}
```

## Examples

| Requirement | Acceptance Criteria |
|-------------|-------------------|
| User can sign up | AC-01: Given valid email/password, when user submits signup form, then account is created and confirmation email is sent |
| API responds quickly | AC-02: Given 100 concurrent requests, when measured, then p95 latency is < 200ms |
| Data is secure | AC-03: Given user A's data, when user B requests it, then 403 Forbidden is returned |

## Success Criteria

- Acceptance criteria are complete and testable
- Every requirement mapped to at least one AC
- No ambiguous language in ACs
