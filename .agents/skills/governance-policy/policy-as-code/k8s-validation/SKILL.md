---
name: k8s-policy-validation
description: "Validate Kubernetes manifests against policy rules. Use when checking resource limits, securityContext, network policies, and image signatures."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kubernetes Policy Validation

> **Load trigger:** `"load k8s-policy-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate Kubernetes manifests against policy rules.

## Responsibilities

- Validate resource limits and requests
- Validate securityContext settings
- Validate network policies
- Validate image signatures

## Inputs

- Kubernetes manifests

## Outputs

- `k8s-policy.json`

## Validation Rules

### Resource Limits

- [ ] CPU requests and limits defined for all containers
- [ ] Memory requests and limits defined for all containers
- [ ] Limits >= requests
- [ ] No containers without resource definitions

### SecurityContext

- [ ] `runAsNonRoot: true`
- [ ] `readOnlyRootFilesystem: true` (where possible)
- [ ] `allowPrivilegeEscalation: false`
- [ ] Capabilities dropped (`drop: ["ALL"]`)
- [ ] No `privileged: true`

### Network Policies

- [ ] NetworkPolicy exists for each namespace
- [ ] Default ingress denied
- [ ] Cross-namespace traffic explicitly allowed

### Image Policies

- [ ] Images from approved registries
- [ ] Image signatures verified (Cosign)
- [ ] No `:latest` tag in production
- [ ] Images pinned to digests

## Tools

- OPA/Gatekeeper constraint templates
- Kyverno validation policies
- `kube-score` for best practices
- `polaris` for configuration auditing

## Output Format

```json
{
  "skill": "k8s-policy-validation",
  "status": "pass | fail",
  "resources_checked": 5,
  "violations": [
    {
      "severity": "high",
      "resource": "deployment/my-app",
      "rule": "security-context",
      "issue": "allowPrivilegeEscalation not set to false",
      "fix": "Add securityContext.allowPrivilegeEscalation: false"
    }
  ]
}
```

## Success Criteria

- No Kubernetes policy violations
- All resources validated
- Violations include remediation
