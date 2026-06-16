---
name: build
description: "Turn plan into code, manifests, pipelines, and GitOps overlays. Use when implementing features, generating manifests, or creating pipeline configurations."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Build

> **Load trigger:** `"load build skill"` 
> **DORA:** Cap 4 (Continuous Delivery)
> **Token cost:** Medium

## Purpose

Turn plan into code, manifests, pipelines, and GitOps overlays.

## Responsibilities

- Generate source code from specifications
- Create Kubernetes manifests
- Generate CI/CD pipeline configurations
- Create GitOps overlays for environments
- Enforce governance policies
- Apply project templates

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `build/code-generation` | Generate source code that satisfies specification |
| `build/manifest-generation` | Create Kubernetes manifests |
| `build/pipeline-generation` | Generate CI/CD pipeline configurations |
| `build/gitops-overlay-generation` | Create environment-specific overlays |
| `build/governance-enforcement` | Enforce organizational policies |
| `build/template-application` | Apply project templates and conventions |
| `build/refactoring` | Improve existing code without changing behavior |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `plan` | Consumes task list and estimates |
| `design` | Consumes architecture and interfaces |
| `test` | Produces code that passes failing tests |

## Inputs

- `tasks.json` (from planner)
- `design.md` (from design)
- `specification.md` (from spec)
- Existing codebase conventions

## Outputs

- Source code files
- Kubernetes manifests
- Pipeline configurations
- GitOps overlays

## Validation Rules

### Code Quality

- [ ] Code compiles without errors
- [ ] Code follows project style guide
- [ ] No `any` types in TypeScript
- [ ] No commented-out code
- [ ] No TODO comments without issue numbers

### Security

- [ ] No hardcoded secrets
- [ ] Input validation at boundaries
- [ ] Output encoding applied
- [ ] Sensitive data not logged

### Testability

- [ ] Functions are pure where possible
- [ ] Dependencies are injectable
- [ ] I/O abstracted behind interfaces
- [ ] Complex logic broken into testable units

## Output Format

```json
{
  "skill": "build",
  "status": "pass | fail",
  "artifacts": {
    "source_files": ["src/feature.ts"],
    "manifests": ["k8s/deployment.yaml"],
    "pipelines": [".github/workflows/ci.yml"],
    "overlays": ["overlays/dev/kustomization.yaml"]
  },
  "validation": {
    "compiles": true,
    "lint_passes": true,
    "security_scan": "pass"
  }
}
```

## Success Criteria

- All artifacts generated successfully
- Code compiles and passes linting
- Security scan passes
- Follows project conventions
