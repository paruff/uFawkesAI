---
name: k8s-security
description: "Validate Kubernetes manifests against security policies. Use when reviewing network policies, pod security standards, resource limits, and container securityContext."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kubernetes Security Policy Validation

> **Load trigger:** `"load k8s-security skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate Kubernetes manifests against security policies and best practices.

## Responsibilities

- Validate network policies (ingress/egress rules)
- Validate pod security standards (restricted, baseline, privileged)
- Validate resource limits and requests
- Validate secret usage in manifests
- Validate container `securityContext` settings

## Inputs

- Kubernetes manifests (Pods, Deployments, Services, NetworkPolicies, etc.)
- Kustomize overlays
- Helm charts

## Validation Rules

### Network Security

- [ ] NetworkPolicy exists for each namespace
- [ ] Default ingress denied, explicit allowlist
- [ ] Default egress denied or restricted
- [ ] Cross-namespace traffic explicitly allowed
- [ ] No `0.0.0.0/0` ingress rules without justification

### Pod Security Standards

- [ ] Pod Security Admission labels set on namespaces
- [ ] Pods comply with `restricted` profile where possible
- [ ] No `privileged` containers unless explicitly justified
- [ ] No `hostPath` volumes unless absolutely required

### Resource Management

- [ ] CPU requests and limits defined for all containers
- [ ] Memory requests and limits defined for all containers
- [ ] No `LimitRange` or `ResourceQuota` violations
- [ ] HPA configured for stateless workloads

### Secrets and Config

- [ ] Secrets referenced via `secretKeyRef`, not inline values
- [ ] ConfigMaps for non-sensitive configuration only
- [ ] No secrets in annotations or labels

### Admission Control

- [ ] Pod Security Admission enforced (not just audit)
- [ ] OPA/Gatekeeper constraints applied
- [ ] Kyverno policies validated

## Tools

- `kubectl` for manifest inspection
- OPA/Gatekeeper for policy validation
- Kyverno for policy validation
- `kube-score` for best practice scoring
- `polaris` for configuration auditing

## Output Format

```json
{
  "skill": "k8s-security",
  "status": "pass | fail",
  "findings": [
    {
      "severity": "critical | high | medium | low",
      "resource": "<resource name>",
      "issue": "Description of the issue",
      "fix": "Recommended remediation"
    }
  ]
}
```

## Success Criteria

- No Kubernetes security policy violations
- Network policies enforce least privilege
- Pod security standards applied
- Resource limits defined for all containers
