# uFawkesAI

> Configure your AI agent to work the way DORA research proves high-performing teams work. One template. Every agent. DORA AI Capabilities built in from line one.
> [![DORA AI Capabilities](https://img.shields.io/badge/DORA%20AI%20Capabilities-Built%20In-0A66C2?style=flat-square)](https://github.com/paruff/uFawkesAI) [![MIT License](https://img.shields.io/badge/License-MIT-2EA44F?style=flat-square)](./LICENSE) [![uFawkes Family](https://img.shields.io/badge/uFawkes-Family-6F42C1?style=flat-square)](https://github.com/paruff/uFawkesAI) > [![Works with Copilot](https://img.shields.io/badge/Works%20with-Copilot-24292F?style=flat-square)](https://docs.github.com/en/copilot/how-tos/custom-instructions/adding-custom-instructions-for-github-copilot) [![Works with Claude Code](https://img.shields.io/badge/Works%20with-Claude%20Code-D97706?style=flat-square)](https://docs.anthropic.com/en/docs/claude-code) [![Works with Cursor](https://img.shields.io/badge/Works%20with-Cursor-1F6FEB?style=flat-square)](https://docs.cursor.com/context/rules-for-ai) > [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/paruff/uFawkesAI)

## The problem

AI agents start every session blank. They do not know your conventions, architecture, or the research-backed practices that improve delivery performance. This template fixes both problems simultaneously.

## What you get

- `AGENTS.md` — universal agent instruction file, auto-loaded by Copilot, Claude Code, Cursor, Codex, Gemini CLI, Windsurf, and Devin
- `CLAUDE.md` symlink — so Claude Code gets the same instructions without a separate file
- `.github/copilot-instructions.md` symlink — Copilot's preferred path
- `.agents/agents/` — 14 agent profiles: 7 core pipeline agents (spec, design, build, test, test-execution, review, cross-validation) + 7 flow/meta agents
- `.github/instructions/` — scoped instruction files for feature and test work
- `docs/PROMPT_LIBRARY.md` — tested prompts for every repeating task, versioned
- `docs/GOLDEN_PATH.md` — 10-step idea→deploy workflow
- `docs/TEAM_ARCHETYPE.md` — DORA 2025 seven team archetype self-assessment
- CI workflow with PR size blocking (400 lines), doc freshness monitoring
- `scripts/weekly-metrics.sh` — rework rate, PR revision rate, CI cycle time in one view

## GitHub Copilot users: built for the token billing model

GitHub Copilot moved to token-based billing on June 1, 2026.
This template is pre-optimized for that cost model — the pieces below are
GitHub Copilot-specific; every other agent (Claude Code, Cursor, Codex, etc.)
gets its cost/mode guidance from `docs/MODEL_ROUTING_GUIDE.md` instead.

| File                          | What it saves                                        |
| ----------------------------- | ---------------------------------------------------- |
| `AGENTS.md` (135 lines)       | Lean, always-on context vs. typical 226-line files   |
| `.agents/skills/`              | On-demand only — zero cost until referenced          |
| `.copilotignore`              | Excludes lock files, build artifacts, generated code |
| `scripts/token-audit.sh`      | Shows your token footprint before the bill arrives   |
| `docs/MODEL_ROUTING_GUIDE.md` | Which mode and model saves the most                  |

Run `npm run token-audit` after setup to see your baseline.

## Learn → Build

The Fawkes Dojo is the learning layer behind this repo. Use it before implementing a feature or workflow change so the agent can connect the task to the right DORA capability and module.

```text
Dojo module → repo template → production workflow
```

- Learn the relevant practice in the Dojo
- Apply the pattern in the repo’s agent guidance and templates
- Ship the change through the same workflow the team already uses

The Dojo map lives in [`docs/DOJO_MAP.md`](./docs/DOJO_MAP.md), and the agent skill for this flow is `.agents/skills/dojo-navigator/SKILL.md`.

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

Or invest 8 hours and go deep → [docs/DOJO_LEARNING_PATH.md](./docs/DOJO_LEARNING_PATH.md)

## Writing your first agent-ready issue

Use the **Feature — Assign to Agent** issue template (`.github/ISSUE_TEMPLATE/feature.yml`). Here is an example of a well-formed feature issue that Copilot can implement immediately:

---

**Title:** `[FEAT] Add weekly rework rate summary to docs/METRICS.md`

**User Story:**

> As a team lead, I want to run `npm run metrics` and see my rework rate for the past 14 days, so that I know immediately whether AI output quality is improving or degrading.

**Acceptance Criteria:**

- [ ] AC1: `npm run metrics` outputs a rework rate percentage calculated from the last 14 days of git history
- [ ] AC2: The output is appended as a dated snapshot block in `docs/METRICS.md`
- [ ] AC3: If rework rate exceeds 20%, the script prints a warning: `⚠ Rework rate > 20% — stop features, fix AGENTS.md first`

**DORA AI Capability:** Rework rate / DORA metrics

**Context Files to Read:**

- `scripts/weekly-metrics.sh` — existing metrics script to extend
- `docs/METRICS.md` — target file for snapshot output
- `AGENTS.md` §9 — rework rate definition and target thresholds

**Constraints and Out of Scope:**

- Do not modify existing `scripts/setup.sh`
- Do not add new npm dependencies

**Definition of Done:**

- [ ] All acceptance criteria met
- [ ] Failing tests written before implementation
- [ ] `npm run preflight` passes
- [ ] AI-Assisted Review Block completed in PR

**Assign to:** Copilot ✓

---

> **What makes this issue agent-ready?**
>
> - Acceptance criteria are testable (each maps to a specific assertion)
> - Context files are listed so the agent reads the right code first
> - Out-of-scope constraints are explicit (preventing unwanted changes)
> - The Definition of Done gives the agent a self-check before opening the PR

## DORA AI Capabilities implemented

| DORA AI Capability               | File(s) in this template                              |
| -------------------------------- | ----------------------------------------------------- |
| Clear and communicated AI stance | [`AI_STANCE.md`](AI_STANCE.md), `AGENTS.md` §1          |
| Healthy data ecosystems          | `docs/CHANGE_IMPACT_MAP.md`, `docs/API_SURFACE.md`    |
| AI-accessible internal data      | `AGENTS.md` §3 context index, `.vscode/settings.json` |
| Strong version control practices | CI PR size block, conventional commits standard       |
| Working in small batches         | 400-line PR limit, TDD requirement, feature flags     |
| User-centric focus               | `docs/GOLDEN_PATH.md`, `docs/VALUE_STREAM_MAP.md`     |
| Quality internal platforms       | `docs/GOLDEN_PATH.md`, agent specialist profiles      |

## Container images

Built and signed by [`build-devsecops-images.yml`](.github/workflows/build-devsecops-images.yml) on every `image-v<semver>` tag (also shown under **Packages** in the repo sidebar):

| Image | Use |
| --- | --- |
| [`ghcr.io/paruff/ufawkesai-devcontainer`](https://github.com/paruff/uFawkesAI/pkgs/container/ufawkesai-devcontainer) | Shared devcontainer for the uFawkes suite and fawkes: Claude Code, OpenCode, Codex, Gemini CLI, LSP (TS/JS, Python, Bash, YAML), qmd. Tag `polyglot` adds Java |
| [`ghcr.io/paruff/ufawkes-devsecops-ai`](https://github.com/paruff/uFawkesAI/pkgs/container/ufawkes-devsecops-ai) | Base of the devcontainer: core + agent harnesses and skills |
| [`ghcr.io/paruff/ufawkes-devsecops-core`](https://github.com/paruff/uFawkesAI/pkgs/container/ufawkes-devsecops-core) | Linters, secret/vuln/SAST scanners, pre-commit |

Tags: `X.Y.Z`, `X.Y`, `X`, `latest`. Pin by digest in consumers; verify with `cosign verify` (see the workflow header).

## Works with

- GitHub Copilot (native AGENTS.md support since Aug 2025 — server-side auto-load)
- Claude Code (reads AGENTS.md as fallback; CLAUDE.md symlink for direct load)
- Cursor (root AGENTS.md auto-detected; .cursor/rules/ for scoped instructions)
- OpenAI Codex (AGENTS.md is the native format)
- Gemini CLI (configure via .gemini/settings.json)
- Windsurf, Devin, Aider — via AGENTS.md

## Part of the uFawkes family

uFawkesAI is the AI plane in the uFawkes stack family: it sets policy, context, guardrails, and workflows so every other stack can move faster with less rework.

Integration entry point: [`docs/UFAWKES_INTEGRATION.md`](./docs/UFAWKES_INTEGRATION.md)

| Stack                    | Role                                                      | Link                                                                 |
| ------------------------- | ----------------------------------------------------------- | ----------------------------------------------------------------------- |
| uFawkesAI                | AI plane (agent policy, context, controls)                 | [paruff/uFawkesAI](https://github.com/paruff/uFawkesAI)             |
| uFawkesPipe              | CI/CD and delivery pipeline plane                           | [paruff/uFawkesPipe](https://github.com/paruff/uFawkesPipe)         |
| uFawkesObs               | Observability and reliability plane                         | [paruff/uFawkesObs](https://github.com/paruff/uFawkesObs)           |
| uFawkesDORA              | Delivery metrics and engineering effectiveness plane        | [uFawkesDORA (planned)](https://github.com/paruff/uFawkesAI/issues) |
| uFawkesApp / uFawkesData | Product and data plane pair (implementation + analytics)   | [planned](https://github.com/paruff/uFawkesAI/issues)               |

**Product Suite Roadmap**: [fawkes/ROADMAP.md](https://github.com/paruff/fawkes/blob/main/ROADMAP.md)

Quick integration hooks:

- **uFawkesObs:** set `OTEL_EXPORTER_OTLP_ENDPOINT` and `OTEL_SERVICE_NAME` in the instrumented runtime/service that uses this template; this repository does not emit OTEL spans by itself.
- **uFawkesDORA:** `npm run metrics` currently summarizes local git/coverage signals; `GITHUB_TOKEN`, `GITHUB_OWNER`, and `GITHUB_REPO` are for external/future GitHub API-backed DORA collectors.
- **uFawkesPipe:** run the Golden Path (`docs/GOLDEN_PATH.md`) so AI-authored PRs flow through the `deliveryd` CI contract (uFawkesPipe pipeline contract: [paruff/uFawkesPipe](https://github.com/paruff/uFawkesPipe)).

## Rework rate

> DORA 2025 added rework rate as a new core metric. It is the earliest signal that
> AI output quality is degrading. This template's `scripts/weekly-metrics.sh` calculates
> it from your git history. Target: < 10%. Above 20%: stop features, fix AGENTS.md first.

## Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) (planned in AI-006).

## License

MIT
