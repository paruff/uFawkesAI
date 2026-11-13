# Plan — v2.3.0: releases that publish themselves, and a smaller repo

**Traces to:** [`spec.md`](spec.md) → [`intent.md`](intent.md).
**Status:** Draft for the plan gate. Revised 2026-11-09: cut to the work that
needs no owner decision (the suite readiness review, IR-C1). AWS AI-DLC was
dropped on 2026-11-05 (`docs/ai-sdlc/remove-aidlc/plan.md`).

**Board:** paruff/uFawkesAI#252 is on Project #7. Each step below is one PR.

## Phase 0 — Release Please tags publish the image (AC-230-01)

paruff/uFawkesAI#252: `release-please.yml` creates tags with `GITHUB_TOKEN`
when `RELEASE_PLEASE_TOKEN` is unset, and GitHub starts no workflow for an
event made with `GITHUB_TOKEN`. So `v2.1.0` never got an image.

The fix needs no new secret. `workflow_dispatch` is the one event
`GITHUB_TOKEN` may start, and a dispatch on a tag runs with `github.ref` set to
that tag, so the existing `publish` job works unchanged:

1. In `.github/workflows/release-please.yml`, give the action step an `id`
   and add a step after it:
   `if: steps.<id>.outputs.release_created == 'true'`, running
   `gh workflow run build-cde-space-image.yml --ref "${{ steps.<id>.outputs.tag_name }}"`
   with `GH_TOKEN: ${{ github.token }}`.
2. Add `actions: write` to that job's `permissions`.
3. Keep the `push: tags` trigger in `build-cde-space-image.yml`, so a tag a
   person pushes still publishes.

**Check:** after the next release PR merges, `docker manifest inspect
ghcr.io/paruff/fawkes-space:<that version>` exits 0. Paste it on #252.

## Phase 1 — File diet (AC-230-02, AC-230-03)

Each item is one PR that OpenCode (Nemotron) can do. Recover anything from the
`v2.2.0` tag.

| Change | Files | Check |
| --- | --- | --- |
| Run the missing self-test | add `scripts/test-check-review-md.sh` to `SUITES` in `scripts/run-unit-tests.sh` | the AC-230-02 loop prints nothing; `scripts/run-unit-tests.sh` passes |
| Move the scaffolds out | delete `templates/tests/` (10 files: test scaffolds for other platform repos; no other file links to them) | `git grep -n templates/tests` finds only this plan |
| Drop unlinked docs | under `docs/`, delete each file no tracked file links to | `scripts/check-artifact-chain.sh` and `pre-commit run --all-files` pass |

**Don't touch:** `.claude/` and `.opencode/` (each harness reads its own
directory; the symlinks are already the single source), `images/devsecops/`,
`.devcontainer/`, `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `REVIEW.md`,
`INTENT.md`, and anything under `docs/ai-sdlc/` another doc links to.

## Phase 2 — Release

Merge the Release Please PR for `v2.3.0`. Phase 0 publishes the image; the
`release` agent writes the notes.

**Exit:** `docker manifest inspect ghcr.io/paruff/fawkes-space:2.3.0` exits 0,
`git ls-files | wc -l` is at most 250, and the suite repos' `devcontainer.json`
pins move to `2.3.0@sha256:…` (suite AC-AI-05 accepts that form).

## Verification Strategy

| Criterion | Evidence |
| --- | --- |
| AC-230-01 | `docker manifest inspect` output on paruff/uFawkesAI#252 |
| AC-230-02 | the AC-230-02 loop, empty, in the PR |
| AC-230-03 | `git ls-files \| wc -l` in the release PR |
| Nothing else broke | `scripts/run-unit-tests.sh` and `pre-commit run --all-files` pass on each PR |

### Make commands

Per [the suite's rule for `make` commands](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/suite-release/spec.md#make-verification-commands):

| Command | Proves | Needs |
| --- | --- | --- |
| `make validate` | Every pre-commit hook passes on every file | Nothing |
| `make doctor` | This clone's hooks are installed and its tools are present | Nothing |

`scripts/run-unit-tests.sh` (AC-230-02) has no `make` target yet; run it directly.

## Not in this release

**A Google lifecycle.** Google has published no AI SDLC framework to adopt.
Its terminal agent moved from Gemini CLI to the closed-source Antigravity CLI,
and Gemini CLI stopped serving most individual users on 2026-06-18. When the
owner wants this work, it starts as a `Decision:` issue (what "Google
lifecycle" means here), then gets its own intent. Until then the image keeps
the pinned Gemini CLI as it is.

## Risks

- **The dispatch step fails quietly** and a tag again ships without an image.
  Mitigation: the Phase 0 check runs on the first real release, and suite
  AC-AI-05 fails when a repo can't pin the new version.
- **A deleted file was still needed.** Mitigation: one PR per row, the checks
  in the table, and the `v2.2.0` tag to recover from.
