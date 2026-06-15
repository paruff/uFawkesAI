---
name: requirements-extraction
description: "Extract clear, structured requirements from a user request. Use when decomposing intent into functional, non-functional, and constraint requirements."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Requirements Extraction

> **Load trigger:** `"load requirements-extraction skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Extract clear, structured requirements from a user request.

## Responsibilities

- Identify functional requirements
- Identify non-functional requirements
- Identify constraints and assumptions
- Identify dependencies
- Identify out-of-scope items

## Inputs

- User request
- Project context (`AGENTS.md`, `docs/`)

## Outputs

- `requirements.json`
- `constraints.json`
- `nonfunctional.json`

## Extraction Rules

### Functional Requirements

- [ ] Each requirement is atomic (one thing per requirement)
- [ ] Each requirement is testable or verifiable
- [ ] No ambiguous language ("should", "might", "fast")
- [ ] Requirements are prioritized (must-have, should-have, nice-to-have)

### Non-Functional Requirements

- [ ] Performance targets specified (latency, throughput)
- [ ] Scalability targets specified (users, data volume)
- [ ] Security requirements explicit (auth, encryption, compliance)
- [ ] Availability targets specified (uptime, recovery)

### Constraints

- [ ] Technical constraints documented (language, framework, version)
- [ ] Business constraints documented (budget, timeline, team)
- [ ] Regulatory constraints documented (GDPR, HIPAA, etc.)

### Assumptions

- [ ] Each assumption stated explicitly
- [ ] Assumptions are testable or verifiable
- [ ] Risk of wrong assumption documented

### Dependencies

- [ ] External systems identified
- [ ] Team dependencies identified
- [ ] Approval dependencies identified

### Out of Scope

- [ ] Explicitly excluded features listed
- [ ] Rationale for exclusion documented

## Output Format

```json
{
  "functional": [
    {
      "id": "REQ-001",
      "title": "Requirement title",
      "description": "What the system must do",
      "priority": "must-have | should-have | nice-to-have"
    }
  ],
  "nonfunctional": [
    {
      "id": "NFR-001",
      "category": "performance | security | scalability | availability",
      "description": "Specific requirement"
    }
  ],
  "constraints": [
    {
      "id": "CON-001",
      "type": "technical | business | regulatory",
      "description": "Constraint description"
    }
  ],
  "assumptions": ["Assumption 1"],
  "dependencies": ["External system X"],
  "out_of_scope": ["Feature Y"]
}
```

## Success Criteria

- Requirements are complete, unambiguous, and structured
- Every requirement is testable or verifiable
- Constraints and assumptions documented
