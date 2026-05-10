# Copilot Agent Starter Template — Design Rationale

> This document explains **why** every file in this template exists and which DORA research
> principle it implements. Read this before customising the template for your project.
>
> Research sources:
> - **DORA 2025** — *State of AI-assisted Software Development* (2025)
> - **DORA AI Cap** — *AI Capabilities Model* companion report (Dec 2025)
> - **DORA ROI 2026** — *ROI of AI-Assisted Software Development* (2026)
> - **AAIF** — *AGENTS.md standard* — Linux Foundation Agentic AI Foundation (2025)
> - **Faros AI 2026** — *AI Engineering Report 2026* (22,000 developer telemetry study)
> - **GitHub Docs** — *Best practices for Copilot coding agent* (2025–2026)
> - **GitHub Blog** — *How to write a great agents.md: Lessons from 2,500+ repos* (Nov 2025)

---

## The Central DORA 2025 Warning

> "AI adoption is linked to higher software delivery throughput AND increases instability.
> Without robust control systems — strong automated testing, mature version control practices,
> and fast feedback loops — an increase in change volume leads to instability."

This is the founding constraint of the entire template. Every file exists to either
**accelerate** AI output or **control** AI output. Neither alone is sufficient.

2026 empirical confirmation: Faros AI's telemetry study of 22,000 developers found
median PR review time up 441% after AI adoption, and 31% of PRs merging with no review.
The productivity gains are real; the oversight failures are equally real.
The J-Curve of AI value realization (DORA ROI 2026) shows organizations must explicitly
budget for the learning phase — and these control systems are that budget.

---

## Template File Map

| File | DORA Capability | What It Does |
|---|---|---|
| `AGENTS.md` | AI Cap 3 — Context Engineering | Universal agent instruction file; loaded by all agents |
| `.github/copilot-instructions.md` | AI Cap 3 | Copilot-specific context index; auto-loaded by VS Code |
| `.github/skills/` | Agent Skills standard | On-demand modular capabilities |
| `CLAUDE.md` | Claude Code — primary config file | Symlink to AGENTS.md |
| `.cursorrules` | Cursor — primary config file | Symlink to AGENTS.md |
| `.github/agents/docs-agent.md` | AI Cap 2 — Prompt Engineering | Specialist for documentation generation |
| `.github/agents/test-agent.md` | AI Cap 2 | Specialist for test generation |
| `.github/agents/review-agent.md` | DORA 2025 — Review Speed | Specialist for code review (REVIEW-01) |
| `.github/agents/security-agent.md` | AI Cap 1 — AI Policy | Specialist for security review |
| `.github/instructions/feature.instructions.md` | AI Cap 3 | Scoped to src/**; injected for feature work |
| `.github/instructions/testing.instructions.md` | AI Cap 3 | Scoped to tests/**; injected for test work |
| `.github/PULL_REQUEST_TEMPLATE.md` | DORA 2025 — Review Speed | Structured AI-Assisted Review Block (REVIEW-01) |
| `.github/workflows/ci-quality.yml` | DORA 2025 — Control Systems | CI gate with PR size blocking (INSTAB-01) |
| `.github/workflows/doc-freshness.yml` | DORA 2025 — Living Docs | Posts reminder when services change without doc update |
| `docs/ARCHITECTURE.md` | DORA 2025 — Loosely Coupled | Layer boundaries enforced by ESLint (ARCH-01) |
| `docs/GOLDEN_PATH.md` | DORA 2025 — Platform Eng | 10-step idea→deploy workflow (PLAT-02) |
| `docs/PROMPT_LIBRARY.md` | AI Cap 2 — Prompt Engineering | Versioned task-specific prompt templates (AIOPS-04) |
| `docs/METRICS.md` | DORA 2025 — Rework Rate | Rework rate, change failure rate, PR revision rate (METRICS-02) |
| `docs/DEVEX_LOG.md` | DORA 2025 — DevEx | Monthly 5-dimension self-assessment (DEVEX-01) |
| `docs/TEAM_ARCHETYPE.md` | DORA 2025 — Archetypes | Seven archetype self-assessment; tailors issue priority (AIOPS-05) |
| `docs/VALUE_STREAM_MAP.md` | DORA 2025 — VSM | Issue→deploy flow with wait times; identifies bottleneck (VSM-01) |
| `docs/KNOWN_LIMITATIONS.md` | AI Cap 3 — Context | What agents must not make worse (DOCS-02) |
| `docs/API_SURFACE.md` | AI Cap 3 — Context | All public service/util functions; Copilot reads before generating (DOCS-02) |
| `docs/CHANGE_IMPACT_MAP.md` | AI Cap 3 — Context | Cross-file impact map; prevents Copilot omissions (DOCS-02) |
| `docs/RUNBOOKS.md` | DORA 2025 — Instability | Emergency rollback, feature disable, weekly review (INSTAB-01) |
| `docs/AI_POLICY.md` | AI Cap 1 — AI Policy | Clear AI stance; psychological safety (PSYCH-01) |
| `scripts/weekly-metrics.sh` | DORA 2025 — Rework Rate | Single-screen metrics summary (METRICS-02) |
| `.vscode/settings.json` | AI Cap 3 — Context Eng. | Auto-loads copilot-instructions.md in every session |

---

## The Seven DORA AI Capabilities (and how this template addresses each)

### Capability 1 — Clarify AI Policies
**Finding:** Ambiguity around AI use harms both adoption and psychological safety.
**Template response:** `docs/AI_POLICY.md` — explicit stance on what AI does/doesn't do, who reviews, data handling.

### Capability 2 — Prompt Engineering as Core Skill
**Finding:** "The modern engineer's value is in prompt engineering, solution architecture, and validating AI outputs — not just writing code."
**Template response:** `docs/PROMPT_LIBRARY.md` — versioned, categorised templates for every repeating task type. `TEMPLATE_DESIGN.md` explains the why.

### Capability 3 — AI-Accessible Internal Data (Context Engineering)
**Finding:** "Moving beyond simple prompts to securely connecting AI tools to your internal documentation and codebases" — Google's #2 "where to start" recommendation.
**Template response:** `AGENTS.md` context index, `.vscode/settings.json` auto-load, `docs/API_SURFACE.md`, `docs/KNOWN_LIMITATIONS.md`, `docs/CHANGE_IMPACT_MAP.md`.

### Capability 4 — Mature Version Control
**Finding:** Strong version control practices are prerequisites for safe AI adoption; without them AI increases instability.
**Template response:** Branch protection in CI, conventional commits standard, PR size blocking at 400 lines (INSTAB-01), large-pr-approved label gate.

### Capability 5 — Small Batches / Shift Left on Quality
**Finding:** Small batches are the most effective structural countermeasure to AI-induced instability.
**Template response:** PR size block in CI, TDD requirement in golden path, failing test commit before implementation commit.

### Capability 6 — Fast Feedback Loops
**Finding:** Fast feedback is the #1 platform capability correlated with positive DevEx.
**Template response:** CI < 4 min target, human-readable CI output, `npm run preflight` (lint+typecheck+test in one command), `docs/DEVEX_LOG.md` Feedback Speed dimension.

### Capability 7 — Internal Developer Platform
**Finding:** "Developer independence resulted in 5% productivity improvement."
**Template response:** `docs/GOLDEN_PATH.md` (one route from idea to deploy), `npm run pr-ready`, `npm run metrics`, agent specialists that reduce interruption.

### Capability 8 — Agent Skills (On-Demand Context)
**Finding:** As AGENTS.md becomes the universal standard (60,000+ open-source projects,
Linux Foundation), a second layer of modular, on-demand capabilities has emerged —
Agent Skills (SKILL.md files). Unlike AGENTS.md which is always loaded, Skills load
only when explicitly referenced, preserving the agent's limited instruction budget.
**Template response:** `.github/skills/` directory with three starter skills:
dora-metrics, security-review, and test-generation.

---

## The Three Sequencing Rules (DORA 2025)

DORA 2025 gives explicit sequencing guidance. This template mirrors it:

```
Phase 1: Clarify AI policies → AGENTS.md, AI_POLICY.md, TEAM_ARCHETYPE.md
Phase 2: Connect AI to context → copilot-instructions.md, API_SURFACE.md, KNOWN_LIMITATIONS.md
Phase 3: Prioritise foundational practices → CI, architecture, PR process
Phase 4: Fortify safety nets → feature flags, rollback, rework rate tracking
Phase 5: Invest in platform → GOLDEN_PATH.md, agents, prompt library
Phase 6: Focus on end-users → features, then iterate
```

Phase 0 (new): Before Phase 1 — assess team archetype using DORA 2025's seven profiles
(not the legacy low/medium/high/elite tiers). Different archetypes need different Phase 1
priorities. A "legacy bottleneck" team needs Phase 3 first; a "harmonious high-achiever"
team can start at Phase 4.

---

## What a Top-Team Adds Beyond This Template

This template establishes the foundation. Elite teams additionally:

1. **Run VSM before first feature** — map wait times across Issue→Deploy to find the real bottleneck before accelerating
2. **Complete team archetype assessment** — `docs/TEAM_ARCHETYPE.md` — to prioritise which controls to add first
3. **Iterate the prompt library** — add a changelog entry every time a prompt produced bad output
4. **Track DevEx monthly** — `docs/DEVEX_LOG.md` — the single leading indicator of whether the AI workflow is helping or grinding
5. **Wire feature flags from day one** — every new feature behind a flag; allows remote disable without OTA
6. **Treat rework rate as the north star metric** — not LOC, not PR count. Rework rate > 10% = stop adding features, fix instructions first
