---
description: Research, design, and plan with Superpowers + the plan skill
agent: plan
---

Produce an implementation-ready design and plan by chaining three skills in
order. Load each explicitly — the plugin's bootstrap context is not a
substitute for invocation.

## Phase 1 — Design (superpowers `brainstorming`)

Load the `brainstorming` skill and follow its workflow strictly:

1. Explore project context (files, commits, docs — start with `AGENTS.md`,
   `discovery-brief.md`, `specification-design.md`)
2. Ask clarifying questions one at a time
3. Propose 2-3 approaches with recommendations
4. Present design sections for confirmation
5. Write the design to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
   (existing convention — match neighbouring files)
6. Self-review the spec (scan for TBD/TODO, contradictions, scope issues)

## Phase 2 — Plan (superpowers `writing-plans`)

Load the `writing-plans` skill and produce
`docs/superpowers/plans/YYYY-MM-DD-<topic>.md` — sequenced, bounded steps
with verification for each.

## Phase 3 — Decompose (the `plan` skill)

Load the `plan` skill (sub-skills `plan/task-decomposition`,
`plan/dependency-mapping`, `plan/effort-estimation`,
`plan/risk-identification`, `plan/skill-matching`, `plan/governance-alignment`
on demand) and apply its rules against the design + plan docs:

- every task fits a single PR, ≤ 400 changed lines, independently mergeable
- dependencies explicit, critical path identified, parallelism noted
- risks mitigated, each task assigned an agent/skills, token budget sane

Emit its JSON outputs next to the plan doc, prefixed with the same stem:

- `docs/superpowers/plans/<stem>.tasks.json`
- `docs/superpowers/plans/<stem>.dependency-graph.json`
- `docs/superpowers/plans/<stem>.effort-estimates.json`

## GitOps Integration

After all artifacts exist:

- Create a branch: `git checkout -b plan/<topic>`
- Commit: `docs(plan): add design and plan for <topic>`
- Push and open a **draft** PR for review:
  `gh pr create --draft --base main --title "docs(plan): <topic>" --body "..."`

Do NOT write any implementation code until the design is committed and
approved. Implementation proceeds on its own branch with the
`executing-plans` skill and the TDD gate — never inside this plan branch.
