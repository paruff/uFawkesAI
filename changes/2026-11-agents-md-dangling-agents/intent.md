---
change: agents-md-dangling-agents
status: draft            # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-27
approved_by:             # who accepted the intent (filled in by the PO or recorded on acceptance)
---
# Intent: AGENTS.md: stop naming agents the repo deletes

## Problem

`AGENTS.md` (the file every harness loads) ends the engine-managed block with: "For clean-context reviews (verifier, spec-reviewer, simplifier, researcher), use `.agents/agents/<name>.md`." The repo allows four agents (`scripts/check-agents.sh`) and `scripts/seam/setup.sh` deletes the engine's `researcher`, `simplifier` and `spec-reviewer` files after every `sdlc sync`, so three of the four named files never exist. An agent following the instruction looks for files that are not there. The sentence is hard-coded in `@morsadev/sdlc` 1.4.0 (no config option), and a hand edit of the block fails the drift check (`check-sdlc-block-drift.sh`, spec R4.1) and is reverted by the next sync.

## Proposed outcome

The block says "For a clean-context review, use `.agents/agents/verifier.md`." (the one existing file that does this), kept that way through `sdlc sync`, and the drift check still catches any other edit inside the block.

## Affected users and systems

Every agent session in this repo and every harness that loads `AGENTS.md`; `scripts/seam/setup.sh`, `scripts/check-sdlc-block-drift.sh`, `scripts/test-sdlc-block-drift.sh`, and the sentence in `AGENTS.md`.

## Constraints

`AGENTS.md` changes need owner approval (hard rule 3): the owner approves this intent, spec and plan, and the one-sentence diff to `AGENTS.md` in the PR. Do not edit the engine in `node_modules`. The change must survive `sdlc sync` and keep the drift check meaningful.

## How we know it worked

`bash scripts/check-sdlc-block-drift.sh` passes on the new `AGENTS.md`; `scripts/seam/setup.sh` leaves it unchanged; the drift self-test still fails on an edit elsewhere in the block.

## Out of scope

Fixing the sentence upstream in `martinisef/ai_sdlc` (worth an issue, separate); the mention of the engine's `spec-reviewer` subagent in `.agents/agents/verifier.md`, which refers to the engine's own subagents, not files; the Spanish locale string.

## Open questions

- Is the owner happy with a post-sync rewrite of an engine-managed sentence (a small, documented divergence from the engine), versus leaving the sentence and accepting the dangling reference?
