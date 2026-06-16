---
name: security-rbac
description: "Validate RBAC, service accounts, and security posture. Use when reviewing roles, bindings, token permissions, and container security settings."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Security & RBAC Validation

> **Load trigger:** `"load security-rbac skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate RBAC, service accounts, and security posture.

## Responsibilities

- Validate RBAC roles and bindings
- Validate service account scopes
- Validate token permissions
- Validate container security settings

## Inputs

- Kubernetes manifests
- RBAC definitions

## Outputs

- `security-rbac.json`

## Validation Rules

### RBAC

- [ ] No wildcard verbs unless justified
- [ ] No wildcard resources unless justified
- [ ] No wildcard apiGroups unless justified
- [ ] ClusterRoleBindings limited to system components
- [ ] No cluster-admin for application service accounts

### Service Accounts

- [ ] `automountServiceAccountToken: false` unless needed
- [ ] Service accounts namespace-scoped
- [ ] No default service account usage

### Token Permissions

- [ ] Tokens scoped to minimum required permissions
- [ ] Token expiration configured
- [ ] No long-lived tokens without justification

### Container Security

- [ ] `runAsNonRoot: true`
- [ ] `readOnlyRootFilesystem: true`
- [ ] `allowPrivilegeEscalation: false`
- [ ] Capabilities dropped
- [ ] No `privileged: true`

### Network Security

- [ ] No `hostNetwork`, `hostPID`, `hostIPC` unless required
- [ ] Network policies restrict traffic

## Tools

- `kubectl auth can-i --list`
- OPA/Gatekeeper for RBAC validation
- Kyverno for security policies

## Output Format

```json
{
  "skill": "security-rbac",
  "status": "pass | fail",
  "checks": [
    {
      "area": "RBAC",
      "status": "pass | fail",
      "details": "Description"
    },
    {
      "area": "Service Accounts",
      "status": "pass | fail",
      "details": "Description"
    }
  ],
  "violations": []
}
```

## Success Criteria

- No security or RBAC violations
- Least privilege enforced
- No unnecessary token mounting
