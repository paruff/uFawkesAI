---
name: manifest-generation
description: "Generate Kubernetes manifests that follow platform rules. Use when creating deployments, services, configmaps, and other K8s resources."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Manifest Generation

> **Load trigger:** `"load manifest-generation skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate Kubernetes manifests that follow platform rules.

## Responsibilities

- Generate Deployments, Services, ConfigMaps, Secrets
- Apply resource limits and requests
- Apply securityContext settings
- Apply network policies
- Apply proper labels and annotations

## Inputs

- `tasks.json`
- `design.md`
- Existing manifest patterns

## Outputs

- `manifests/` directory with K8s resources

## Generation Rules

### Required Fields

- [ ] `apiVersion` and `kind` correct for resource type
- [ ] `metadata.name` follows naming conventions
- [ ] `metadata.namespace` specified
- [ ] `metadata.labels` include `app`, `version`, `team`, `env`
- [ ] `metadata.annotations` include ownership and docs links

### Security

- [ ] `securityContext.runAsNonRoot: true`
- [ ] `securityContext.readOnlyRootFilesystem: true`
- [ ] `securityContext.allowPrivilegeEscalation: false`
- [ ] `securityContext.capabilities.drop: ["ALL"]`
- [ ] No `privileged: true` unless explicitly justified

### Resources

- [ ] `resources.requests.cpu` defined
- [ ] `resources.requests.memory` defined
- [ ] `resources.limits.cpu` defined
- [ ] `resources.limits.memory` defined

### Networking

- [ ] `Service` uses correct port mapping
- [ ] `NetworkPolicy` restricts ingress/egress
- [ ] No `hostNetwork`, `hostPID`, or `hostIPC`

### Health Checks

- [ ] `livenessProbe` configured
- [ ] `readinessProbe` configured
- [ ] `startupProbe` configured for slow-starting apps

## Tools

- `kubectl` for validation
- OPA/Gatekeeper for policy checks
- Kyverno for manifest validation
- `kube-score` for best practices

## Success Criteria

- Manifests pass policy validation
- Security best practices applied
- Health checks configured
