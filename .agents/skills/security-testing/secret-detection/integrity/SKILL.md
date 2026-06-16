---
name: artifact-integrity-validation
description: "Ensure all build artifacts are tamper-proof and verifiable. Use when validating checksums, signatures, or provenance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Artifact Integrity Validation

> **Load trigger:** `"load artifact-integrity-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all build artifacts are tamper-proof and verifiable.

## Responsibilities

- Validate checksums
- Validate signatures
- Validate provenance

## Inputs

- Build artifacts

## Outputs

- `integrity.json`

## Artifact Types

| Artifact        | Checksum | Signature | Provenance |
| --------------- | -------- | --------- | ---------- |
| Container image | digest   | Cosign    | SLSA       |
| SBOM            | sha256   | Cosign    | -          |
| Manifests       | sha256   | -         | -          |
| Binaries        | sha256   | Cosign    | SLSA       |

## Validation Commands

```bash
# Checksum
sha256sum artifact > artifact.sha256
sha256sum -c artifact.sha256

# Signature
cosign verify-blob --signature artifact.sig --cert artifact.cert artifact

# Provenance
cosign verify-attestation --type slsaprovenance --key cosign.pub artifact
```

## Validation Rules

- [ ] All artifacts have checksums
- [ ] All checksums valid
- [ ] All signatures valid
- [ ] Provenance attached where required
- [ ] No tampering detected

## Output Format

```json
{
  "skill": "artifact-integrity-validation",
  "status": "pass | fail",
  "artifacts": [
    {
      "name": "my-app:v1.3.0",
      "checksum": "valid",
      "signature": "valid",
      "provenance": "valid"
    },
    {
      "name": "sbom.json",
      "checksum": "valid",
      "signature": "valid",
      "provenance": "n/a"
    }
  ],
  "total_artifacts": 5,
  "verified": 5,
  "failed": 0
}
```

## Success Criteria

- All artifacts integrity-verified
- No tampering detected
