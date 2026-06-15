---
name: sca
description: "Scan dependencies for known vulnerabilities. Use when dependency manifests change or during periodic security audits."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dependency Vulnerability Scanning (SCA)

> **Load trigger:** `"load sca skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Scan dependencies for known vulnerabilities and license risks.

## Responsibilities

- Parse dependency manifests
- Run vulnerability scans against known CVE databases
- Identify and classify CVEs by severity
- Check for deprecated or unmaintained packages
- Validate license compatibility

## Inputs

- Dependency manifests (`package.json`, `go.mod`, `requirements.txt`, `Cargo.toml`, `pom.xml`, etc.)
- Lock files (`package-lock.json`, `go.sum`, `poetry.lock`, etc.)

## Validation Rules

### Vulnerability Checks

- [ ] No critical CVEs in direct dependencies
- [ ] No high CVEs in direct dependencies
- [ ] Transitive dependency CVEs documented with risk assessment
- [ ] No dependencies with known exploit code available

### Dependency Hygiene

- [ ] All dependencies pinned to exact versions or narrow ranges
- [ ] No deprecated packages in use
- [ ] No packages with known maintenance issues
- [ ] Dependency count within reasonable bounds for project size

### License Compliance

- [ ] No copyleft licenses in proprietary code paths
- [ ] License compatibility verified for dependency graph
- [ ] New licenses reviewed and approved

## Tools

- `npm audit` / `yarn audit`
- `go vuln check`
- `pip-audit` / `safety`
- `cargo audit`
- Snyk, Trivy, or Grype for comprehensive scanning

## Output Format

```json
{
  "skill": "sca",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "package": "<package name>@<version>",
      "cve": "CVE-XXXX-XXXXX",
      "issue": "Description of the vulnerability",
      "fix": "Recommended remediation (upgrade path or workaround)"
    }
  ]
}
```

## Success Criteria

- No critical or high-severity vulnerabilities in direct dependencies
- All dependencies pinned and documented
- License compliance verified
