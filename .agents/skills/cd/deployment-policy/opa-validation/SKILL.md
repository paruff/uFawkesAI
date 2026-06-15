---
name: opa-validation
description: "Validate manifests against policy-as-code rules. Use when running OPA/Kyverno checks, validating violations, or producing compliance reports."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: OPA/Kyverno Policy Validation

> **Load trigger:** `"load opa-validation skill"` > **DORA:** Cap 1 (AI Policy)
> **Token cost:** Low

## Purpose

Validate manifests against policy-as-code rules.

## Responsibilities

- Run OPA/Kyverno policy checks
- Validate violations
- Produce compliance report

## Inputs

- Manifests
- Policy definitions

## Outputs

- `opa-validation.json`

## Validation Methods

### OPA/Rego

```rego
package kubernetes.admission

deny[msg] {
    input.request.kind.kind == "Deployment"
    container := input.request.object.spec.template.spec.containers[_]
    not container.resources.limits.memory
    msg := "Memory limit required"
}
```

### Kyverno

```yaml
apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: require-resource-limits
spec:
  validationFailureAction: Enforce
  rules:
  - name: check-container-limits
    match:
      resources:
        kinds:
        - Deployment
    validate:
      message: "Memory limit required"
      pattern:
        spec:
          template:
            spec:
              containers:
              - resources:
                  limits:
                    memory: "?*"
```

## Common Policies

| Policy | Severity | Effect |
|--------|----------|--------|
| Require resource limits | Critical | Block |
| Require security context | Critical | Block |
| Require labels | High | Block |
| Require image digest | High | Warn |
| Ban privileged containers | Critical | Block |

## Output Format

```json
{
  "skill": "opa-validation",
  "status": "pass | fail",
  "policies_evaluated": 12,
  "violations": [
    {
      "policy": "require-resource-limits",
      "resource": "deployment/my-app",
      "message": "Memory limit required",
      "severity": "critical"
    }
  ]
}
```

## Success Criteria

- No policy violations
- All required policies enforced
- Violations include remediation
