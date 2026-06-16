---
name: review
description: "Review PR and build output for quality, security, and compliance. Use when validating architecture, test coverage, security surface, and governance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Review

> **Load trigger:** `"load review skill"` 
> **DORA:** Cap 4 + 6 (Continuous Delivery + Operations)
> **Token cost:** Medium

## Purpose

Review PR and build output for quality, security, and compliance.

## Responsibilities

- Validate architecture compliance
- Check test coverage and gaps
- Identify security surface
- Scan for secrets and vulnerabilities
- Validate governance policies
- Assess code quality

## Modes

### PR Review Mode

Consumes PR diff and validates:

- Architecture compliance
- Test gap analysis
- Security surface identification
- Secrets scanning
- Dependency review
- Auth & data handling review
- fawkes suite gates check

### Build Validation Mode

Consumes build output and validates:

- Spec compliance
- Design compliance
- Acceptance criteria validation
- Code quality
- Pipeline policy
- K8s policy
- GitOps overlay
- Security & RBAC
- Secret governance
- Policy-as-code

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `review/spec-compliance` | Validate against specification |
| `review/design-compliance` | Validate against architecture |
| `review/code-quality` | Assess code quality |
| `review/acceptance-criteria` | Validate acceptance criteria |
| `review/security-rbac` | RBAC validation |
| `review/secret-governance` | Secret management review |
| `review/policy-validation` | Policy-as-code validation |
| `review/k8s-policy` | Kubernetes policy compliance |
| `review/pipeline-policy` | Pipeline policy validation |
| `review/gitops-overlay` | GitOps overlay validation |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `build` | Consumes build output |
| `test-execution` | Consumes test results |
| `spec` | Validates against requirements |
| `design` | Validates against architecture |

## Inputs

- PR diff (PR Review mode)
- Build output (Build Validation mode)
- `specification.md`
- `design.md`
- Test results

## Outputs

- `review-report.json`
- `findings.json`
- `recommendations.json`

## Review Rules

### Architecture Compliance

- [ ] Follows established patterns
- [ ] Respects layer boundaries
- [ ] No circular dependencies
- [ ] Single responsibility maintained

### Test Coverage

- [ ] All requirements have tests
- [ ] Critical paths covered
- [ ] Edge cases tested
- [ ] No unexplained skips

### Security Surface

- [ ] No hardcoded secrets
- [ ] Input validation present
- [ ] Auth changes flagged
- [ ] New dependencies reviewed

### Code Quality

- [ ] No `any` types in TypeScript
- [ ] No commented-out code
- [ ] No TODO without issue numbers
- [ ] Follows style guide

### Governance

- [ ] Complies with policies
- [ ] Meets documentation standards
- [ ] Follows naming conventions
- [ ] Aligns with platform requirements

## Output Format

```json
{
  "skill": "review",
  "mode": "pr-review | build-validation",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "category": "architecture | test | security | quality",
      "description": "Finding description",
      "location": "file.ts:42",
      "recommendation": "How to fix"
    }
  ],
  "summary": {
    "critical": 0,
    "high": 1,
    "medium": 3,
    "low": 5
  },
  "decision": "approve | request-changes"
}
```

## Success Criteria

- All critical/high findings addressed
- Architecture compliance validated
- Test coverage adequate
- Security surface acceptable
- Governance policies met
