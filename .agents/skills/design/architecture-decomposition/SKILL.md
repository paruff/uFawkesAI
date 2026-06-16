---
name: architecture-decomposition
description: "Break the specification into logical architectural components. Use when identifying system components, data flows, external dependencies, and boundaries."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Architecture Decomposition

> **Load trigger:** `"load architecture-decomposition skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Break the specification into logical architectural components.

## Responsibilities

- Identify major system components
- Identify data flows between components
- Identify external dependencies
- Identify boundaries and responsibilities

## Inputs

- `specification.md`

## Outputs

- `architecture.json`

## Decomposition Rules

### Component Identification

- [ ] Each component has a single, clear responsibility
- [ ] Components are loosely coupled
- [ ] Components communicate through defined interfaces
- [ ] No god components (doing everything)

### Data Flow

- [ ] Data flows are unidirectional where possible
- [ ] Synchronous and asynchronous flows identified
- [ ] Data transformation points identified
- [ ] Error flows documented

### External Dependencies

- [ ] External APIs identified
- [ ] Databases identified
- [ ] Message queues identified
- [ ] Third-party services identified

### Boundaries

- [ ] Layer boundaries defined (UI, Service, Data)
- [ ] Trust boundaries identified
- [ ] Integration boundaries identified

## Architecture Patterns

| Pattern       | Use When                                           |
| ------------- | -------------------------------------------------- |
| Monolith      | Simple domain, small team, fast iteration          |
| Microservices | Complex domain, independent scaling, team autonomy |
| Event-Driven  | Async workflows, loose coupling, audit trail       |
| CQRS          | Read/write optimization, complex queries           |
| Serverless    | Variable load, event-driven, minimal ops           |

## Output Format

```json
{
  "components": [
    {
      "name": "Component Name",
      "purpose": "What it does",
      "responsibility": "What it owns",
      "layer": "ui | service | data | infrastructure",
      "dependencies": ["Other Component"],
      "external_dependencies": ["External API"]
    }
  ],
  "data_flows": [
    {
      "from": "Component A",
      "to": "Component B",
      "type": "sync | async",
      "data": "What is transferred"
    }
  ],
  "boundaries": [
    {
      "type": "layer | trust | integration",
      "description": "Boundary description"
    }
  ]
}
```

## Success Criteria

- Architecture is clear and logically decomposed
- Components have single responsibilities
- Data flows documented
