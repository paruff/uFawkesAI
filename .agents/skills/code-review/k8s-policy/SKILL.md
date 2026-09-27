---
name: k8s-policy
description: "Validate Kubernetes manifests for compliance. Use when reviewing resource limits, securityContext, network policies, and secret usage."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kubernetes Policy Validation

> **Load trigger:** `"load k8s-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate Kubernetes manifests for compliance.

## Responsibilities

- Validate resource limits
- Validate securityContext
- Validate network policies
- Validate secret usage

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

### Secret Usage

- [ ] Secrets referenced via `secretKeyRef`
- [ ] No plaintext secrets in manifests
- [ ] No secrets in annotations or labels

### Labels and Annotations

- [ ] Required labels present (`app`, `version`, `team`, `env`)
- [ ] Owner annotations present
- [ ] Documentation annotations present

## Tools

- OPA/Gatekeeper for policy validation
- Kyverno for manifest validation
- `kube-score` for best practices
- `polaris` for configuration auditing

## Output Format

```json
{
  "skill": "k8s-policy",
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
- Resource limits defined for all containers
- Security best practices applied
