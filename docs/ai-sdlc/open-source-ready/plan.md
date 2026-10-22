# Plan — open-source ready (audit and cleanup)

Status: APPROVED; decisions below. Starts after #250 (v2.2.0) merges. Audit of `main` @ 2026-10-22 (298 tracked files).

## What the audit found

**Good (keep as is):** no secrets in 503 commits of history (`gitleaks`, redacted); MIT
license, `SECURITY.md`, `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, issue templates, a clean
CI gate set; pinned, signed, reproducibly-built image.

**Problems, with evidence**

| # | Finding | Evidence |
| --- | --- | --- |
| F1 | **README describes a different product.** | Says "14 agent profiles" (there are 4), "`AGENTS.md` (135 lines)" (50), a Copilot token-billing section, a "tested prompt library", an 8-hour Dojo path. It names the template and `fawkes-space` image only in passing. |
| F2 | **Depends on repos a stranger can't see.** | "Dojo" / uFawkesObs / uFawkesDojo / uFawkesDevX appear in 4 skills (22, 20, 19, 17 mentions), 6 docs and the README. |
| F3 | **Oversized, emoji-heavy skills that read as generated.** | `dora-measurement` 985 lines, `discovery` 916, `learn` 835, `ai-stance` 757, `documentation` 956 across 6 files; 35 emoji in `learn`, 20 in `ai-stance`. Only `continuous-evals`, `dev-experience`, `ufawkes-knowledge` are short. |
| F4 | **Orphan or near-orphan docs** (referenced by 0–1 other files). | `DATA_MODEL.md` (0), `README-mcp.md` (0), `AGENT_METRICS.md`, `AGENT_TELEMETRY.md`, `DORA_alignment.md`, `PR_STANDARD.md`, `DOJO_LEARNING_PATH.md` (1 each). |
| F5 | **Maintainer process files at the root and in docs.** | `INTENT.md`, `TEMPLATE-DESIGN.md`, `README-ai-sdlc.md`, `README-mcp.md`, `.artifact-chain-paths`, `.pipeline.yml`; `docs/ai-sdlc/` holds 11 internal feature folders (~30 files) of project history. |
| F6 | **Personal / environment leakage.** | A private LAN IP in `opencode/opencode.jsonc` and `opencode/README.md`; a Copilot-bot-authored history (79 of 454 commits). |
| F7 | **Many agent-harness config copies.** | `CLAUDE.md`, `GEMINI.md`, `.cursorrules`, `.cursor/`, `.github/copilot-instructions.md`, `.copilotignore`, `opencode.json` + `.opencode/opencode.json`: 8 pointers to one file. The `AGENTS.md` symlinks are the product, so keep them, but audit the rest. |
| F8 | **16 workflows**, some only serve the maintainer's sibling repos. | `dojo-feedback-intent.yml`, `pre-commit-autoupdate.yml` overlap with Dependabot, `doc-freshness.yml`. |

## Tiers

- **Keep (core):** `AGENTS.md` + harness pointers, `.agents/{agents,rules,commands,assertions,evals}`,
  `REVIEW.md`, `opencode/`, `images/`, `.devcontainer/`, `scripts/` used by CI or hooks,
  the image/release/review workflows, LICENSE/SECURITY/CoC/CONTRIBUTING.
- **Trim to under 150 lines each:** `discovery`, `ai-stance`, `documentation`, `context-engineering`,
  `integration-testing`, `lang`; remove emoji headers.
- **Move out (to a `paruff/uFawkes-extras` repo or delete):** `dora-measurement`, `learn`,
  `dojo-navigator`, all `DOJO_*` docs, `UFAWKES_INTEGRATION.md`, `dojo-feedback-intent.yml`,
  `docs/ai-sdlc/dojo-handoff.md`, `VALUE_STREAM_MAP.md`, `TEAM_ARCHETYPE.md`.
- **Delete (orphans / duplicates):** `DATA_MODEL.md`, `README-mcp.md` (fold 10 lines into `docs/DEVCONTAINER.md`),
  `AGENT_METRICS.md`, `AGENT_TELEMETRY.md`, `DORA_alignment.md`, `PR_STANDARD.md`,
  `PROMPT_LIBRARY.md` (615 lines), `TEMPLATE-DESIGN.md` and `INTENT.md` (fold the useful half into the README).
- **Archive:** `docs/ai-sdlc/*` feature folders to a `docs/history/` branch or tag; keep `v2.2.0/` and
  `open-source-ready/` as the worked example of intent → spec → plan.

## Phases (one PR each; `/review-local` before every commit)

1. **Truth first (README).** Rewrite for what exists: what the template is, the 4 agents, the lifecycle
   (plan → build → verify → review → ship), `fawkes-space` install, `REVIEW.md`. Under 120 lines, no badge wall,
   no emoji. Extend `check-readme-claims.sh` to assert agent count, `AGENTS.md` length and linked files exist.
2. **Remove leakage.** F6: strip the LAN IP and personal paths; add a `gitleaks` + a "no private IPs / home paths" check.
3. **Cut sibling-repo coupling.** Open PRs moving the skills to uFawkesObs and uFawkesDojo (O1), then remove them here
   and fix the links the link-checker flags.
4. **Delete orphans** (F4) and root process files (F5). Each deletion first needs `git grep` in-degree 0 after step 3.
5. **Trim the remaining skills** (F3) by hand, not by a model pass: keep the steps a user runs, drop the narration.
6. **Workflow diet** (F8): drop workflows whose only consumer was removed; document each remaining one in a table in `CONTRIBUTING.md`.
7. **Public-facing polish:** issue/PR templates trimmed to what maintainers read; `CODEOWNERS` kept single (done);
   repo description and topics reduced to what is true; a `docs/README.md` index of the surviving docs.

## Decisions (owner, 2026-10-22)

- **O1** Move the skills out, into the repos they serve: `dora-measurement` and the `/measure` command into
  **uFawkesObs**; `learn`, `dojo-navigator`, the `DOJO_*` docs and `dojo-feedback-intent.yml` into **uFawkesDojo**.
  Moving means a PR in each target repo first (outward-facing: needs the owner's go-ahead per repo), then deletion here.
- **O2** Feature folders under `docs/ai-sdlc/` stay in git history; tag `pre-cleanup` before the first deletion.
- **O3** No history rewrite.
- **O4** Keep `GEMINI.md`, `.cursorrules` and `.copilotignore`.

## Acceptance

- Tracked files down from 298 to under 180; no skill over 200 lines.
- `git grep -E "Dojo|uFawkesObs|192\.168\.|/Users/"` returns nothing outside `CHANGELOG.md`.
- `check-readme-claims.sh` passes and covers the new claims; `pre-commit run --all-files` and CI green.
- A stranger can follow the README to a running `fawkes-space` container in under 5 minutes (tested on a clean machine).

## Risks

- Deleting something a sibling repo (uFawkesPipe, uFawkesObs) links to: run `gh search code --owner paruff` for each removed path first.
- Over-trimming skills removes real content: trim in a PR separate from deletions so each is reviewable.

## Verification Strategy

| Criterion | How it is verified |
| --- | --- |
| Tracked files: 266 accepted by the owner on 2026-10-22 (the original under-180 target is withdrawn); no skill over 200 lines | `git ls-files \| wc -l`; `wc -l .agents/skills/*/SKILL.md` |
| No leakage | `git grep -E "Dojo\|uFawkesObs\|192\.168\.\|/Users/"` is empty outside `CHANGELOG.md` |
| README is true | `scripts/check-readme-claims.sh` extended with agent count, `AGENTS.md` length, linked-file existence |
| Nothing a sibling repo needs was removed | `gh search code --owner paruff` for each removed path before deletion |
| Gates stay green | `pre-commit run --all-files` and CI on every PR |

## Progress (2026-10-22)

| Phase | State |
| --- | --- |
| 1 README | Done: 104 lines, claims check extended (agent count) |
| 2 Leakage | Done: private IP removed; `check-no-leakage.sh` is a pre-commit hook and a unit suite |
| 3 Sibling coupling | Done: `learn`, `dojo-navigator`, four Dojo docs to uFawkesDojo#110; `integration-testing` and `dora-measurement` to uFawkesObs#681; `/measure` removed here (Obs has its own); Dojo feedback pipeline removed; operator agent and `/release` now only file the follow-up issue |
| 4 Orphans | Done: nine docs removed, six finished feature chains archived under the `pre-cleanup` tag |
| 5 Skills | Done: no skill file over 200 lines (discovery 916 to 79, dora-measurement 985 to 74, ai-stance 757 to 59) |
| 6 Workflows | Partly: one workflow removed; the rest are documented in CONTRIBUTING. No more removed: each is a required check or a release gate |
| 7 Polish | Done: `docs/README.md`, CONTRIBUTING workflow table, Node 22 fix |

Tracked files: 298 to 266. The target of 180 was not reached and is revised to "under 270, and nothing a user does not need" after the audit; the remaining mass is the image build, the CI scripts and
their tests, and the guardrail docs, which current users depend on. Revisit after the Dojo and Obs PRs merge.

## Stranger-onboarding measurement (2026-10-22)

`docker pull ghcr.io/paruff/fawkes-space:latest` then `docker run`: pull 100 s, start 6 s, 106 s total, on a Mac with Colima and a
warm network. It is not a clean-machine run (Colima and Docker were already installed). `:2.1.0` does not exist because the
release-please tag did not publish (#252), so the README tells readers to pin a version from the Releases page; fix #252 first.
A true clean-machine timing (install Docker, open the repo, Reopen in Container) still needs a person on a fresh machine.

## Owner acceptance (2026-10-22)

The owner accepted 266 tracked files as the end state of this cleanup. The clean-machine onboarding test is to be run in a
GitHub Codespace created from a throwaway repo made with **Use this template**, which is a clean machine with no local
Docker, Colima or checkout. Record the time from "Create codespace" to a working `claude --version` here when it is done.
