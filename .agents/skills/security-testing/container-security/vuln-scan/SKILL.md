---
name: container-vulnerability-scanning
description: "Scan container layers for OS and application vulnerabilities. Use when scanning image layers, validating CVE severity, or checking remediation suggestions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Container Vulnerability Scanning

> **Load trigger:** `"load container-vulnerability-scanning skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Scan container layers for OS and application vulnerabilities.

## Responsibilities

- Scan image layers
- Validate CVE severity
- Validate remediation suggestions

## Inputs

- Container image

## Outputs

- `container-vulns.json`

## Scan Command

```bash
trivy image --severity CRITICAL,HIGH --format json <image>
```

## CVE Severity Thresholds

| Severity | Action |
|----------|--------|
| Critical | Block deploy, immediate fix |
| High | Block deploy, fix within 24h |
| Medium | Warn, fix within 1 week |
| Low | Log, fix in next sprint |

## Validation Rules

- [ ] All image layers scanned
- [ ] No critical CVEs
- [ ] Remediation suggestions provided
- [ ] CVEs documented

## Output Format

```json
{
  "skill": "container-vulnerability-scanning",
  "status": "pass | fail",
  "image": "my-app:v1.3.0",
  "total_layers": 15,
  "vulnerabilities": {
    "critical": 0,
    "high": 0,
    "medium": 2,
    "low": 5
  },
  "vulnerable_packages": [
    {"package": "openssl", "version": "1.1.1", "cve": "CVE-2021-3711", "severity": "critical", "fix": "1.1.1k"}
  ]
}
```

## Success Criteria

- No critical CVEs
- Remediation suggestions provided
