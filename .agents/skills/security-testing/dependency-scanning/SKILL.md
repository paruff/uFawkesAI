---
name: dependency-scanning
description: "Detect vulnerable dependencies in NPM, Python, Go, and container layers. Use when scanning package.json, requirements.txt, Dockerfile, or validating SBOM."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Dependency & Supply Chain Scanning

> **Load trigger:** `"load dependency-scanning skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Detect vulnerable dependencies in NPM, Python, Go, and container layers.

## Responsibilities

- Scan NPM dependencies
- Scan Python dependencies
- Scan OS packages in container images
- Validate SBOM contents

## Inputs

- `package.json`
- `requirements.txt`
- `Dockerfile`

## Outputs

- `dependency.json`
- `sbom.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `dependency-scanning/npm` | NPM dependency scanning |
| `dependency-scanning/sbom` | SBOM generation & validation |

## Scan Targets

| Target | Tool | Focus |
|--------|------|-------|
| `package-lock.json` | Trivy | JS/TS CVEs |
| `requirements.txt` | Trivy | Python CVEs |
| `go.sum` | Trivy | Go CVEs |
| Container OS packages | Trivy | OS CVEs |

## Severity Thresholds

| Severity | Action |
|----------|--------|
| Critical | Block build |
| High | Block build |
| Medium | Warn, fix within 1 week |
| Low | Log, fix in next sprint |

## Validation Rules

- [ ] All dependency files scanned
- [ ] No critical CVEs
- [ ] SBOM generated
- [ ] CVEs triaged

## Output Format

```json
{
  "skill": "dependency-scanning",
  "status": "pass | fail",
  "scans": {
    "npm": {"vulnerabilities": 0, "critical": 0},
    "python": {"vulnerabilities": 0, "critical": 0},
    "container_os": {"vulnerabilities": 0, "critical": 0}
  },
  "sbom_generated": true,
  "total_critical": 0
}
```

## Success Criteria

- No critical CVEs
- SBOM generated successfully
