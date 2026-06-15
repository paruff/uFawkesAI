---
name: ci-artifact-production
description: "Produce all required artifacts for OBS, GitOps, and release engineering. Use when building container images, generating SBOMs, signatures, version.json, or provenance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Artifact Production

> **Load trigger:** `"load ci-artifact-production skill"` > **DORA:** Cap 4 (AI Policy)
> **Token cost:** Low

## Purpose

Produce all required artifacts for OBS, GitOps, and release engineering.

## Responsibilities

- Build container image
- Generate SBOM (Syft)
- Generate signatures (Cosign)
- Generate `version.json`
- Generate provenance metadata

## Inputs

- Source code
- `Dockerfile`
- `pipeline-spec.yaml`

## Outputs

- Container image
- `sbom.json`
- `signature.json`
- `version.json`
- `provenance.json`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `ci-artifact-production/version-file` | Generate `version.json` |
| `ci-artifact-production/signing` | Sign all artifacts |

## Artifact Checklist

| Artifact | Tool | Required |
|----------|------|----------|
| Container image | Docker/Buildx | Yes |
| Image digest | Docker | Yes |
| SBOM | Syft | Yes |
| Image signature | Cosign | Yes |
| `version.json` | jq/scripts | Yes |
| Provenance | SLSA generator | Recommended |

## Rules

- [ ] All artifacts produced before quality gates
- [ ] Artifacts tagged with version and digest
- [ ] Signatures validated
- [ ] Provenance recorded

## Success Criteria

- All artifacts produced successfully
- Artifacts tagged correctly
- Supply chain integrity maintained
