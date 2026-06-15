---
name: sbom-attachment
description: "Attach SBOM to release metadata. Use when generating SBOM with Syft, validating SBOM schema, or attaching to release.json."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: SBOM Attachment

> **Load trigger:** `"load sbom-attachment skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Attach SBOM to release metadata.

## Responsibilities

- Generate SBOM from container image
- Validate SBOM schema (SPDX/CycloneDX)
- Attach SBOM to release.json

## Inputs

- Container image
- `version.json`

## Outputs

- `sbom.json`

## SBOM Formats

| Format | Standard | Tool |
|--------|----------|------|
| SPDX | Linux Foundation | Syft |
| CycloneDX | OWASP | Syft |

## Generation

```bash
syft <image> -o spdx-json > sbom.json
```

## Validation Rules

- [ ] SBOM generated successfully
- [ ] Valid SPDX or CycloneDX schema
- [ ] All packages listed
- [ ] Licenses identified
- [ ] No critical vulnerabilities unnoted

## Output Format

```json
{
  "skill": "sbom-attachment",
  "status": "success",
  "format": "spdx-json",
  "sbom_digest": "sha256:...",
  "packages": 120,
  "licenses": {
    "MIT": 80,
    "Apache-2.0": 30,
    "BSD-2-Clause": 10
  }
}
```

## Success Criteria

- Valid SBOM attached
- All dependencies cataloged
