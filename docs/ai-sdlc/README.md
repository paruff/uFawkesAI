# AI SDLC Artifact Chain

This directory is the feature audit trail:

`intent.md` → `spec.md` → `plan.md` → code

Each artifact is versioned and should be committed in a PR (or attached to the feature branch) as it is produced.

- `intent.md`: originator idea and discovery context
- `spec.md`: requirements, design, policy constraints, and concerns
- `plan.md`: executable implementation sequence and verification strategy

Each feature gets its own directory: `docs/ai-sdlc/<feature>/intent.md`,
`spec.md`, `plan.md`. The chain is carried by the four agents and the
Superpowers skills for each stage: `@planner` reads `intent.md`, loads
`brainstorming` (spec and design) and `writing-plans`, and writes `spec.md`
and `plan.md`; `@builder` reads `plan.md`, loads `executing-plans` and
`test-driven-development`, and writes the code diff. `@verifier` then checks
the diff against those artifacts (`verification-before-completion`,
`requesting-code-review`), and `@operator` ships it. The repo skills
`discovery` (before `intent.md`) and `learn` (after release) bracket the chain.

A feature need not have its own `plan.md`: the checker only requires an
`intent.md` beside every `spec.md`, and a `plan.md` when a PR changes `src/`.
`opencode-alignment/` is implemented by the repo-level [`plan.md`](plan.md),
which cites that spec's requirements (R1–R8). `dora-events-portability/` has an
intent, spec and plan; its code is not built yet.

## Closing the loop — Dojo

A completed chain becomes a uFawkesDojo lab, and the lab's findings become
the next `intent.md` within one sprint: see [`dojo-handoff.md`](dojo-handoff.md)
(`dojo-feedback` skill → `dojo-feedback.md` → `intent` issue).

## Enforced in CI

`.github/workflows/artifact-chain.yml` runs `scripts/check-artifact-chain.sh`
on every PR. Through the CI Quality Gate it feeds `✅ CI Complete`, the check
`main` requires, so a violation blocks the merge:

1. A PR that changes `src/` must include, **in its own diff**, a
   `docs/ai-sdlc/**/plan.md` with a `## Verification Strategy` heading.
2. Every `docs/ai-sdlc/**/spec.md` must have a sibling `intent.md` in the
   branch history.

Run it locally with `scripts/check-artifact-chain.sh origin/main`;
`scripts/test-artifact-chain.sh` exercises both rules against throwaway repos.
