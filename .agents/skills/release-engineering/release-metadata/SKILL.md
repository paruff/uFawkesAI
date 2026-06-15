---
name: release-metadata
description: "Generate metadata describing the release, including SBOM, signatures, digests, and provenance. Use when building release.json, validating SBOM, or generating provenance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Release Metadata & Provenance

> **Load trigger:** `"load release-metadata skill"` > **DORA:** Cap 4 (CI/CD Automation)
> **Token cost:** Low

## Purpose

Generate metadata describing the release, including SBOM, signatures, digests, and provenance.

## Responsibilities

- Generate release.json
- Validate SBOM
- Validate Cosign signatures
- Validate provenance (SLSA-style)

## Inputs

- Build artifacts
- `version.json`

## Outputs

- `release.json`
- `provenance.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `release-metadata/sbom-attachment` | Generate and attach SBOM |
| `release-metadata/provenance` | Generate SLSA-style provenance |

## Release Metadata Fields

| Field | Source | Required |
|-------|--------|----------|
| `version` | version.json | Yes |
| `commit_sha` | Git | Yes |
| `build_timestamp` | CI | Yes |
| `image_digest` | Registry | Yes |
| `sbom_digest` | Syft | Yes |
| `signature` | Cosign | Yes |
| `provenance` | provenance.json | Yes |

## Tools

- Syft (SBOM)
- Cosign (signing)
- jq (JSON manipulation)

## Validation Rules

- [ ] release.json complete
- [ ] SBOM valid and attached
- [ ] Cosign signature valid
- [ ] Provenance metadata complete
- [ ] All digests match

## Output Format

```json
{
  "skill": "release-metadata",
  "status": "success",
  "version": "1.3.0",
  "commit_sha": "abc1234",
  "image_digest": "sha256:...",
  "sbom_digest": "sha256:...",
  "signature": "valid",
  "provenance": "valid"
}
```

## Success Criteria

- Complete, valid release metadata
