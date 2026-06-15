---
name: ci-signing
description: "Sign all artifacts for supply-chain security. Use when signing container images, SBOMs, provenance, or validating signatures."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: CI Artifact Signing

> **Load trigger:** `"load ci-signing skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Sign all artifacts for supply-chain security.

## Responsibilities

- Sign container image
- Sign SBOM
- Sign provenance
- Validate signatures

## Inputs

- Artifacts (image, SBOM, provenance)
- Signing key (Cosign)

## Outputs

- `signature.json`

## Signing Commands

### Image Signing

```bash
cosign sign --key cosign.key \
  ghcr.io/myorg/myapp:v1.2.3@sha256:abc123
```

### SBOM Signing

```bash
cosign sign-blob --key cosign.key \
  --output-signature sbom.json.sig \
  sbom.json
```

### Signature Verification

```bash
cosign verify --key cosign.pub \
  ghcr.io/myorg/myapp:v1.2.3@sha256:abc123
```

## Signing Rules

- [ ] All artifacts signed with project key
- [ ] Signatures attached to artifacts
- [ ] Signatures verifiable by consumers
- [ ] Key not logged or exposed

## Output Format

```json
{
  "skill": "ci-signing",
  "status": "success",
  "signed_artifacts": [
    {"type": "image", "digest": "sha256:abc123", "signature": "sha256:def456"},
    {"type": "sbom", "file": "sbom.json", "signature": "sbom.json.sig"},
    {"type": "provenance", "file": "provenance.json", "signature": "provenance.json.sig"}
  ]
}
```

## Success Criteria

- All artifacts signed
- Signatures verifiable
- Key secured
