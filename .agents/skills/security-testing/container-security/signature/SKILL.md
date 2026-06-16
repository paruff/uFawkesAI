---
name: image-signature-verification
description: "Ensure all images are signed and verifiable before deployment. Use when validating Cosign signatures, keyless signing, or provenance."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Image Signature Verification

> **Load trigger:** `"load image-signature-verification skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure all images are signed and verifiable before deployment.

## Responsibilities

- Validate Cosign signatures
- Validate keyless signing
- Validate provenance

## Inputs

- Container image

## Outputs

- `signature.json`

## Signing Methods

| Method       | Tool          | Use When       |
| ------------ | ------------- | -------------- |
| Key-based    | Cosign        | CI/CD pipeline |
| Keyless      | Cosign + OIDC | GitHub Actions |
| Hardware key | Cosign + HSM  | High security  |

## Verification Commands

```bash
# Key-based
cosign verify --key cosign.pub <image>

# Keyless (GitHub Actions)
cosign verify --certificate-identity=... --certificate-oidc-issuer=... <image>
```

## Validation Rules

- [ ] Signature present
- [ ] Signature valid
- [ ] Signing identity matches expected
- [ ] Provenance attached
- [ ] Provenance valid

## Output Format

```json
{
  "skill": "image-signature-verification",
  "status": "pass | fail",
  "image": "my-app:v1.3.0",
  "signature": {
    "present": true,
    "valid": true,
    "method": "keyless",
    "identity": "https://github.com/paruff/uFawkesAI/.github/workflows/ci.yml",
    "issuer": "https://token.actions.githubusercontent.com"
  },
  "provenance": {
    "present": true,
    "valid": true
  }
}
```

## Success Criteria

- Valid signature and provenance
- Signing identity verified
