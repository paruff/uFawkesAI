---
change: seam-verification-stack
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-23
issue: 360
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: Seam verification stack (R9)

## Problem

The seam's R9 verification table is not live: no CI job runs Stryker, the SAST job lacks the `p/typescript` and `p/secrets` rulesets, and the verifier's steps do not name the two-layer checklist.

## Proposed outcome

Semgrep (`p/ci`, `p/typescript`, `p/secrets`) and Stryker on `scripts/seam/` run in CI and block, and the verifier follows verification-before-completion, requesting-code-review and `/code-review`, then green CI, before handing off.

## Affected users and systems

Maintainers and the `@verifier` agent; `agent-ci.yml`, `ci-quality.yml`, `.agents/agents/verifier.md`, `REVIEW.md`, `AI_STANCE.md`.

## Constraints

Pinned tool versions, actions pinned by SHA, `AI_STANCE.md` updated in the same PR (ai-policy rule), nothing installed on the host.

## How we know it worked

Both CI jobs run on a PR; Stryker meets its break threshold; the new eval task passes.

## Out of scope

Raising the `morsadev.ts` mutation score; downstream repos (phase 6); turning the engine's subagent prompts into skills.

## Open questions

Whether `seam-mutation` and `sdlc-seam ci` are required checks on `main` (a settings change for the owner).
