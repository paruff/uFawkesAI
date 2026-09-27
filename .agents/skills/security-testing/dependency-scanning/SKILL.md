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

| Skill                      | Purpose                      |
| -------------------------- | ---------------------------- |
| `dependency-scanning/npm`  | NPM dependency scanning      |
| `dependency-scanning/sbom` | SBOM generation & validation |

## Scan Targets

| Target                | Tool  | Focus       |
| --------------------- | ----- | ----------- |
| `package-lock.json`   | Trivy | JS/TS CVEs  |
| `requirements.txt`    | Trivy | Python CVEs |
| `go.sum`              | Trivy | Go CVEs     |
| Container OS packages | Trivy | OS CVEs     |

## Severity Thresholds

**Partial enforcement.** `.github/workflows/dependency-review.yml` runs
`actions/dependency-review-action@v5`, which is a real merge gate — but it
gates on *newly introduced* vulnerable or unlicensed dependencies appearing in
the diff, not on a repo-wide CVE count. A pre-existing Critical in an unchanged
dependency will not fail it, so the "no critical CVEs" bar below is a reporting
target that this workflow does not enforce on its own.

| Severity | Response                                       |
| -------- | ---------------------------------------------- |
| Critical | Mark blocking in `review-report.md`; update or justify before merge |
| High     | Mark blocking in `review-report.md`; fix in 7 days |
| Medium   | Warn, fix within 30 days                       |
| Low      | Log, fix in next sprint                        |

**Enforcement: partial.** `dependency-review.yml` gates newly introduced
vulnerable or unlicensed dependencies only; a pre-existing Critical does not
fail it. These criteria are reported, not enforced.

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
    "npm": { "vulnerabilities": 0, "critical": 0 },
    "python": { "vulnerabilities": 0, "critical": 0 },
    "container_os": { "vulnerabilities": 0, "critical": 0 }
  },
  "sbom_generated": true,
  "total_critical": 0
}
```

## Success Criteria

- No critical CVEs
- SBOM generated successfully
