---
name: sbom-generation-validation
description: "Generate and validate Software Bill of Materials for Fawkes artifacts. Use when generating SBOM with Syft, validating SBOM schema, or checking dependency completeness."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: SBOM Generation & Validation

> **Load trigger:** `"load sbom-generation-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Generate and validate Software Bill of Materials for Fawkes artifacts.

## Responsibilities

- Generate SBOM using Syft
- Validate SBOM schema
- Validate dependency completeness

## Inputs

- Container image
- Source code

## Outputs

- `sbom.json`

## SBOM Formats

| Format | Standard | Tool |
|--------|----------|------|
| SPDX | Linux Foundation | Syft |
| CycloneDX | OWASP | Syft |

## Generation Commands

```bash
# Container image SBOM
syft <image> -o spdx-json > sbom.json

# Source code SBOM
syft dir:. -o spdx-json > sbom.json
```

## Validation Rules

- [ ] SBOM generated successfully
- [ ] Valid SPDX or CycloneDX schema
- [ ] All packages listed
- [ ] Licenses identified
- [ ] No unknown licenses > 5%

## Output Format

```json
{
  "skill": "sbom-generation-validation",
  "status": "pass | fail",
  "format": "spdx-json",
  "packages": 120,
  "licenses": {
    "MIT": 80,
    "Apache-2.0": 30,
    "BSD-2-Clause": 10
  },
  "unknown_licenses": 0,
  "schema_valid": true
}
```

## Success Criteria

- Valid SBOM with complete dependency graph
- All packages cataloged
