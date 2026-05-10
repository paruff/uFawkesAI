# uFawkesAI
> Configure your AI agent to work the way DORA research proves high-performing teams work. One template. Every agent. DORA AI Capabilities built in from line one.
[![DORA AI Capabilities](https://img.shields.io/badge/DORA%20AI%20Capabilities-Built%20In-0A66C2?style=flat-square)](https://github.com/paruff/uFawkesAI) [![MIT License](https://img.shields.io/badge/License-MIT-2EA44F?style=flat-square)](./LICENSE) [![uFawkes Family](https://img.shields.io/badge/uFawkes-Family-6F42C1?style=flat-square)](https://github.com/paruff/uFawkesAI)
[![Works with Copilot](https://img.shields.io/badge/Works%20with-Copilot-24292F?style=flat-square)](https://docs.github.com/en/copilot/how-tos/custom-instructions/adding-custom-instructions-for-github-copilot) [![Works with Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-D97706?style=flat-square)](https://docs.anthropic.com/en/docs/claude-code) [![Works with Cursor](https://img.shields.io/badge/Works%20with-Cursor-1F6FEB?style=flat-square)](https://docs.cursor.com/context/rules-for-ai)
[![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/paruff/uFawkesAI)

## The problem
AI agents start every session blank. They do not know your conventions, architecture, or the research-backed practices that improve delivery performance. This template fixes both problems simultaneously.

## What you get
- `AGENTS.md` — universal agent instruction file, auto-loaded by Copilot, Claude Code, Cursor, Codex, Gemini CLI, Windsurf, and Devin
- `CLAUDE.md` symlink — so Claude Code gets the same instructions without a separate file
- `.github/copilot-instructions.md` symlink — Copilot's preferred path
- `.github/agents/` — 4 specialist agent profiles: docs, test, review, security
- `.github/instructions/` — scoped instruction files for feature and test work
- `docs/PROMPT_LIBRARY.md` — tested prompts for every repeating task, versioned
- `docs/GOLDEN_PATH.md` — 10-step idea→deploy workflow
- `docs/TEAM_ARCHETYPE.md` — DORA 2025 seven team archetype self-assessment
- CI workflow with PR size blocking (400 lines), doc freshness monitoring
- `scripts/weekly-metrics.sh` — rework rate, PR revision rate, CI cycle time in one view

## 5-minute quick start
```bash
# 1. Use this template (click "Use this template" on GitHub) or clone
git clone https://github.com/paruff/uFawkesAI.git my-project
cd my-project

# 2. Run setup (creates symlinks, installs hooks)
./scripts/setup.sh

# 3. Customise for your project (replace all [PLACEHOLDER] sections)
# Start with AGENTS.md — everything else derives from it
code AGENTS.md

# 4. Assign your first issue to Copilot or Claude Code
# Your agent now knows your project from session one
```

## DORA AI Capabilities implemented
| DORA AI Capability | File(s) in this template |
|---|---|
| Clear and communicated AI stance | `AGENTS.md` §1, `docs/AI_POLICY.md` |
| Healthy data ecosystems | `docs/CHANGE_IMPACT_MAP.md`, `docs/API_SURFACE.md` |
| AI-accessible internal data | `AGENTS.md` §3 context index, `.vscode/settings.json` |
| Strong version control practices | CI PR size block, conventional commits standard |
| Working in small batches | 400-line PR limit, TDD requirement, feature flags |
| User-centric focus | `docs/GOLDEN_PATH.md`, `docs/VALUE_STREAM_MAP.md` |
| Quality internal platforms | `docs/GOLDEN_PATH.md`, agent specialist profiles |

## Works with
- GitHub Copilot (native AGENTS.md support since Aug 2025 — server-side auto-load)
- Claude Code (reads AGENTS.md as fallback; CLAUDE.md symlink for direct load)
- Cursor (root AGENTS.md auto-detected; .cursor/rules/ for scoped instructions)
- OpenAI Codex (AGENTS.md is the native format)
- Gemini CLI (configure via .gemini/settings.json)
- Windsurf, Devin, Aider — via AGENTS.md

## Part of the uFawkes family
uFawkesAI is the AI plane in a five-stack delivery system: it sets policy, context, guardrails, and workflows so every other stack can move faster with less rework.

Integration entry point: [`docs/UFAWKES_INTEGRATION.md`](./docs/UFAWKES_INTEGRATION.md)

| Stack | Role | Link |
|---|---|---|
| uFawkesAI | AI plane (agent policy, context, controls) | [paruff/uFawkesAI](https://github.com/paruff/uFawkesAI) |
| uFawkesPipe | CI/CD and delivery pipeline plane | [paruff/uFawkesPipe](https://github.com/paruff/uFawkesPipe) |
| uFawkesObs | Observability and reliability plane | [paruff/uFawkesObs](https://github.com/paruff/uFawkesObs) |
| uFawkesApp | Product application plane | [uFawkesApp (planned)](https://github.com/paruff/uFawkesAI/issues) |
| uFawkesData | Data and analytics plane | [uFawkesData (planned)](https://github.com/paruff/uFawkesAI/issues) |

Quick integration hooks:
- **uFawkesObs:** set `OTEL_EXPORTER_OTLP_ENDPOINT` to export OTEL telemetry and view latency/token traces in Grafana.
- **uFawkesDORA:** provide `GITHUB_TOKEN`, `GITHUB_OWNER`, and `GITHUB_REPO` so `npm run metrics` can summarize delivery performance from your repo activity.
- **uFawkesPipe:** run the Golden Path (`docs/GOLDEN_PATH.md`) so AI-authored PRs flow through the `deliveryd` CI contract.

## Rework rate
> DORA 2025 added rework rate as a new core metric. It is the earliest signal that
> AI output quality is degrading. This template's `scripts/weekly-metrics.sh` calculates
> it from your git history. Target: < 10%. Above 20%: stop features, fix AGENTS.md first.

## Contributing
See [CONTRIBUTING.md](./CONTRIBUTING.md) (planned in AI-006).

## License
MIT
