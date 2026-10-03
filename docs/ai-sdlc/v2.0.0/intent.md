# Intent — uFawkesAI v2.0.0

Status: ACCEPTED (originator: repo owner, 2026-10-01; image name 2026-10-03)
Traces to: [uFawkes Suite Release, Phase 1](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/suite-release/plan.md) · goal #145

## Problem

Every uFawkes repo builds on this template and its devcontainer, but none of
them can pin it:

- The signed image publish path has never run for a tag (#111). Suite repos
  use `:latest`.
- 1.x consumers have no written contract: they can't tell which changes
  break them. Two already did: the npm package rename (#124) and the removed
  gitops image variant (#125).
- Some README claims are not checked against what ships (uFawkesObs
  integration, eval gating).

## Desired Outcome

A `v2.0.0` tag that a suite repo can pin, with a written contract saying
what semver covers, an upgrade note from 1.x, and every capability claim
backed by a file, a tool in the image, or a verified run.

## Decisions Already Made

- **Major version.** The npm rename and the gitops-variant removal break
  1.x consumers, so this is `2.0.0`.
- **Contract (suite intent, Release decisions #1).** Semver covers the
  devcontainer image name and tags, the `docs/ai-sdlc/<feature>/` layout and
  file names, and the npm package name. Agent prompt text, default model
  routing and skill internals are not covered.
- **Image name: `ghcr.io/paruff/fawkes-space`** (owner, 2026-10-03). It
  replaces `ufawkesai-devcontainer` and `fawkes-space-devcontainer`. Neither
  was ever publicly pullable, so the rename breaks no consumer.
- **Gate-driven, not date-driven.** If this release slips more than two
  weeks, uFawkesObs ships first.
- **A claim that can't be verified by the tag is removed**, not rushed in.

## Out of Scope

- New template features. 2.0 ships what exists.
- Stage 5 review (`REVIEW.md`, agent PR review, #158) and the live
  "Use this template" workflow (#160): later releases.
- Pinning the other suite repos (AC-AI-05): lands within a week after the
  tag and doesn't block it.
