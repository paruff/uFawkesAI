---
name: k8s-design-validation
description: "Validate Kubernetes-related design decisions. Use when checking resource requirements, deployment patterns, network design, and secret usage in the design."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Kubernetes Design Validation

> **Load trigger:** `"load k8s-design-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate Kubernetes-related design decisions.

## Responsibilities

- Validate resource requirements in design
- Validate deployment patterns
- Validate network design
- Validate secret usage approach

## Inputs

- `design.md`
- `architecture.json`

## Outputs

- `k8s-design.json`

## Validation Rules

### Resource Design

- [ ] CPU requests/limits specified per component
- [ ] Memory requests/limits specified per component
- [ ] Storage requirements specified (if applicable)
- [ ] Horizontal scaling approach defined

### Deployment Patterns

- [ ] Deployment strategy chosen (RollingUpdate, Recreate)
- [ ] Replica count specified
- [ ] Pod disruption budgets defined (if needed)
- [ ] Init containers defined (if needed)

### Network Design

- [ ] Service types defined (ClusterIP, NodePort, LoadBalancer)
- [ ] Ingress rules defined
- [ ] Network policies defined
- [ ] DNS strategy defined

### Secret Management

- [ ] Secret storage approach chosen (native, Vault, ExternalSecrets)
- [ ] Secret rotation strategy defined
- [ ] Secret access pattern defined
- [ ] Encryption at rest approach defined

### Storage Design

- [ ] Persistent volume claims defined (if needed)
- [ ] Storage classes specified
- [ ] Backup strategy defined (if needed)

## Design Patterns

| Pattern     | Use When                                |
| ----------- | --------------------------------------- |
| Deployment  | Stateless workloads                     |
| StatefulSet | Stateful workloads (databases, queues)  |
| DaemonSet   | Node-level agents (logging, monitoring) |
| Job/CronJob | Batch or scheduled workloads            |

## Output Format

```json
{
  "skill": "k8s-design-validation",
  "status": "pass | fail",
  "checks": [
    {
      "area": "Resource design",
      "status": "pass | fail | na",
      "details": "Description"
    }
  ],
  "recommendations": ["Consider adding PodDisruptionBudget for production"],
  "violations": []
}
```

## Success Criteria

- Kubernetes design is valid and compliant
- Resource requirements defined
- Deployment patterns appropriate
