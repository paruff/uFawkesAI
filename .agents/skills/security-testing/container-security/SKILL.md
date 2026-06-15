---
name: container-security
description: "Ensure container images built by PIPE are secure, minimal, and free of vulnerabilities. Use when scanning container images, validating base images, or checking OS package vulnerabilities."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Container Image Security

> **Load trigger:** `"load container-security skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure container images built by PIPE are secure, minimal, and free of vulnerabilities.

## Responsibilities

- Scan container images
- Validate base image security
- Validate OS package vulnerabilities
- Validate image metadata

## Inputs

- Built image

## Outputs

- `container.json`
- `container-vulns.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `container-security/vuln-scan` | Container vulnerability scanning |
| `container-security/signature` | Image signature verification |

## Image Requirements

| Requirement | Rule |
|-------------|------|
| Base image | Distroless or minimal |
| Latest tag | Not used |
| Root user | Not running as root |
| Ports | Only required ports exposed |
| Secrets | No secrets in image layers |

## Validation Rules

- [ ] No critical vulnerabilities
- [ ] Base image is distroless/minimal
- [ ] Not running as root
- [ ] No secrets in layers
- [ ] Valid signature

## Output Format

```json
{
  "skill": "container-security",
  "status": "pass | fail",
  "image": "my-app:v1.3.0",
  "base_image": "distroless",
  "running_as_root": false,
  "vulnerabilities": {
    "critical": 0,
    "high": 0,
    "medium": 2,
    "low": 5
  },
  "signature_valid": true,
  "issues": []
}
```

## Success Criteria

- No critical vulnerabilities
- Valid signature
- Secure base image
