# Spec: Align opencode configuration with the AI-native SDLC and the DORA AI Capabilities

**Traces to:** [`intent.md`](intent.md) | **Status:** Draft | **Revision:** 1

## Yardsticks

**Anthropic's published guidance on agentic development**, cited by title:

| # | Practice | Source |
|---|---|---|
| A1 | Explore → plan → code → verify → commit. Give the agent a way to check its own work: tests, CI, a real run | *Claude Code best practices* |
| A2 | Keep always-loaded context small; load the rest on demand (skills), just in time | *Effective context engineering for AI agents* |
| A3 | Start with the simplest workflow that works, and add agents only when they earn it (orchestrator-workers, evaluator-optimizer) | *Building effective agents* |
| A4 | Rules that must always hold go in deterministic hooks, not in prompt instructions | *Claude Code best practices* (hooks) |
| A5 | Few, well-scoped tools and skills, each with a description that says *when* to use it | *Writing effective tools for agents* |

**The 7 DORA AI capabilities** (DORA 2025): D1 clear and communicated AI stance · D2 healthy
data ecosystems · D3 AI-accessible internal data · D4 strong version control practices ·
D5 working in small batches · D6 user-centric focus · D7 quality internal platforms.

## Findings

Evidence was gathered on 2026-09-28 from `~/.config/opencode/`, the `main` trees of the
suite repos, and uFawkesAI `main`. F5 and F6 were confirmed against uFawkesAI `main` and
opencode's own log.

| ID | Finding | Evidence | Breaks | Severity |
|---|---|---|---|---|
| F1 | Six incompatible agent rosters | uFawkesAI: 4 agents (+3 reviewers in `.opencode`). Obs: 12 + 3 `.claude`. Pipe: 8. uFawkes.dev: 7 + `gitops`. DevX: skills only. Dojo: none | A3, D7 | High |
| F2 | The same agent defined in up to three places | `.agents/agents/`, `.opencode/agents/`, `.claude/agents/` (uFawkesAI, Obs, uFawkes.dev) | A2, D4 | High |
| F3 | Global `AGENTS.md` (loaded into every session) is an empty Claude-Mem placeholder | `~/.config/opencode/AGENTS.md`: "No context yet" | D1, A2 | Medium |
| F4 | Model routing ignores triage | Default/`build`/`general`/`explore` use MiMo, but `tiers.json` puts all three tiers on Gemini (`@heavy` = `@medium`). `nemotron-3-ultra-free` is defined but routed nowhere. CI `opencode.yml` uses a fixed NIM → Gemini → DeepSeek chain and ignores `model:*` labels | A3, D7 | High |
| F5 | The hook plugin does not load | On `main`, `ai-sdlc-hooks.ts` (lines 48–72) default-exports `{hooks:{PreToolUse:[…], PostToolUse:[…]}}`, which is Claude Code's settings shape. opencode plugins export a function returning handlers such as `tool.execute.before`. opencode 1.18.30's log confirms it: `level=ERROR message="failed to load plugin" path=…/uFawkesAI/.opencode/plugins/ai-sdlc-hooks.ts error="Plugin export is not a function"` (2026-09-26). `opencode debug info` still lists the plugin, so the failure is invisible unless you read the log | A4, D4 | **Critical.** The protected-path and secret-scan gates are silent no-ops |
| F6 | The formatter hook is non-deterministic and contradicts a decision | On `main`, lines 11–13: `black` for `.py` (rejected, and uninstalled so it would fail), `npx -y prettier` for `.ts`/`.js` (unpinned). Moot until F5 is fixed, then live | A4, D4 | High |
| F7 | Skill sprawl with name collisions | 122 skills in uFawkesAI, 31 global, more per repo. Names overlap: `build`, `design`, `plan`, `spec`, `test`, `test-execution`, `review`, `verification` | A2, A5 | Medium |
| F8 | CI can't run the triaged models, and fires too easily | No MiMo in `opencode.yml`. The `opencode` label triggers a run immediately. The NIM proxy was already removed locally as unreliable (a ~58% timeout rate, per `opencode.jsonc`) but is still primary in CI | D5, D7 | Medium |
| F9 | "Done" is claimed without evidence on the default branch | 2026-09-27: follow-up commits were pushed to already-merged PRs, stranded, and reported as fixed | A1, D4, D5 | High |

## Requirements

- **R1 — One roster.** Every suite repo uses the template's four agents: `planner`,
  `builder`, `verifier`, `operator`. Repo-specific expertise (Obs `promql`, `dashboard`,
  `otel-collector`, `alloy-river`; Pipe `buildpack`, `pipeline-library`) becomes a **skill**
  that those agents load, not another agent. (F1, A3)
- **R2 — One source per definition.** Agents and skills live in `.agents/`. The
  opencode and Claude copies are generated or symlinked by uFawkesAI's setup script,
  which already symlinks `AGENTS.md` → `CLAUDE.md`. CI fails if a generated copy
  drifts. (F2, D4)
- **R3 — A real global stance.** Replace the global `AGENTS.md` with a stance of 40
  lines or fewer (D1):
  - verify against the default branch before saying "done";
  - small batches, one PR per change;
  - agents never merge;
  - follow the artifact chain;
  - use `ruff`;
  - read the repo's `INTENT.md` first.
- **R4 — Routing follows triage.** (F4, F8)
  - `model:mimo-v2.6-flash` routes to `opencode/mimo-v2.6-flash-free`, the mechanical
    tier and the default.
  - `model:nemotron-3-ultra` routes to `opencode/nemotron-3-ultra-free`, the reasoning
    tier.
  - Gemini stays as the **fallback**.
  - `@heavy` either gets a genuinely stronger model or is removed.
  - CI `opencode.yml` reads the issue's `model:*` label and puts the free `opencode`
    provider ahead of NIM.
- **R5 — Hooks that demonstrably run.** Rewrite `ai-sdlc-hooks.ts` against opencode's
  plugin API (a function returning `tool.execute.before` / `tool.execute.after`).
  Formatters become `ruff format` and a **pinned** prettier from `package.json`.
  (F5, F6, A4)
- **R6 — Lean skills.**
  - Dedupe names across global, template and repo skills.
  - Global keeps only cross-project skills; the template owns SDLC skills.
  - Every skill description states its trigger (the uFawkesObs #505 pattern).

  (F7, A2, A5)
- **R7 — Deliberate CI trigger.** CI runs only when an issue has **both**
  `ready-for-dev` and a `model:*` label, or on a maintainer's `/oc` comment. (F8, D5)
- **R8 — The verifier checks the default branch.** The `verifier` agent's definition of
  done: the PR is merged **and** the change is present on `main` (content check) **and**
  CI on `main` is green. (F9, A1)

## Design

- **Where things live.** The template (uFawkesAI) is the source of truth for agents,
  SDLC skills, hooks, commands and CI workflow. Repos keep only their `INTENT.md`, domain
  skills, and repo-specific hook config (for example uFawkesObs's `config/**` deploy
  guard). Global `~/.config/opencode` keeps model and provider config and cross-project
  skills; it is synced from its canonical repo (open question 1).
- **Commands.** Keep `/plan` and `/ship`; they map onto the chain. `/plan` should write
  `docs/ai-sdlc/<feature>/intent.md` and `spec.md` rather than only brainstorm. Add
  `/verify`, which runs R8's checks. `/oc-health` should also check R2 drift and R5 hook
  loading.
- **Evaluation.** Every hook and gate gets an adversarial test proving it **blocks**.
  uFawkesObs's #489 guardrail eval is the model to follow.

## Acceptance Criteria

- **AC-01:** `opencode debug info` in each repo shows the four agents and the plugin
  loaded, with no load errors.
- **AC-02:** An automated test shows the hook blocks an edit to a protected path and a
  commit containing a planted fake secret.
- **AC-03:** Editing a `.py` file runs `ruff format`, and nothing calls `black`.
- **AC-04:** An issue labeled `model:nemotron-3-ultra` + `ready-for-dev` produces a CI run
  whose log shows `nemotron-3-ultra` as the model.
- **AC-05:** No skill name appears in more than one of global, template and repo;
  every skill description has a trigger clause.
- **AC-06:** Agent definition files exist in exactly one source location per repo; the
  generated copies match, and CI enforces it.
- **AC-07:** The global `AGENTS.md` contains the R3 stance and no placeholder text.

## Suggested order (small batches, each its own PR)

1. **R5, F5/F6 hooks.** Confirmed on uFawkesAI `main`: the gates are no-ops today. This is
   the only critical item.
2. **R3, global stance.** One file, highest leverage per line.
3. **R4 + R7, routing and CI trigger.** This unlocks tomorrow's cheap-model queue.
4. **R2, then R1, per repo.** uFawkes.dev, then Pipe, then Obs (largest), then DevX and
   Dojo.
5. **R6 skills, R8 verifier.**
