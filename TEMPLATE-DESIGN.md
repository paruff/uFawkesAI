# uFawkesAI Template — Design Rationale

> This document explains **why** every file in this template exists and which DORA research
> principle it implements. Read this before customising the template for your project.
>
> Research sources:
>
> - **DORA 2025** — _State of AI-assisted Software Development_ (2025)
> - **DORA AI Cap** — _AI Capabilities Model_ companion report (Dec 2025)
> - **DORA ROI 2026** — _ROI of AI-Assisted Software Development_ (2026)
> - **AAIF** — _AGENTS.md standard_ — Linux Foundation Agentic AI Foundation (2025)
> - **Faros AI 2026** — _AI Engineering Report 2026_ (22,000 developer telemetry study)
> - **GitHub Docs** — _Best practices for Copilot coding agent_ (2025–2026)
> - **GitHub Blog** — _How to write a great agents.md: Lessons from 2,500+ repos_ (Nov 2025)

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

| File                                           | Capability / Standard Link        | What It Does                                                                 |
| ---------------------------------------------- | --------------------------------- | ---------------------------------------------------------------------------- |
| `AGENTS.md`                                    | AI Capability 3                  | Universal agent instruction file; loaded by all agents                       |
| `.github/copilot-instructions.md`              | AI Capability 3                  | Copilot path-compatibility symlink to `AGENTS.md`                            |
| `.github/skills/`                              | Agent Skills standard             | On-demand modular capabilities                                               |
| `CLAUDE.md`                                    | Claude Code — primary config file | Symlink to AGENTS.md                                                         |
| `.cursorrules`                                 | Cursor — primary config file      | Symlink to AGENTS.md                                                         |
| `.agents/agents/` (4 files)                    | Core: Prompt engineering         | The 4 execution-boundary agents: `planner`, `builder`, `verifier`, `operator` — see `.agents/README.md` |
| `.agents/agents/verifier.md`                   | AI Capabilities 4 + 5 + 6        | The verdict: evidence vs. claims. The only agent that can block (REVIEW-01)   |
| `.github/instructions/feature.instructions.md` | AI Capability 3                  | Scoped to src/\*\*; injected for feature work                                |
| `.github/instructions/testing.instructions.md` | AI Capability 3                  | Scoped to tests/\*\*; injected for test work                                 |
| `.github/PULL_REQUEST_TEMPLATE.md`             | DORA 2025 — Review Speed          | Structured AI-Assisted Review Block (REVIEW-01)                              |
| `.github/workflows/ci-quality.yml`             | DORA 2025 — Control Systems       | CI gate with PR size blocking (INSTAB-01)                                    |
| `.github/workflows/doc-freshness.yml`          | DORA 2025 — Living Docs           | Posts reminder when services change without doc update                       |
| `docs/ARCHITECTURE.md`                         | DORA 2025 — Loosely Coupled       | Layer boundaries as convention today; wire a linter's import rules to them if you add application source (ARCH-01) |
| `docs/GOLDEN_PATH.md`                          | DORA 2025 — Platform Eng          | 10-step idea→deploy workflow (PLAT-02)                                       |
| `docs/PROMPT_LIBRARY.md`                       | Core: Prompt engineering         | Versioned task-specific prompt templates (AIOPS-04)                          |
| `docs/METRICS.md`                              | DORA 2025 — Rework Rate           | Rework rate, change failure rate, PR revision rate (METRICS-02)              |
| `docs/DEVEX_LOG.md`                            | DORA 2025 — DevEx                 | Monthly 5-dimension self-assessment (DEVEX-01)                               |
| `docs/TEAM_ARCHETYPE.md`                       | DORA 2025 — Archetypes            | Seven archetype self-assessment; tailors issue priority (AIOPS-05)           |
| `docs/VALUE_STREAM_MAP.md`                     | DORA 2025 — VSM                   | Issue→deploy flow with wait times; identifies bottleneck (VSM-01)            |
| `docs/KNOWN_LIMITATIONS.md`                    | AI Capability 3                  | What agents must not make worse (DOCS-02)                                    |
| `docs/API_SURFACE.md`                          | AI Capability 3                  | All public service/util functions; Copilot reads before generating (DOCS-02) |
| `docs/CHANGE_IMPACT_MAP.md`                    | AI Capability 3                  | Cross-file impact map; prevents Copilot omissions (DOCS-02)                  |
| `docs/RUNBOOKS.md`                             | DORA 2025 — Instability           | Emergency rollback, feature disable, weekly review (INSTAB-01)               |
| `docs/AI_POLICY.md`                            | AI Capability 1                  | Clear AI stance; psychological safety (PSYCH-01)                             |
| `scripts/weekly-metrics.sh`                    | DORA 2025 — Rework Rate           | Single-screen metrics summary (METRICS-02)                                   |
| `.vscode/settings.json`                        | AI Capability 3                  | Auto-loads copilot-instructions.md in every session                          |
| `.mcp.json`                                     | Dual-Harness — MCP Config         | Claude Code's MCP server registrations, mirroring `opencode.json`'s server set |
| `.opencode/skills/*-rules/SKILL.md`             | Agent Skills standard             | Testing/security/api-design/gitops rules, migrated from `rules/*.md` to on-demand skills; visible at `.claude/skills/` via symlink |
| `scripts/hooks/protected-paths.json`            | Dual-Harness — Shared Hook Data   | Protected-path list read by both `.claude/settings.json` and `.opencode/plugins/ai-sdlc-hooks.ts` |
| `scripts/AGENTS.md` + `scripts/CLAUDE.md`       | OpenCode "Rules" / Claude Code memory | Directory-scoped rule example — loads only when working under `scripts/` |
| `scripts/check-harness-parity.sh`               | Dual-Harness — Anti-Shadowing     | CI check: `.claude`↔`.opencode` symlinks intact, MCP server sets match, no reserved-name collisions |
| `scripts/dual-harness-smoke.sh`                 | Dual-Harness — CI Smoke Test      | Proves one example each of MCP server, skill, hook, command, and rule works under both harnesses |
| `.devcontainer/devcontainer.json`               | Dual-Harness — Devcontainer       | Installs both `opencode` and Claude Code CLIs, version-pinned, non-root `remoteUser` |
| `.github/workflows/ci-quality.yml` (`dual-harness-smoke` job) | Dual-Harness — CI Gate | Runs `scripts/dual-harness-smoke.sh` inside the built devcontainer on every push/PR |

---

## The Capability Model in This Template

The canonical vocabulary is the **DORA AI Capabilities Model (2025)** — seven
capabilities, source of truth in `.agents/registry/dora-capabilities.yaml`.
Every capability label in this repo reads `AI Capability N: <Name>`, and
`scripts/check-dora-vocabulary.sh` fails the build if a file uses a different
name for a given number.

### AI Capability 1 — Clear and communicated AI stance

**Finding:** Ambiguity around AI use harms both adoption and psychological safety.
A clear stance amplifies AI's impact _regardless of what the stance says_.
**Template response:** `AI_STANCE.md` (authoritative) and `docs/AI_POLICY.md`
(downstream-repo template) — explicit stance on permitted tools, expectations
for AI use, and data handling.

### AI Capability 2 — Healthy data ecosystems

**Finding:** The quality of internal data is critical to AI success. High-quality,
easily accessible, unified internal data substantially amplifies AI's influence
on organizational performance.
**Template response:** `docs/DORA_alignment.md` maps the five core delivery
metrics to the session-linked JSONL logs that this template emits.

### AI Capability 3 — AI-accessible internal data

**Finding:** "Moving beyond simple prompts to securely connecting AI tools to
your internal documentation and codebases." This is the capability commonly
called _context engineering_ — the name is common, but it is not the DORA name.
**Template response:** `AGENTS.md` context index, `.vscode/settings.json`
auto-load, `docs/API_SURFACE.md`, `docs/KNOWN_LIMITATIONS.md`,
`docs/CHANGE_IMPACT_MAP.md`, and the `context-engineering` skill.

### AI Capability 4 — Strong version control practices

**Finding:** With AI increasing the volume and velocity of code generation,
strong version control habits are a safety net. Frequent commits amplify
individual effectiveness; frequent use of rollback boosts team performance.
**Template response:** Branch protection in CI, conventional commits standard,
PR size blocking at 400 lines (INSTAB-01), large-pr-approved label gate, and the
`main-ci-guard` workflow.

### AI Capability 5 — Working in small batches

**Finding:** Small batches are the most effective structural countermeasure to
AI-induced instability — AI can generate large blocks that are hard to review
and test.
**Template response:** PR size block in CI, TDD requirement in the golden path,
failing test committed before the implementation commit.

### AI Capability 6 — User-centric focus

**Finding:** Without a user-centric focus, AI adoption can have a _negative_
impact on team performance — teams move quickly in the wrong direction. Speed is
irrelevant if the direction is wrong.
**Template response:** the `discover` skill (JTBD + acceptance criteria before
any `spec` stage), the `discovery` workflow, and `platform-feedback` for the
measurement half.

### AI Capability 7 — Quality internal platforms

**Finding:** Quality internal platforms provide the shared capabilities needed to
scale AI's benefits. They prevent individual productivity gains from being
absorbed by downstream bottlenecks.
**Template response:** `docs/GOLDEN_PATH.md` (one route from idea to deploy),
`npm run preflight`, `npm run pr-ready`, `docs/DEVCONTAINER.md`.

### Template extensions — not DORA capabilities

These three are real practices this template implements, but they are **not**
among DORA's seven. They are labelled `Core:` in capability lines and are
deliberately kept out of the numbered sequence, because giving them numbers is
what previously caused `Cap 6` to mean three different things across this repo.

- **Prompt engineering as a core skill.** The DORA ROI report does observe that
  "the modern engineer's value is in prompt engineering, solution architecture,
  and validating AI outputs — not just writing code." That is a finding about
  developer craft, not one of the seven AI capabilities. Response:
  `docs/PROMPT_LIBRARY.md`.
- **Agent Skills (on-demand context).** An implementation pattern layered on top
  of the model, not a capability: `AGENTS.md` is always loaded, whereas a
  `SKILL.md` loads only when referenced, preserving the instruction budget.
  Response: `.agents/skills/` — see `.agents/README.md`.
- **Fast feedback loops.** A platform quality attribute (CI under 4 min,
  human-readable output, one-command preflight), reported under
  `docs/DEVEX_LOG.md` rather than as a capability.

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
