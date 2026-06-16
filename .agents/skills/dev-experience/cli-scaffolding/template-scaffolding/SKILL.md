---
name: template-scaffolding
description: "Generate new project components from templates. Use when scaffolding service boilerplate, tests, manifests, or workflows."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Template Scaffolding

> **Load trigger:** `"load template-scaffolding skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Generate new project components from templates.

## Responsibilities

- Scaffold service boilerplate
- Scaffold tests
- Scaffold manifests
- Scaffold workflows

## Inputs

- Template repo
- Component name

## Outputs

- Scaffolded files

## Template Types

| Template | Output |
|----------|--------|
| Service | `src/<name>/index.ts`, `handler.ts`, `config.ts` |
| Test | `tests/<name>/handler.test.ts` |
| Manifest | `manifests/<name>/deployment.yaml`, `service.yaml` |
| Pipeline | `pipeline-spec.yaml` |
| GitOps | `overlays/<env>/kustomization.yaml` |

## Scaffolded Service Structure

```
my-service/
├── src/
│   ├── index.ts          # Entry point
│   ├── handler.ts        # Request handler
│   └── config.ts         # Configuration
├── tests/
│   └── handler.test.ts   # Tests
├── manifests/
│   ├── deployment.yaml   # K8s deployment
│   └── service.yaml      # K8s service
├── Dockerfile            # Container build
└── pipeline-spec.yaml    # CI/CD pipeline
```

## Validation Rules

- [ ] All required files generated
- [ ] Files follow naming conventions
- [ ] TypeScript compiles
- [ ] Tests pass
- [ ] Manifests valid YAML

## Success Criteria

- All scaffolds generated correctly
- Code compiles
- Tests pass
