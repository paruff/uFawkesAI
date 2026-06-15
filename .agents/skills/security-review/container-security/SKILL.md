---
name: container-security
description: "Validate container images and runtime security posture. Use when reviewing container manifests, Dockerfiles, or image metadata."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Container Security Validation

> **Load trigger:** `"load container-security skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate container images and runtime security posture.

## Responsibilities

- Validate base image security and provenance
- Validate image signatures and attestations
- Validate container capabilities and privilege escalation
- Validate `securityContext` settings
- Detect privileged containers and host path mounts

## Inputs

- Container manifests (Pod, Deployment, StatefulSet, etc.)
- Image metadata (tags, digests, registry)
- Dockerfiles or build definitions

## Validation Rules

### Image Security

- [ ] Images pinned to digest (`@sha256:...`) not mutable tags
- [ ] Base images from trusted registries
- [ ] No `latest` tag used in production
- [ ] Image signatures verified (Cosign/Notary)
- [ ] Vulnerability scan results available and clean

### Runtime Security

- [ ] `runAsNonRoot: true`
- [ ] `readOnlyRootFilesystem: true` where possible
- [ ] `allowPrivilegeEscalation: false`
- [ ] No `privileged: true` unless explicitly justified
- [ ] Capabilities dropped (drop `ALL`, add only required)
- [ ] No `hostNetwork`, `hostPID`, or `hostIPC` unless required

### Resource Limits

- [ ] CPU limits defined
- [ ] Memory limits defined
- [ ] No `requests` without `limits` or vice versa

### Mounts

- [ ] No `hostPath` mounts unless absolutely required
- [ ] `hostPath` mounts restricted to read-only where used
- [ ] Persistent volume claims use appropriate storage classes

## Tools

- `kubectl get pods -o yaml`
- OPA/Gatekeeper constraint templates
- Kyverno container security policies
- Trivy / Grype for image scanning

## Output Format

```json
{
  "skill": "container-security",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<pod or deployment name>",
      "issue": "Description of the issue",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No insecure container configurations
- All images signed and scanned
- Least privilege runtime security applied
