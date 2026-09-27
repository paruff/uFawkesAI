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

> **Load trigger:** `"load container-vulnerability-scanning skill"` > **DORA:** AI Capability 1: Clear and communicated AI stance
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

**This skill produces evidence only.** Trivy runs in
`.github/workflows/image-build.yml` and `.github/workflows/image-release.yml`,
but solely to append a report to the job summary (`|| true`); it never fails
the build. A Critical CVE therefore does not stop a release — it surfaces a
finding that the human releaser must act on.

| Severity | Response                                       |
| -------- | ---------------------------------------------- |
| Critical | Report as blocking; do not release until reviewed |
| High     | Report as blocking; review before release      |
| Medium   | Warn, fix within 1 week                        |
| Low      | Log, fix in next sprint                        |

To close the gap, make the Trivy step fail on Critical (drop `|| true`, add a
severity exit-code threshold) in both image workflows, then update this section.

**Enforcement: advisory.** Trivy runs in `image-build.yml` and
`image-release.yml` but only appends to the job summary (`|| true`). These
criteria are reported, not enforced.

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
    {
      "package": "openssl",
      "version": "1.1.1",
      "cve": "CVE-2021-3711",
      "severity": "critical",
      "fix": "1.1.1k"
    }
  ]
}
```

## Success Criteria

- No critical CVEs
- Remediation suggestions provided
