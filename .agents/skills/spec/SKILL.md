---
name: spec
description: "Convert a human request into a clear, structured specification and technical design with architecture, components, interfaces, and data flows. Implements DORA AI Capabilities 1, 3, 4, 5."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  form: rule
---

# Skill: spec

> **Load trigger:** "load spec skill" > **DORA:** AI Capabilities 1, 3, 4, 5
> **Token cost:** Medium

## Purpose

Convert a human request into a clear, structured specification and technical design with architecture, components, interfaces, and data flows. Combines requirements extraction, acceptance criteria, architecture decomposition, component identification, interface definition, and K8s design validation. Implements DORA AI Capabilities 1, 3, 4, 5.

## When to Use

- Starting a new feature or capability that needs formal requirements
- Translating requirements into a buildable system design
- Architecture decomposition, component identification, interface definition
- K8s design validation

## Sub-skills (now integrated)

### 1. Requirements & Acceptance Criteria

# Skill: Spec

> **Load trigger:** `"load spec skill"`

> Migrated from the former `spec` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

Converts a human's stated intent into a structured specification that the `design` skill can consume: requirements, acceptance criteria, constraints, and policy alignment — not code.

## Artifact Chain — Your Link

Every feature lives in `docs/ai-sdlc/<feature>/` and moves through committed
artifacts: `intent.md` → **`spec.md`** → `plan.md` → code diff
(`docs/ai-sdlc/README.md`). You **read `intent.md`** and **write `spec.md`**
next to it.

CI enforces the chain (`.github/workflows/artifact-chain.yml`): a `spec.md`
with no sibling `intent.md` in the branch history fails the PR and blocks the
merge. So:

- If `docs/ai-sdlc/<feature>/intent.md` does not exist, **stop** — ask the
  human for the intent (or load the `discover` skill) and commit `intent.md`
  first. Never write a spec without one.
- Commit `spec.md` on the same feature branch as `intent.md`, so both are
  visible in the PR diff.

## Inputs Required Before Specifying

Read these files first:

1. `docs/ai-sdlc/<feature>/intent.md` — **required.** The problem, desired
   outcome, decisions already made, and out-of-scope list. Every requirement
   you write must trace back to it; anything beyond it is scope expansion and
   must be flagged as such.
2. `AGENTS.md` — project identity, governance rules, what agents may/must not do
3. `docs/GOLDEN_PATH.md` — canonical idea→deploy workflow (if exists)
4. Existing `docs/ai-sdlc/*/spec.md` files (avoid duplicating work)
5. `discovery-brief.md` — carries the persona, JTBD, riskiest assumption, and a
   draft acceptance criterion with a `test_type` tag from the `discover` agent.
   Do not discard the `test_type` tag without reason — carry it forward onto
   the corresponding AC below, and assign a `test_type` to any further ACs you
   derive that the discovery brief didn't already cover.

`intent.md` is mandatory; for the others, if a file is missing, note it and
proceed with what is available.

## Spec Protocol

### Step 1 — Clarify Intent

Restate the human's intent as a user story:

> "As a [role], I want [capability], so that [outcome]."

Ask clarifying questions if the intent is ambiguous. Wait for confirmation before proceeding.

### Step 2 — Extract Requirements

Decompose the intent into structured requirements:

- **Functional requirements** — what the system must do
- **Non-functional requirements** — performance, scalability, security, availability
- **Constraints** — technical, business, regulatory limitations
- **Assumptions** — what we're taking as true without verification
- **Dependencies** — external systems, services, or teams
- **Out of scope** — what this spec explicitly does not cover

### Step 3 — Generate Acceptance Criteria

Convert each requirement into binary pass/fail criteria:

- [ ] AC-01: Specific, testable assertion — `test_type: unit | integration | live-system`
- [ ] AC-02: Specific, testable assertion — `test_type: unit | integration | live-system`

Rules:

- Each AC must be independently verifiable
- No ambiguous language ("should", "might", "good enough")
- Include measurable outcomes where possible
- Each AC must carry a `test_type` tag. Default to whatever `discover.md`
  already assigned for the AC it corresponds to; for any new AC you introduce
  here, assign the tag yourself using the same judgment call `discover.md`
  applies — a one-sentence reasoning is not required here (it was already
  captured upstream), but do not tag an AC touching a deployed/runtime
  component as `unit` just because that's the default — check first.

### Step 4 — Validate Against Governance

Check the spec against platform rules:

- Security requirements addressed
- Pipeline requirements noted (SBOM, signing, test stages)
- Kubernetes requirements noted (if applicable)
- Naming and structure conventions noted

### Step 5 — Produce Specification

Write the specification to `docs/ai-sdlc/<feature>/spec.md` (the Output
Format below) and commit it on the feature branch. Hand off to the `design`
skill,
which reads this file to write `plan.md`.

## Required Skills

Load these skills as needed:

| Skill                           | When to Load                               |
| ------------------------------- | ------------------------------------------ |
| `spec/requirements-extraction`  | Extracting structured requirements         |
| `spec/spec-acceptance-criteria` | Generating testable ACs                    |
| `spec/policy-validation`        | Validating against organizational policies |
| `spec/pipeline-policy`          | Aligning with pipeline governance          |
| `spec/template-governance`      | Aligning with platform templates           |
| `spec/k8s-policy`               | Kubernetes-specific requirements           |

## Output Format

```markdown
# Specification: [Feature Name]

## User Story

As a [role], I want [capability], so that [outcome].

## Functional Requirements

### REQ-001: [Requirement Title]

[Description of what the system must do]

### REQ-002: [Requirement Title]

[Description]

## Non-Functional Requirements

### NFR-001: Performance

[Response time, throughput requirements]

### NFR-002: Security

[Authentication, authorization, data protection]

## Constraints

- [Technical constraint]
- [Business constraint]

## Assumptions

- [Assumption 1]
- [Assumption 2]

## Dependencies

- [External system or service]
- [Team or approval required]

## Out of Scope

- [Explicitly excluded feature]
- [Explicitly excluded feature]

## Acceptance Criteria

- [ ] AC-01: [Specific, testable assertion] — `test_type: unit | integration | live-system`
- [ ] AC-02: [Specific, testable assertion] — `test_type: unit | integration | live-system`
- [ ] AC-03: [Specific, testable assertion] — `test_type: unit | integration | live-system`

## Governance Alignment

| Requirement | Status  | Notes          |
| ----------- | ------- | -------------- |
| Security    | COVERED | [Details]      |
| Pipeline    | COVERED | [Details]      |
| K8s         | N/A     | Not applicable |

## Open Questions

- [Question requiring human decision]
```

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

- Required sections: Specification:, Functional Requirements, Acceptance Criteria, Governance Alignment
- Every Acceptance Criteria line item must carry a `test_type` tag
- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/assertion-runner.sh <report.md> spec`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), `triggered_by`, `started_at`, `duration_ms`, skills loaded, findings, decision, blockers
4. For each finding, set `actionable`, `manual_review_needed`, and `severity` accurately
5. Set `triggered_by` to whichever orchestrator invoked this agent: `"discovery"` (the typical case for spec), or `"manual"` if invoked directly by the user
6. Record `started_at` (ISO 8601, when this agent began) — `timestamp` in the log entry remains the completion time
7. Compute `duration_ms` as the difference between `started_at` and completion

### Finding Severity

Every finding must carry a `severity` field, one of:

- `blocker` — prevented the task from completing as planned; required a fix before proceeding
- `defect` — a real problem that was found and fixed within this invocation, but did not block completion
- `note` — informational; no fix required

Do not default to `defect` when uncertain — if a finding did not require any change to resolve, it is a `note`, not a `defect`.

This log is required. If the file cannot be written, document why.

## Hard Rules

- Never write `spec.md` without a committed `intent.md` in the same `docs/ai-sdlc/<feature>/` directory.
- Never produce a specification without acceptance criteria.
- Never produce an acceptance criterion without a `test_type` tag.
- Never leave ambiguous requirements — flag for clarification.
- Never assume governance compliance — validate it.
- Never add features not requested without noting it as scope expansion.
- If the request is too vague, ask questions before specifying.

## Inputs

- Human intent (requirements, feature request, bug fix)
- Policy documents (if available)
- Existing specification (if updating)

## Outputs

- `specification.md`
- `acceptance-criteria.md`
- `constraints.md`

### 2. Architecture & Components

# Skill: Design

> **Load trigger:** `"load design skill"`

> Migrated from the former `design` agent. It is a skill, not an execution
> boundary: same tools, same model, same memory — the stage name describes work,
> not a separate agent runtime.

Converts the specification into an actionable technical design and implementation plan that the `build` skill follows: architecture decisions, component definitions, interface contracts, data models, an implementation sequence, and a verification strategy — not code.

## Artifact Chain — Your Link

Every feature lives in `docs/ai-sdlc/<feature>/` and moves through committed
artifacts: `intent.md` → `spec.md` → **`plan.md`** → code diff
(`docs/ai-sdlc/README.md`). You **read `spec.md`** (and the `intent.md` it
traces to) and **write `plan.md`** next to them.

CI enforces the chain (`.github/workflows/artifact-chain.yml`): a PR that
changes `src/` must include a `docs/ai-sdlc/<feature>/plan.md` with a
`## Verification Strategy` section in the same diff, or the merge is blocked.
So:

- If `docs/ai-sdlc/<feature>/spec.md` does not exist, **stop** and route to
  the `spec` skill. Never plan from a request that has no committed spec.
- `plan.md` must always contain `## Verification Strategy` mapping every
  acceptance criterion to how it will be proven.
- Commit `plan.md` on the feature branch, so `@builder`'s code lands in the
  same PR as the plan it implements.

## Inputs Required Before Designing

Read these files first:

1. `docs/ai-sdlc/<feature>/spec.md` — **required.** Requirements and
   acceptance criteria, including each AC's `test_type` tag
2. `docs/ai-sdlc/<feature>/intent.md` — the originating problem and
   decisions already made (to catch spec drift from intent)
3. `AGENTS.md` — project identity, architecture rules, layer boundaries
4. `docs/ARCHITECTURE.md` — existing architecture patterns (if exists)
5. `docs/KNOWN_LIMITATIONS.md` — existing constraints (if exists)

`spec.md` is mandatory; for the others, if a file is missing, note it and
proceed with what is available.

## Design Protocol

### Step 1 — Validate Specification

Before designing, confirm:

- [ ] `docs/ai-sdlc/<feature>/spec.md` exists and is complete
- [ ] All requirements are clear and unambiguous
- [ ] Acceptance criteria are defined, each with a `test_type` tag
- [ ] Governance constraints are noted

If specification is incomplete, flag gaps and request clarification.

### Step 2 — Decompose Architecture

Break the system into logical components:

- Identify major system components
- Identify data flows between components
- Identify external dependencies
- Identify boundaries and responsibilities
- Select architecture patterns (if applicable)
- **Note which components are actually deployed/networked at runtime** (as
  opposed to purely in-process logic) — this is what downstream `test`/
  `test-execution` need to know when deciding what a `live-system`-tagged AC
  actually has to stand up and hit. This is a proposed addition for this
  plan, not an established convention elsewhere in the repo — treat it as a
  note to carry forward, not a rigid schema.

### Step 3 — Define Components

For each component, define:

- Purpose and responsibility
- Interfaces (APIs, events, data contracts)
- Dependencies on other components
- Technology choices and rationale
- Security considerations
- Whether this component is exercised by any `live-system`-tagged AC from the
  spec, and if so, which one

### Step 4 — Define Interfaces

For each interface:

- API endpoints (method, path, request/response shapes)
- Data models (schemas, types)
- Event schemas (if async)
- Error handling contracts

### Step 5 — Identify Risks and Tradeoffs

- Technical risks
- Architecture tradeoffs
- Security implications
- Scalability considerations

### Step 6 — Validate Against Governance

Check the design against platform rules:

- Architecture follows layer boundaries
- Security requirements addressed
- Pipeline requirements included
- Kubernetes patterns followed (if applicable)

### Step 7 — Sequence the Implementation

Order the work into small, independently verifiable steps (each small enough
for a reviewable PR), noting dependencies between them.

### Step 8 — Define the Verification Strategy

For **every** acceptance criterion in `spec.md`, state how it will be
proven: the test or check, its `test_type` (unit | integration |
live-system), and the command or CI job that runs it. An AC with no
verification entry is a gap — flag it rather than leave it out.

### Step 9 — Write plan.md

Write the result to `docs/ai-sdlc/<feature>/plan.md` (the Output Format
below) and commit it on the feature branch. Hand off to `@builder`, which reads
this file to produce the code diff.

## Required Skills

Load these skills as needed:

| Skill                               | When to Load                     |
| ----------------------------------- | -------------------------------- |
| `design/architecture-decomposition` | Breaking spec into architecture  |
| `design/component-identification`   | Identifying required components  |
| `design/interface-definition`       | Defining API and data contracts  |
| `spec/template-governance`          | Aligning with platform templates |
| `spec/policy-validation`            | Validating against policies      |
| `design/k8s-design-validation`      | Kubernetes-specific design       |

## Output Format

Write this to `docs/ai-sdlc/<feature>/plan.md`:

````markdown
# Design: [Feature Name]

Implements `docs/ai-sdlc/<feature>/spec.md`.

## Architecture Overview

[High-level description of the architecture]

## Components

### Component: [Name]

- **Purpose:** [What it does]
- **Responsibility:** [What it owns]
- **Interfaces:** [APIs, events]
- **Dependencies:** [Other components]
- **Technology:** [Language, framework]
- **Runtime/deployed:** [yes/no — is this actually deployed and networked, or purely in-process?]
- **Exercised by live-system AC:** [AC-0X | none]

## Data Flow

1. [Step 1: User action → Component A]
2. [Step 2: Component A → Component B]
3. [Step 3: Component B → Database]

## Interfaces

### API: [Endpoint]

- **Method:** POST
- **Path:** `/api/v1/resource`
- **Request:** `{ "field": "type" }`
- **Response:** `{ "field": "type" }`
- **Errors:** 400, 404, 500

### Data Model: [Name]

```json
{
  "field": "type"
}
```

## Tradeoffs

| Decision | Chosen     | Rejected | Rationale              |
| -------- | ---------- | -------- | ---------------------- |
| Database | PostgreSQL | MongoDB  | ACID compliance needed |

## Risks

| Risk                  | Severity | Mitigation              |
| --------------------- | -------- | ----------------------- |
| External API downtime | HIGH     | Circuit breaker + retry |

## Governance Alignment

| Requirement | Design Decision      | Status  |
| ----------- | -------------------- | ------- |
| Security    | JWT auth + RBAC      | COVERED |
| Pipeline    | Standard stages      | COVERED |
| K8s         | Deployment + Service | COVERED |

## Implementation Sequence

1. [Step — files/components touched — depends on: none]
2. [Step — files/components touched — depends on: 1]

## Verification Strategy

| AC    | How it is proven                 | test_type   | Command / CI job         |
| ----- | -------------------------------- | ----------- | ------------------------ |
| AC-01 | [test or check that proves it]   | unit        | `npm test -- auth.spec`  |
| AC-02 | [test or check that proves it]   | live-system | `ci-quality.yml` › e2e   |
````

## Output Contract

Your report MUST satisfy this contract. Self-validate before finishing.

- Required sections: Design:, Architecture Overview, Components, Tradeoffs, Governance Alignment, Implementation Sequence, Verification Strategy
- Each Component must state Runtime/deployed status and which live-system AC (if any) exercises it
- Every acceptance criterion in `spec.md` must appear in the Verification Strategy table
- Schema: `.agents/assertions/agent-output-schema.json`
- Runner: `bash .agents/assertions/assertion-runner.sh <report.md> design`

## Post-Task Logging

After producing your report, write a structured log entry:

1. Append one JSON object to `.agents/logs/YYYY-MM-DD.jsonl` (one line per invocation)
2. Follow the schema in `.agents/schema/skill-invocation-log.json`
3. Include: agent name, session_id (unique identifier), `triggered_by`, `started_at`, `duration_ms`, skills loaded, findings, decision, blockers
4. For each finding, set `actionable`, `manual_review_needed`, and `severity` accurately
5. Set `triggered_by` to whichever orchestrator invoked this agent: `"discovery"` (the typical case for design), or `"manual"` if invoked directly by the user
6. Record `started_at` (ISO 8601, when this agent began) — `timestamp` in the log entry remains the completion time
7. Compute `duration_ms` as the difference between `started_at` and completion

### Finding Severity

Every finding must carry a `severity` field, one of:

- `blocker` — prevented the task from completing as planned; required a fix before proceeding
- `defect` — a real problem that was found and fixed within this invocation, but did not block completion
- `note` — informational; no fix required

Do not default to `defect` when uncertain — if a finding did not require any change to resolve, it is a `note`, not a `defect`.

This log is required. If the file cannot be written, document why.

## Hard Rules

- Never write `plan.md` without a committed `spec.md` in the same `docs/ai-sdlc/<feature>/` directory.
- Never write `plan.md` without a `## Verification Strategy` section covering every acceptance criterion.
- Never produce a design without validating the specification first.
- Never leave interface contracts ambiguous — define exact shapes.
- Never ignore governance constraints noted in the spec.
- Never make technology choices without rationale.
- Never leave a component's runtime/deployed status unstated.
- If the spec has gaps, flag them before designing.

## Inputs

- `specification.md` (from spec)
- Existing architecture (if updating)
- Policy documents

## Outputs

- `design.md`
- `architecture-decisions.md`
- `component-interfaces.md`

## Usage

```bash
# Extract requirements
load spec/requirements-extraction skill

# Generate acceptance criteria
load spec/spec-acceptance-criteria skill

# Architecture decomposition
load spec/architecture-decomposition skill

# Component identification
load spec/component-identification skill

# Interface definition
load spec/interface-definition skill

# K8s design validation
load spec/k8s-design-validation skill

# Policy validation
load spec/policy-validation skill
```

## Enforcement

- **DORA vocabulary** validates AI Capabilities 1, 3, 4, 5 references
- **AI stance audit** validates relevant clarity dimensions
