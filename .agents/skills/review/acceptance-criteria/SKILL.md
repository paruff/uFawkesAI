---
name: acceptance-criteria
description: "Validate that build output satisfies all acceptance criteria. Use when checking each AC for pass/fail status."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Acceptance Criteria Validation

> **Load trigger:** `"load acceptance-criteria skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate that the build output satisfies all acceptance criteria.

## Responsibilities

- Evaluate each acceptance criterion
- Mark pass/fail for each item
- Identify missing functionality
- Flag partially met criteria

## Inputs

- Acceptance criteria (from `tasks.json` or task files)
- Build output (code, manifests, tests)

## Outputs

- `acceptance-results.json`

## Validation Rules

### Evaluation

- [ ] Each AC evaluated independently
- [ ] AC tested against actual implementation, not assumed
- [ ] Evidence cited for each pass/fail decision
- [ ] Partial implementations flagged (not marked as pass)

### Completeness

- [ ] All ACs from all tasks accounted for
- [ ] No AC skipped without justification
- [ ] Cross-cutting ACs validated across all affected tasks

### Ambiguity

- [ ] Ambiguous ACs flagged for human clarification
- [ ] ACs requiring runtime validation noted
- [ ] ACs dependent on external systems noted

## AC Status Classification

| Status | Meaning |
|--------|---------|
| PASS | Implementation satisfies the AC completely |
| FAIL | Implementation does not satisfy the AC |
| PARTIAL | Implementation partially satisfies the AC |
| NOT TESTED | AC requires runtime testing not possible in review |
| AMBIGUOUS | AC is unclear and needs human clarification |

## Output Format

```json
{
  "skill": "acceptance-criteria",
  "status": "pass | fail",
  "total": 12,
  "passed": 10,
  "failed": 1,
  "partial": 1,
  "results": [
    {
      "task_id": "TASK-001",
      "ac_id": "AC-01",
      "description": "Specific, testable assertion",
      "status": "pass | fail | partial | not_tested | ambiguous",
      "evidence": "File:Line or test reference",
      "notes": "Any issues or ambiguities"
    }
  ]
}
```

## Success Criteria

- All acceptance criteria evaluated
- Each pass/fail decision backed by evidence
- Ambiguous ACs flagged for human review
