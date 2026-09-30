# Architecture

uFawkesAI is a documentation-and-agent-orchestration template, not an
application with a runtime call stack. "Architecture" here means: which
layer of files may depend on, reference, or be modified by which other
layer. Agents read this file before generating or changing structure so
they don't blur these boundaries.

## Layers

```
┌────────────────────────────────────────────────────────────────┐
│ 1. Instruction layer                                            │
│    AGENTS.md (source) ← CLAUDE.md, .cursorrules,                │
│    .github/copilot-instructions.md, .cursor/rules/AGENTS.md      │
│    (symlinks — always identical, never edited directly)          │
└───────────────────────────────┬────────────────────────────────┘
                                 │ routes to
┌───────────────────────────────▼────────────────────────────────┐
│ 2. Agent layer — `.agents/agents/`                               │
│    7 core pipeline agents (spec→design→build→test→review→        │
│    cross-validation) + 7 flow/meta agents that orchestrate them  │
└───────────────────────────────┬────────────────────────────────┘
                                 │ loads on demand
┌───────────────────────────────▼────────────────────────────────┐
│ 3. Skill layer — `.agents/skills/`                                │
│    31 on-demand capability folders (SKILL.md per Agent Skills    │
│    spec). Passive reference material — skills never invoke        │
│    agents or other skills; only an agent decides to load one.    │
└───────────────────────────────┬────────────────────────────────┘
                                 │ checked against by
┌───────────────────────────────▼────────────────────────────────┐
│ 4. Governance layer                                               │
│    `.agents/registry/` — capability + lifecycle metadata          │
│    `.agents/schema/` — JSON schemas for handoffs and logs         │
│    `.agents/assertions/` — report contracts + validation runners  │
└───────────────────────────────┬────────────────────────────────┘
                                 │ invoked by
┌───────────────────────────────▼────────────────────────────────┐
│ 5. Automation layer                                                │
│    `scripts/` — human/CI-invoked (metrics, preflight, setup)      │
│    `.agents/hooks/` — git hooks (pre-commit-agent, post-commit)   │
│    `.github/workflows/` — CI gates (ci-quality, main-ci-guard,     │
│    doc-freshness, secret-scan, dependency-review)                 │
└────────────────────────────────────────────────────────────────┘
```

`templates/` sits outside these five layers — it is output scaffolding
handed to *downstream* projects that adopt this template, not part of
uFawkesAI's own structure.

## Dependency rules

- **Layer 1 → Layer 2, read-only.** Agents read `AGENTS.md`; nothing may
  modify it except a human-approved PR (Hard Rule 3).
- **Layer 2 → Layer 3, one direction.** Agents load skills on demand.
  Skills do not load agents or other skills, and never act autonomously —
  they're reference material an agent consults mid-task.
- **Layer 2/3 → Layer 4, validated by.** `cross-validation` (agent) and
  `cross-validation-runner.sh` (governance) check agent *output* against
  the contracts in `.agents/assertions/`, not the skill or agent files
  themselves.
- **Layer 5 wraps everything.** CI workflows and git hooks call into
  `scripts/` and `.agents/assertions/` at defined checkpoints (pre-commit,
  pre-merge); they do not read or write `.agents/agents/` or
  `.agents/skills/` content directly.

## Enforcement status

These boundaries are **documentation conventions today, not
machine-enforced**. `package.json`'s `lint`, `typecheck`, and
`lint:architecture` scripts are placeholders (this repo ships no
application source to lint yet — see `package.json`). If you fork this
template for a real service with `src/`, wire a real linter's
import-boundary rules to the layers above and replace the placeholder
scripts.

## uFawkes suite boundary

This file describes uFawkesAI's *internal* structure. What crosses into
the rest of the uFawkes stack family (uFawkesPipe, uFawkesObs, uFawkesDORA)
is a separate, narrower contract — see
[`docs/UFAWKES_INTEGRATION.md`](./UFAWKES_INTEGRATION.md).

## Keeping this current

Update this file whenever a layer's boundary changes (a new top-level
`.agents/` subfolder, a new governance contract, a new CI gate). The
`documentation` and `context-engineering` skills check for this file's
existence and flag staleness after 90 days without a structural change —
see `docs/RUNBOOKS.md`'s monthly review checklist.
