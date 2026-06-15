---
name: e2e-test-execution
description: "Validate full system behavior from the user's perspective. Use when running end-to-end tests to verify complete workflows and acceptance criteria."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: End-to-End Test Execution

> **Load trigger:** `"load e2e-test-execution skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate full system behavior from the user's perspective.

## Responsibilities

- Execute E2E test suite
- Validate workflows end-to-end
- Validate acceptance criteria
- Detect regressions

## Inputs

- Build output
- E2E test files
- `acceptance-criteria.md` (or from tasks)

## Outputs

- `e2e-test-results.json`
- `e2e-test-report.md`

## Execution Rules

### Pre-Run

- [ ] Application deployed to test environment
- [ ] All dependent services running
- [ ] Test data seeded
- [ ] Browser/UI available (if UI tests)
- [ ] API endpoints accessible

### Execution

- [ ] All E2E workflows executed
- [ ] User journeys validated
- [ ] Acceptance criteria verified
- [ ] Error scenarios validated

### Post-Run

- [ ] Pass/fail counts recorded
- [ ] Failure details captured (with screenshots if UI)
- [ ] Acceptance criteria mapping documented
- [ ] Regression assessment made

## Workflow Validation

### User Journey Mapping

| Journey | Test File | Status |
|---------|-----------|--------|
| User signup → login → dashboard | `signup.e2e.ts` | PASS |
| Create item → edit → delete | `crud.e2e.ts` | PASS |
| Checkout flow → payment → confirmation | `checkout.e2e.ts` | PASS |

### Acceptance Criteria Verification

- [ ] Each AC maps to at least one E2E test
- [ ] AC test results documented
- [ ] Uncovered ACs flagged as findings

## Tools

| Type | Tool | Notes |
|------|------|-------|
| API | Supertest, httpx, httptest | HTTP-level E2E |
| UI | Playwright, Cypress, Selenium | Browser automation |
| CLI | Bash scripts, expect | Command-line E2E |

## Output Format

```json
{
  "skill": "e2e-test-execution",
  "status": "pass | fail",
  "total": 5,
  "passed": 5,
  "failed": 0,
  "workflows_tested": [
    "User signup → login → dashboard",
    "Create item → edit → delete"
  ],
  "acceptance_criteria_coverage": {
    "total": 12,
    "covered": 10,
    "uncovered": ["AC-11: Multi-language support", "AC-12: Offline mode"]
  },
  "failures": []
}
```

## Success Criteria

- All E2E tests pass
- Acceptance criteria covered
- No regressions detected
