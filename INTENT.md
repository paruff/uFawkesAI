# INTENT — Read This Before Touching Anything

**uFawkesAI** is a GitHub template that makes an AI coding agent work the way
DORA research says high-performing teams work. A new repo created from it
gets:

- one `AGENTS.md` that Claude Code, Copilot, Cursor, Codex and Gemini CLI all
  load (with `CLAUDE.md` and the Copilot path as symlinks);
- agent profiles for each pipeline stage, in `.agents/agents/`;
- a devcontainer (the "CDE") with the agent tooling installed;
- a documented idea-to-deploy path, a prompt library, and CI guardrails
  (PR size limit, doc-freshness checks).

## The one thing to know

**`v1.0.0` (2026-06-04) is usable today. `v2.0.0` is not released.** Three
things stop it from being a template you can trust from a clean start:

- **The devcontainer image can't be pinned.** The publish path is broken, so
  there's no `:2.0.0` tag to point at (#111, AC-AI-01).
- **The "Use this template" flow hasn't been run end to end** on a fresh repo
  in the new image (AC-AI-02).
- **Nothing finds unfilled placeholders** in a repo made from the template
  (#28).

The README and the site describe v1.0.0 as it works today. If a claim isn't
in the image or the template tree, it doesn't belong in the README (AC-AI-04).

## Where this sits in the suite

| Role                                               | Repo                                 |
| -------------------------------------------------- | ------------------------------------ |
| AI-SDLC template and devcontainer image            | **uFawkesAI** (this repo)            |
| Observability, CI/CD, developer experience         | uFawkesObs, uFawkesPipe, uFawkesDevX |
| Learning (the "Start here" lab uses this template) | uFawkesDojo                          |
| Kubernetes graduation track                        | fawkes                               |

Every other suite repo inherits this one's conventions (the `intent → spec →
plan` chain, pre-commit and Pre-flight checks) and pins its devcontainer
image (AC-AI-05). A change here reaches all seven repos, so check how it
syncs before you change a shared workflow.

The suite release plan is at
[uFawkes.dev `docs/ai-sdlc/suite-release/`](https://github.com/paruff/uFawkes.dev/tree/main/docs/ai-sdlc/suite-release).
This repo's release, `v2.0.0`, is Phase 1 of that plan. It's gated on
AC-AI-01 to AC-AI-09.

## What "done" means here

- **`v2.0.0` ships when its acceptance criteria pass,** each with real
  evidence (a transcript or CI log), not a described run.
- **Planning follows the `intent → spec → plan` chain:**
  `docs/ai-sdlc/<feature-or-release>/intent.md` → `spec.md` → `plan.md`. The
  release folder `docs/ai-sdlc/v2.0.0/` is written before the tag. The
  root-level v1 `intent.md`, `spec.md` and `plan.md` in `docs/ai-sdlc/` move
  into their own feature folder.
- **A template step is described only after it has been run** from a repo
  created from the template.
- **Work goes through PRs,** with tests and evals both gating merges
  (AC-AI-07).

## Explicit non-goals

- **Sample application code.** The product being templated is the SDLC
  tooling, not a business app.
- **Other languages' tooling.** The Node/TypeScript tooling stays as it is.
  Other golden-path repos copy the _pattern_ (how agents, skills, hooks and
  rules fit together), not these npm commands.
- **Running agents for you.** This repo configures agents. It doesn't host
  or schedule them.
- **Unbuilt capability claims.** If the README names a DORA capability, the
  file that provides it is named beside it.
