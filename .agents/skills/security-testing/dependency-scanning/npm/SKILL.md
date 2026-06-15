---
name: npm-dependency-scanning
description: "Scan JavaScript/TypeScript dependencies for vulnerabilities. Use when scanning package-lock.json, validating dependency trees, or detecting vulnerable transitive dependencies."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: NPM Dependency Scanning

> **Load trigger:** `"load npm-dependency-scanning skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Scan JavaScript/TypeScript dependencies for vulnerabilities.

## Responsibilities

- Scan package-lock.json
- Validate dependency tree
- Detect vulnerable transitive dependencies

## Inputs

- `package-lock.json`

## Outputs

- `npm-deps.json`

## Scan Command

```bash
trivy fs --scanners vuln --format json package-lock.json
```

## Validation Rules

- [ ] package-lock.json exists
- [ ] All dependencies scanned
- [ ] Transitive dependencies included
- [ ] No critical CVEs
- [ ] CVEs documented

## Output Format

```json
{
  "skill": "npm-dependency-scanning",
  "status": "pass | fail",
  "total_dependencies": 450,
  "vulnerabilities": {
    "critical": 0,
    "high": 1,
    "medium": 3,
    "low": 5
  },
  "vulnerable_packages": [
    {"name": "lodash", "version": "4.17.20", "cve": "CVE-2021-23337", "severity": "high"}
  ]
}
```

## Success Criteria

- No critical CVEs
- All vulnerabilities documented
