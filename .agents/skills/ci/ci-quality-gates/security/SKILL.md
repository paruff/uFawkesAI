---
name: ci-security-gate
description: "Block CI if critical vulnerabilities or insecure patterns are detected. Use when validating SAST, dependency scan, or container scan results."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Security Gate

> **Load trigger:** `"load ci-security-gate skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Block CI if critical vulnerabilities or insecure patterns are detected.

## Responsibilities

- Validate SAST results
- Validate dependency scan results
- Validate container scan results

## Inputs

- `sast.sarif` (SAST output)
- `dependency.json` (SCA output)
- `container-vulns.json` (container scan output)

## Outputs

- `security-gate.json`

## Thresholds

| Scan Type | Critical | High | Medium |
|-----------|----------|------|--------|
| SAST | 0 | < 5 | Warn |
| SCA (dependencies) | 0 | < 3 | Warn |
| Container scan | 0 | < 5 | Warn |

## Validation Rules

### SAST

- [ ] No critical vulnerabilities
- [ ] High vulnerabilities < 5
- [ ] No hardcoded secrets
- [ ] No SQL injection vectors

### SCA (Dependencies)

- [ ] No critical CVEs
- [ ] High CVEs < 3
- [ ] No known exploited vulnerabilities

### Container Scan

- [ ] No critical OS vulnerabilities
- [ ] No critical library vulnerabilities
- [ ] Base image from approved registry

## Output Format

```json
{
  "skill": "ci-security-gate",
  "status": "pass | fail",
  "scans": {
    "sast": {"critical": 0, "high": 2, "medium": 5, "status": "pass"},
    "sca": {"critical": 0, "high": 1, "medium": 3, "status": "pass"},
    "container": {"critical": 0, "high": 0, "medium": 2, "status": "pass"}
  },
  "failed_scans": []
}
```

## Success Criteria

- No critical vulnerabilities
- High vulnerabilities within limits
- Pipeline fails on critical findings
