# Plan: v2.2.0 — fawkes-space for the Anthropic AI-native SDLC

Status: APPROVED (decisions below); implementation in progress. Written 2026-10-22 against v2.1.0 (released 2026-10-20).

## Goal

`ghcr.io/paruff/fawkes-space` supports the Anthropic AI-native SDLC end to end:
plan → build → review → ship, with `REVIEW.md` driving review, Superpowers as
the construction skill suite, and current Claude Code and OpenCode.

## Where we are (verified 2026-10-22)

| Piece | In the image | Latest upstream | Gap |
| --- | --- | --- | --- |
| Superpowers | 7.0.0 (`tools.lock.json`) | 7.0.1 (2026-10-21) | One patch behind. Brainstorming retune, three skills trimmed for Claude Code compaction. Low risk |
| Claude Code | 2.1.293 (`.devcontainer/Dockerfile`) | 2.1.308 | 15 builds behind. Installed from npm at build time, so a bump is one `ARG` |
| OpenCode | 1.19.3 (sst/opencode, matches upstream 1.19.x) | **2.1.2** (the `opencode-v2` Homebrew formula, which you run locally) | A **major** version behind your host. v2 binaries are published at `opencode.ai/files/bin/2.1.2/…` and are not on the GitHub release feed we track |
| REVIEW.md | `REVIEW.md` + `agent-review.yml` + `check-review-md.sh` in CI | n/a | CI-only. Inside the image there is no way to run the same review locally before pushing |
| Host config sync | `opencode/sync.sh` is called by the image build to bake config; also a manual host mode | n/a | See decision D3 |

## Decisions (owner, 2026-10-22)

- **D1** OpenCode 2.1.2 goes into 2.2.0.
- **D2** Target is the Anthropic workflow starting from `intent.md` → `spec.md` → `plan.md`, with a review stage added **before commit and CI**. AI-DLC stays opt-in.
- **D3** Remove the host `--apply`: `sync.sh` is replaced by an image-only `bake.sh`.
- **D4** Release as `v2.2.0`, via `v2.2.0-rc.1` first.

## Plan

Order matters: land the image-plumbing PRs first, then content bumps, then the release.

1. **Merge the two open PRs** (you review; I never merge).
   - #247 fold `fawkes-space-ai` into `fawkes-space:base-<version>` — **untested publish path**.
   - the agent-review warning PR (key no longer required; Dependabot PR #246 unblocks).
2. **Superpowers 7.0.0 → 7.0.1.** `tools.lock.json` version + sha256 (the existing
   `image-lock-bump` workflow should do this; if not, `scripts/image-lock-bump.sh`).
   Verify with `images/devsecops/tests/verify-tools.sh ai`.
3. **Spike: OpenCode v2.1.2 compatibility** (no image change yet). On the host, point
   `OPENCODE_CONFIG_DIR` at a scratch copy of `opencode/` and run `opencode/validate.sh`
   plus the four agents. Output: pass / list of config changes needed. Gates D1.
4. **OpenCode bump** (per D1). New `tools.lock.json` entry with source `opencode.ai/files/bin/<v>/`
   and sha256 from the formula (no upstream checksum file, same as today's note); update
   `image-lock-bump` to track the v2 feed, or pin manually with a note.
5. **Claude Code 2.1.293 → current** in `.devcontainer/Dockerfile`; run `multi-harness-smoke.sh`.
6. **Review inside the image (REVIEW.md support).**
   - Add a `/review-local` command/skill in the image that runs Claude Code against `git diff origin/main...HEAD`
     with `REVIEW.md` as the rubric (same prompt as `agent-review.yml`, one source of truth).
   - `check-review-md.sh` already runs in CI; make `scripts/shift-left.sh` run it locally too.
   - Verifier agent: cite `REVIEW.md` levels (HIGH/MEDIUM/LOW) in its report so it matches the CI reviewer.
7. **Construction skill suite = Superpowers.** Already linked into both harnesses. Add an acceptance
   check that the stage skills the routing names (`brainstorming`, `writing-plans`,
   `test-driven-development`, `verification-before-completion`, `systematic-debugging`) exist in the
   image at the pinned version, so a Superpowers rename fails CI instead of silently breaking routing.
8. **Config changes go through evals.** Items 2, 4, 5 and 6 change agent configuration, so run
   `continuous-evals` before merging (project rule).
9. **Release.** `/release` checklist: tag `v2.2.0-rc.1` → wait for publish, sign, live acceptance,
   benchmark, reproducibility → verify the `fawkes-space:base-2.2.0-rc.1` tag exists and
   `cosign verify` passes → tag `v2.2.0`.
10. **Cleanup after the rc succeeds.** Delete the `fawkes-space-ai` GHCR package; mirror the workflow
    edits into `ufawkesai-template-test`; update uFawkesPipe only if it consumes anything but
    `fawkes-core` (it does not today).

## Acceptance

- `verify-tools.sh ai` and `multi-harness-smoke.sh` pass with the new pins.
- `opencode --version` in the image matches the pin; `claude --version` matches 2.1.x current.
- `/review-local` in the image produces a REVIEW.md-formatted finding list on a seeded diff.
- A `v2.2.0-rc.1` run is green end to end, including signing and the benchmark gate (<10% regression).

## Risks

- OpenCode v2 may break the 1.x config and plugins (mitigated by the step 3 spike and by shipping without it).
- The #247 publish path has never run; the rc is its first test (mitigated by rc-first).
- v2 binaries come from `opencode.ai`, not GitHub: no upstream checksum file, so we pin the formula's sha256 and
  record where it came from. Reproducibility check may need an allowance until verified.
