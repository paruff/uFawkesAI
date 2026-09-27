# AI SDLC Artifact Chain

This directory is the feature audit trail:

`intent.md` → `spec.md` → `plan.md` → code

Each artifact is versioned and should be committed in a PR (or attached to the feature branch) as it is produced.

- `intent.md`: originator idea and discovery context
- `spec.md`: requirements, design, policy constraints, and concerns
- `plan.md`: executable implementation sequence and verification strategy

Each feature gets its own directory: `docs/ai-sdlc/<feature>/intent.md`,
`spec.md`, `plan.md`. The agents hand off along the chain: `@spec` reads
`intent.md` and writes `spec.md`; `@design` reads `spec.md` and writes
`plan.md`; `@build` reads `plan.md` and writes the code diff.

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
