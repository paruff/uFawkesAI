---
name: rbac-governance
description: "Ensure access controls are correct, minimal, and compliant. Use when validating Kubernetes RBAC, GitOps permissions, CI/CD token scopes, and secret access."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: RBAC & Access Governance

> **Load trigger:** `"load rbac-governance skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Ensure access controls are correct, minimal, and compliant.

## Responsibilities

- Validate Kubernetes RBAC roles and bindings
- Validate GitOps repo permissions
- Validate CI/CD token scopes
- Validate secret access policies

## Inputs

- RBAC manifests
- GitOps repo ACLs
- CI/CD token metadata

## Outputs

- `rbac-report.json`
- `overprivileged-roles.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `rbac-governance/rbac-drift` | Detect unauthorized RBAC changes |
| `rbac-governance/token-scope` | Validate token permissions |

## Validation Rules

### Kubernetes RBAC

- [ ] No wildcard verbs (`*`) unless justified
- [ ] No wildcard resources (`*`) unless justified
- [ ] ClusterRoleBindings limited to system components
- [ ] No cluster-admin for application service accounts
- [ ] Service accounts namespace-scoped

### GitOps Permissions

- [ ] Repo access restricted to authorized teams
- [ ] Branch protection enabled on main
- [ ] Force push disabled
- [ ] Signed commits required

### CI/CD Tokens

- [ ] GitHub token scopes minimal (no `repo` if not needed)
- [ ] Registry tokens scoped to specific repos
- [ ] Cluster tokens limited to required namespaces

### Secret Access

- [ ] Secret access restricted via RBAC
- [ ] No unnecessary secret access
- [ ] Secret access audited

## Tools

- `kubectl auth can-i --list`
- Git CLI for repo permissions
- Token analyzer

## Success Criteria

- No overprivileged roles or tokens
- Least privilege enforced
- Access controls auditable
