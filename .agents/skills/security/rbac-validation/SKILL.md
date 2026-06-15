---
name: rbac-validation
description: "Validate RBAC roles, bindings, and service accounts for least privilege and compliance. Use when reviewing Kubernetes RBAC manifests or service account definitions."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: RBAC Validation

> **Load trigger:** `"load rbac-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate RBAC roles, bindings, and service accounts for least privilege and compliance.

## Responsibilities

- Validate RBAC roles and bindings
- Detect overprivileged roles (wildcard verbs, resources, or API groups)
- Validate service account scopes
- Validate token permissions and automounting
- Detect cluster-admin bindings where not required

## Inputs

- RBAC manifests (Role, ClusterRole, RoleBinding, ClusterRoleBinding)
- Service account definitions

## Validation Rules

### Roles and ClusterRoles

- [ ] No wildcard (`*`) in `verbs` unless explicitly justified
- [ ] No wildcard (`*`) in `resources` unless explicitly justified
- [ ] No wildcard (`*`) in `apiGroups` unless explicitly justified
- [ ] Scope to minimum required resources (e.g., `pods` not `*`)
- [ ] Namespace-scoped Roles preferred over ClusterRoles

### Bindings

- [ ] RoleBindings reference specific subjects, not `system:anonymous`
- [ ] ClusterRoleBindings limited to system components
- [ ] No cluster-admin binding for application service accounts
- [ ] Service accounts not bound to elevated roles

### Service Accounts

- [ ] `automountServiceAccountToken` set to `false` unless token is required
- [ ] Service accounts are namespace-scoped
- [ ] No default service account usage for workloads

## Tools

- `kubectl auth can-i --list --as=system:serviceaccount:<ns>:<sa>`
- OPA/Gatekeeper policies
- Kyverno validation policies

## Output Format

```json
{
  "skill": "rbac-validation",
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

- No RBAC violations or overprivileged roles
- All service accounts follow least privilege
- No unnecessary automounting of tokens
