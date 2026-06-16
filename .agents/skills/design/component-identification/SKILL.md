---
name: component-identification
description: "Identify the components required to implement the design. Use when mapping architecture to concrete services, modules, pipelines, and GitOps components."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Component Identification

> **Load trigger:** `"load component-identification skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Identify the components required to implement the design.

## Responsibilities

- Identify services
- Identify modules
- Identify pipelines
- Identify GitOps components

## Inputs

- `architecture.json` (from architecture-decomposition skill)
- `specification.md`

## Outputs

- `component-map.json`

## Identification Rules

### Services

- [ ] Each service has a clear ownership boundary
- [ ] Services communicate through defined APIs
- [ ] Services can be deployed independently
- [ ] Services have distinct data stores (where applicable)

### Modules

- [ ] Each module has a single responsibility
- [ ] Modules are reusable where possible
- [ ] Module interfaces are well-defined
- [ ] No circular module dependencies

### Pipelines

- [ ] Each service has a build pipeline
- [ ] Shared pipelines for common tasks
- [ ] Deployment pipelines per environment

### GitOps Components

- [ ] Base manifests defined
- [ ] Environment overlays defined
- [ ] Secret management approach defined

## Component Types

| Type        | Purpose                | Example                         |
| ----------- | ---------------------- | ------------------------------- |
| API Service | Handle HTTP requests   | User API, Payment API           |
| Worker      | Process async jobs     | Email Worker, Report Worker     |
| CLI Tool    | Command-line interface | Migration Tool, Admin CLI       |
| Library     | Shared code            | Auth Library, Utils Library     |
| Pipeline    | CI/CD automation       | Build Pipeline, Deploy Pipeline |
| Manifest    | K8s resources          | Deployment, Service, ConfigMap  |

## Output Format

```json
{
  "services": [
    {
      "name": "service-name",
      "type": "api | worker | cli | library",
      "language": "typescript | python | go",
      "port": 3000,
      "database": "postgresql",
      "dependencies": ["other-service"]
    }
  ],
  "pipelines": [
    {
      "name": "pipeline-name",
      "type": "build | deploy | security",
      "triggers": ["push", "pr"],
      "stages": ["lint", "test", "build", "deploy"]
    }
  ],
  "gitops": {
    "base": "base/",
    "overlays": ["dev", "staging", "production"],
    "secret_management": "external-secrets"  # pragma: allowlist secret
  }
}
```

## Success Criteria

- Components are complete and well-defined
- Each component has clear ownership
- Dependencies between components mapped
