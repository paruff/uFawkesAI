---
name: design
description: "Convert specification into technical design. Use when creating architecture, defining components, interfaces, and data flows."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Design

> **Load trigger:** `"load design skill"` 
> **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Convert specification into technical design.

## Responsibilities

- Decompose architecture
- Identify components
- Define interfaces
- Model data flows
- Validate K8s design
- Document tradeoffs

## Sub-Skills

| Skill | Purpose |
|-------|---------|
| `design/architecture-decomposition` | Break down system architecture |
| `design/component-identification` | Identify required components |
| `design/interface-definition` | Define component interfaces |
| `design/k8s-design-validation` | Validate Kubernetes design |

## Dependencies

| Skill | Relationship |
|-------|-------------|
| `spec` | Consumes specification and requirements |

## Inputs

- `specification.md` (from spec)
- Existing architecture (if updating)
- Policy documents

## Outputs

- `design.md`
- `architecture-decisions.md`
- `component-interfaces.md`

## Design Rules

### Architecture

- [ ] Follows established patterns
- [ ] Aligns with existing architecture
- [ ] Scalability considered
- [ ] Security embedded (not bolted on)

### Components

- [ ] Single responsibility
- [ ] Clear boundaries
- [ ] Loose coupling
- [ ] High cohesion

### Interfaces

- [ ] Contracts defined
- [ ] Versioning considered
- [ ] Error handling specified
- [ ] Input validation defined

### Tradeoffs

- [ ] Alternatives documented
- [ ] Rationale provided
- [ ] Risks identified
- [ ] Mitigation strategies defined

## Output Format

```json
{
  "skill": "design",
  "status": "pass | fail",
  "architecture": {
    "overview": "description",
    "components": ["auth-service", "user-api", "database"],
    "patterns": ["microservices", "event-driven"]
  },
  "interfaces": [
    {
      "component": "auth-service",
      "inputs": ["email", "password"],
      "outputs": ["token", "user-id"]
    }
  ],
  "tradeoffs": [
    {
      "decision": "Use PostgreSQL",
      "alternatives": ["MySQL", "MongoDB"],
      "rationale": "ACID compliance required"
    }
  ]
}
```

## Success Criteria

- Architecture is clear and documented
- Components are well-defined
- Interfaces are explicit
- Tradeoffs are justified
