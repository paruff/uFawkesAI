---
name: spec-k8s-policy
description: "Validate Kubernetes-related requirements in the specification. Use when checking resource, securityContext, network policy, and secret usage requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kubernetes Policy Validation (Spec)

> **Load trigger:** `"load spec-k8s-policy skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate Kubernetes-related requirements in the specification.

## Responsibilities

- Validate resource requirements are specified
- Validate securityContext requirements are specified
- Validate network policy requirements are specified
- Validate secret usage requirements are specified

## Inputs

- `specification.md`

## Outputs

- `k8s-policy.json`

## Validation Rules

### Resource Requirements

- [ ] CPU requirements specified
- [ ] Memory requirements specified
- [ ] Storage requirements specified (if applicable)
- [ ] Replica count or scaling requirements specified

### Security Requirements

- [ ] Run-as-user requirements specified
- [ ] Filesystem permissions specified
- [ ] Capability requirements specified
- [ ] Privileged mode requirements specified (should be false)

### Network Requirements

- [ ] Ingress requirements specified
- [ ] Egress requirements specified
- [ ] Cross-namespace communication specified (if applicable)
- [ ] Service mesh requirements specified (if applicable)

### Secret Requirements

- [ ] Secret types specified (Opaque, TLS, etc.)
- [ ] Secret storage approach specified (native, external)
- [ ] Secret rotation requirements specified
- [ ] Secret access control specified

### Deployment Requirements

- [ ] Deployment strategy specified (RollingUpdate, Recreate)
- [ ] MinReadySeconds specified (if applicable)
- [ ] Progress deadline specified (if applicable)

## Output Format

```json
{
  "skill": "spec-k8s-policy",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Resource requirements",
      "status": "pass | fail | na",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- Kubernetes requirements are valid and compliant
- All K8s-related requirements specified
