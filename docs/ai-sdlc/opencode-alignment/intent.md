# Intent: Align opencode configuration with the AI-native SDLC and the DORA AI Capabilities

**Owner:** @paruff | **Created:** 2026-09-28 | **Status:** Draft (review only; no config changed)
**Chain:** `intent.md` → [`spec.md`](spec.md) → `plan.md` (written by whoever executes this)

## Problem

The suite's agent tooling has drifted into several incompatible shapes:

- **Six different agent rosters.**
  - uFawkesAI, the template, just moved to a 4-agent taxonomy: `planner`, `builder`,
    `verifier`, `operator`.
  - uFawkesObs carries 12 domain agents plus 3 `.claude` agents and its own hooks.
  - uFawkesPipe has 8 `*-agent` definitions.
  - uFawkes.dev has 7 agents plus a `gitops` agent.
  - uFawkesDevX has only 5 skills, and uFawkesDojo has nothing.
- **The same agents are defined in more than one place:** `.agents/agents/`,
  `.opencode/agents/`, and `.claude/agents/`.
- **Model routing doesn't match how work is triaged.**
  - The global default, `build`, `general`, and `explore` all use
    `opencode/mimo-v2.6-flash-free`.
  - The `@fast`, `@medium`, and `@heavy` tiers all use Gemini, and `@heavy` uses the
    same model as `@medium`.
  - Nemotron 3 Ultra is available free but routed nowhere.
  - The CI `opencode.yml` ignores the `model:*` labels now used to triage Project #7.
- **Enforcement may be weaker than it looks.** The template's `ai-sdlc-hooks.ts` appears
  to use Claude Code's settings shape rather than opencode's plugin API. Its formatter
  step runs `black`, which was rejected and uninstalled on 2026-09-27, and `npx -y
  prettier`, which is unpinned.
- **The global `AGENTS.md`, injected into every opencode session, is an empty Claude-Mem
  placeholder.**

## Goal

One coherent setup, owned by the uFawkesAI template and inherited by every suite repo.
It should be cheap to run on MiMo v2.6 Flash and Nemotron 3 Ultra, and follow Anthropic's
published practices for agentic development and the 7 DORA AI capabilities.

## Decisions already made (by @paruff)

- **Python formatting and linting:** `ruff format` and `ruff check`. No black, flake8, or
  isort.
- **Delegated work** runs on MiMo v2.6 Flash (mechanical) or Nemotron 3 Ultra (needs
  judgment). Project #7 already triages issues with `model:mimo-v2.6-flash` and
  `model:nemotron-3-ultra` labels.
- **Planning follows the artifact chain** `intent.md` → `spec.md` (requirements and
  design) → `plan.md`, which uFawkesAI's CI enforces.
- **Merges are human-gated.** Agents open PRs; they don't merge.

## Open questions

1. **Where is the canonical global config?** `~/.config/opencode/opencode.jsonc` says it
   is a synced copy of `<repo>/opencode/`, installed by `sync.sh`, but that folder isn't
   in uFawkesAI. Which repo owns it?
2. **Should per-repo domain agents become skills?** For example uFawkesObs's `promql`,
   `dashboard`, `otel-collector`, and `alloy-river`, and uFawkesPipe's `buildpack-agent`
   and `pipeline-library-agent`. Under the 4-agent taxonomy, the proposal is that the
   `builder` and `verifier` agents load them as skills.
3. **Should CI `opencode.yml` pick its model from the issue's `model:*` label?**
