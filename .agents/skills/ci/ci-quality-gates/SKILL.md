---
name: ci-quality-gates
description: "Enforce quality thresholds before artifacts proceed to OBS or GitOps. Use when enforcing test coverage, linting, SAST/SCA, container vulnerability, or manifest validation thresholds."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Quality Gates

> **Load trigger:** `"load ci-quality-gates skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Enforce quality thresholds before artifacts are allowed to proceed to OBS or GitOps.

## Responsibilities

- Enforce test coverage thresholds
- Enforce linting rules
- Enforce SAST/SCA thresholds
- Enforce container vulnerability thresholds
- Enforce manifest validation

## Inputs

- Test results
- Security scan results
- Manifest validation results

## Outputs

- `quality-gates.json`
- `failed-gates.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-quality-gates/coverage` | Enforce test coverage thresholds |
| `ci-quality-gates/security` | Block on critical vulnerabilities |

## Gate Definitions

| Gate | Threshold | Severity |
|------|-----------|----------|
| Test coverage | ≥ 80% | Block |
| Lint errors | 0 | Block |
| Lint warnings | < 10 | Warn |
| SAST critical | 0 | Block |
| SAST high | < 3 | Warn |
| SCA critical | 0 | Block |
| Container critical | 0 | Block |
| Manifest valid | 100% | Block |

## Rules

- [ ] All gates evaluated
- [ ] Block gates fail pipeline
- [ ] Warn gates logged but don't block
- [ ] Gate results recorded

## Output Format

```json
{
  "skill": "ci-quality-gates",
  "status": "pass | fail",
  "gates": [
    {"name": "coverage", "value": 85, "threshold": 80, "status": "pass"},
    {"name": "lint", "errors": 0, "threshold": 0, "status": "pass"},
    {"name": "sast", "critical": 0, "threshold": 0, "status": "pass"},
    {"name": "container-scan", "critical": 0, "threshold": 0, "status": "pass"}
  ],
  "failed_gates": []
}
```

## Success Criteria

- All quality gates passed
- No critical violations
- Pipeline proceeds to artifact stage
