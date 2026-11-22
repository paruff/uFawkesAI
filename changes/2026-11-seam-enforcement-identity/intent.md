---
change: seam-enforcement-identity
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-22
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-22
approved_sha: b7e1235
---
# Intent: Seam phase 2: enforcement and agent identity

## Problem
Nothing stops a commit or push of code whose plan is unapproved, in git, Claude Code or OpenCode, and a `--no-verify` push gets through CI. Agent commits are indistinguishable from the human's, so the engine cannot refuse a bot approval.

## Proposed outcome
A commit or push touching code paths is blocked until the change's plan is approved, in all three places. A `--no-verify` push is red in CI. Agent sessions commit as one bot identity that can never approve.

## Affected users and systems
Maintainers, agent sessions (Claude Code, OpenCode), pre-commit, `artifact-chain.yml`, downstream repos (they stay on their v2.x ref).

## Constraints
Spec R6 and R6a in `docs/ai-sdlc/sdlc-engine-seam/spec.md`. No gate logic outside `scripts/sdlc-seam`. No tokens in files.

## How we know it worked
Scripts `test-sdlc-seam-hooks.sh`, `test-harness-identity.sh` and `test-commit-matcher.sh` pass. A throwaway PR pushed with `--no-verify` has a red `CI Complete`.

## Out of scope
Commit signing; retiring the old loop (phase 3); the board mirror (phase 4).

## Open questions
- None.
