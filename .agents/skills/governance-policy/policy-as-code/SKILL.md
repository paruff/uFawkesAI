---
name: policy-as-code
description: "Validate manifests, pipelines, and GitOps repos against organizational policies. Use when enforcing policy rules on Kubernetes manifests, pipelines, or directory structure."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Policy-as-Code Validation

> **Load trigger:** `"load policy-as-code skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate manifests, pipelines, and GitOps repos against organizational policies.

## Responsibilities

- Validate Kubernetes manifests against policy rules
- Validate GitOps overlays for compliance
- Validate `pipeline-spec.yaml` against requirements
- Validate security and compliance rules

## Inputs

- Manifests
- `pipeline-spec.yaml`
- Policy definitions (OPA Rego, Kyverno)

## Outputs

- `policy-report.json`
- `violations.txt`

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `policy-as-code/k8s-validation` | Validate Kubernetes manifests |
| `policy-as-code/pipeline-validation` | Validate pipeline configuration |

## Policy Categories

| Category | Description |
|----------|-------------|
| Security | Secret handling, image signing, network policies |
| Compliance | Regulatory requirements, audit logging |
| Cost | Resource limits, quota enforcement |
| Naming | Label conventions, naming standards |

## Validation Rules

- [ ] All manifests checked against OPA/Gatekeeper policies
- [ ] All pipelines checked against pipeline requirements
- [ ] Violations classified by severity
- [ ] Remediation provided for each violation

## Tools

- OPA/Rego for policy evaluation
- Kyverno for Kubernetes policies
- Conftest for manifest testing

## Success Criteria

- No policy violations
- All required policies enforced
- Violations include remediation steps
