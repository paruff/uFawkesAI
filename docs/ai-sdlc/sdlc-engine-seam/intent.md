# Intent — An SDLC engine seam for uFawkesAI

## Problem Statement

AI-native SDLC tooling changes every few weeks: new loop frameworks, new
gate engines, new harness features. uFawkesAI currently owns its whole
process layer by hand:

- the four agents (`.agents/agents/{planner,builder,verifier,operator}.md`)
  and the nine commands in `.agents/commands/`;
- the artifact-chain check (`scripts/check-artifact-chain.sh`, reusable
  workflow `.github/workflows/artifact-chain.yml`);
- the OpenCode gate plugin (`.opencode/plugins/ai-sdlc-hooks.ts`);
- human gates that live only as Project #7 board statuses.

Each new idea in the field means rewriting part of that layer. The Fawkes
IDP knowledge (planes, K8s, observability, Woodpecker, security) is the part
that is uniquely ours; the loop machinery is not.

## Desired Outcome

uFawkesAI stops maintaining a process framework and maintains a **seam**
instead: a small, engine-neutral contract (stages, artifacts, gate state,
approver identity, one CI check). An off-the-shelf engine plugs in behind
it. The first engine is `@morsadev/sdlc` (Apache-2.0, v1.4.0). Replacing
that engine later means writing one adapter and passing one conformance
suite, without touching agents, skills, or CI callers.

On top of the seam:

- **Superpowers** carries TDD (`test-driven-development`) and review
  (`requesting-code-review`, `verification-before-completion`) inside the
  build and ship stages in both Claude Code and OpenCode.
- **A verification stack** combines agent-side skills with deterministic
  gates (pre-commit, CI, static analysis, mutation testing).

## Users

- **Primary:** the repo owner, working solo in Claude Code and OpenCode.
- **Secondary (later phase):** the downstream uFawkes* repos that consume
  `artifact-chain.yml` and copy this template's pattern.

## Why now

`@morsadev/sdlc` already ships the loop, gates, approvals-as-commits, CI
templates and a dashboard. Adopting it behind a seam is cheaper than
writing the rest of the process layer ourselves, and the seam keeps the
1.x, single-maintainer dependency replaceable.

## Success looks like

1. One change completes intent → spec → plan → build → ship in OpenCode
   **and** in Claude Code. The gate verdicts are the same in both, and
   approvals are commits by a human.
2. A `--no-verify` push of unapproved work is still red in CI.
3. No hand-written loop skill or gate script remains that duplicates the
   engine.
4. A second, fake engine passes the same conformance suite, which proves
   the seam is real.

## Non-goals

- Migrating downstream uFawkes* repos (that is the last phase, not v1).
- Moving historical `docs/ai-sdlc/` chains to the new layout.
- Writing new Fawkes IDP skills (k8s, observability, Woodpecker); that is a
  separate initiative once the seam exists.

## Anti-goals

- Two sources of truth for gate state (engine and board disagreeing).
- A second gate engine hidden in an OpenCode plugin or a hook.
- Agents or skills that call `sdlc` directly instead of going through the
  seam.
