# INTENT — Read This Before Touching Anything

**uFawkesAI** is a GitHub template and a signed devcontainer image
(`fawkes-space`) that make an AI coding agent follow the
[AI-Native SDLC Playbook](https://claude.com/blog/the-ai-native-sdlc-playbook):
six stages, each ending in a committed artifact a human reviews.

Its users are developers starting a repo who want agents to work in small,
reviewed, traceable steps instead of ad-hoc prompting, and the other uFawkes
repos, which are built from it.

> Made a repo from this template? This file describes uFawkesAI. Replace it
> with your own project's intent.

## The one thing to know

**The template is the product, not the code in it.** A change here reaches
every repo built from it and every repo that pins the `fawkes-space` image, so
a template step is described only after it has been run from a fresh repo
created with "Use this template".

## Where this sits in the suite

| Role                                       | Repo                                 |
| ------------------------------------------ | ------------------------------------ |
| AI-SDLC template and devcontainer image    | **uFawkesAI** (this repo)            |
| Observability, CI/CD, developer experience | uFawkesObs, uFawkesPipe, uFawkesDevX |
| Learning                                   | uFawkesDojo                          |
| Kubernetes graduation track                | fawkes                               |

The other suite repos inherit its conventions (the `intent → spec → plan`
chain, pre-commit and Pre-flight checks) and pin its image by digest. Release
order, acceptance criteria and status live in the
[suite release plan](https://github.com/paruff/uFawkes.dev/tree/main/docs/ai-sdlc/suite-release)
and on [Project #7](https://github.com/users/paruff/projects/7), not here.

## What "done" means here

- **A release is verified when its acceptance criteria pass** with real
  evidence (a transcript or CI log), not a described run. Every release tag
  publishes a signed `fawkes-space:<version>` image.
- **Planning follows the `intent → spec → plan` chain** in
  `docs/ai-sdlc/<feature-or-release>/`.
- **The four agent tools stay equal:** Claude Code, OpenCode, Codex and Gemini
  CLI load the same `AGENTS.md`.
- **Work goes through PRs,** with tests and agent evals gating merges, and a
  human merges.

## Explicit non-goals

- **Sample application code.** The product being templated is the SDLC
  tooling, not a business app.
- **Other languages' tooling.** Other repos copy the pattern (how agents,
  skills, hooks and rules fit together), not these npm commands.
- **Running agents for you.** This repo configures agents. It doesn't host or
  schedule them.
- **Unbuilt capability claims.** If the README names a capability, the file
  that provides it is named beside it.
