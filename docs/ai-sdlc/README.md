# AI SDLC Artifact Chain

This directory is the feature audit trail:

`intent.md` → `spec.md` → `plan.md` → code

Each artifact is versioned and should be committed in a PR (or attached to the feature branch) as it is produced.

- `intent.md`: originator idea and discovery context
- `spec.md`: requirements, design, policy constraints, and concerns
- `plan.md`: executable implementation sequence and verification strategy

Each feature gets its own directory: `docs/ai-sdlc/<feature>/intent.md`,
`spec.md`, `plan.md`. The chain is carried by two agents and their skills:
`@planner` reads `intent.md`, loads the `discover`, `spec`, `design`, and
`plan` skills, and writes `spec.md` and `plan.md`; `@builder` reads `plan.md`,
loads `build` and `test`, and writes the code diff. `@verifier` then checks the
diff against those artifacts, and `@operator` ships it.

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
