# Plan — public release: a repo that holds up on first read

**Traces to:** [`spec.md`](spec.md) → [`intent.md`](intent.md). Goal #310. **Status:** Draft for the plan gate.
Tasks are sub-issues of #310; this plan holds order and verification, not task status. Each step is one PR.
Recover any deleted file from the `v2.2.0` tag.

**Order matters.** Checks first (so every later PR is held to them), then fixes, then deletions, then the release.
v2.3.0 Phase 0 and Phase 1 (image publish, `templates/tests/`, unit-runner fix) run in parallel; this plan does
not repeat them.

## Phase 1 — Checks that fail today

| Step | Change | Check |
| --- | --- | --- |
| 1.1 | `scripts/check-links.sh` plus `scripts/test-check-links.sh`; add to `SUITES` in `scripts/run-unit-tests.sh` and to CI | it finds the 7 known broken links, then 0 after 2.1 (AC-PR-01) |
| 1.2 | `scripts/check-orphans.sh` plus its self-test and an allow-list file | it lists the audit candidates on `main` today (AC-PR-03) |

Wire both into pre-commit as non-blocking until Phase 3 ends, then blocking.

## Phase 2 — Fix what is wrong

| Step | Change | Check |
| --- | --- | --- |
| 2.1 | `docs/AGENT_REFERENCE.md`: `./docs/METRICS.md` → `./METRICS.md` | `check-links.sh` exits 0 |
| 2.2 | Delete `API_SURFACE.md`, `CHANGE_IMPACT_MAP.md`, `DEVEX_LOG.md`; cut `KNOWN_LIMITATIONS.md` to L-004 and L-005 or delete it; fix every referrer (list in spec AC-PR-02) | the AC-PR-02 grep is empty; `check-links.sh` exits 0 |
| 2.3 | README badges (CI on `main`, release, licence); remove or measure any coverage claim | `check-readme-claims.sh` passes; badge URLs return 200 |
| 2.4 | `SECURITY.md`: report path, supported versions, image signature verification; collapse duplicate issue templates; fix community profile gaps | `gh api repos/paruff/uFawkesAI/community/profile` shows all files |

## Phase 3 — Delete what is orphaned or overtaken

One PR per row. In each, remove inbound links first, then the files.

| Step | Delete | Check |
| --- | --- | --- |
| 3.1 | `scripts/agent-skill-graph.sh`, `scripts/verify.sh`, `.claude/reviews/`, `rules/`, `opencode/commands/review-local.md` | `check-orphans.sh` and `scripts/run-unit-tests.sh` pass |
| 3.2 | the four sibling-repo skill files, after reading what each public skill needs | `scripts/run-evals.sh` passes (skills are eval-gated) |
| 3.3 | `docs/ai-sdlc/` chains `v2.0.0`, `v2.2.0`, `audit-medium-low`, `remove-aidlc`, `cde-space-rename`, `devsecops-image`; add the `git show` recovery note to `docs/ai-sdlc/README.md` | `check-artifact-chain.sh` and `check-links.sh` pass |

**Don't touch:** `.claude/` and `.opencode/` symlinks, `images/devsecops/`, `.devcontainer/`, `AGENTS.md` and its
symlinks (owner approval only), `REVIEW.md`, `INTENT.md`.

## Phase 4 — Slop check

4.1 Run `/ponytail-audit` on the whole repo. Fix each Must fix and Should fix, or write one line why not.
4.2 Read README, `docs/` and `.agents/skills/` once for filler and invented examples; cut, never add a file.
4.3 Make `check-links.sh` and `check-orphans.sh` blocking.

**Check:** the second audit has no Must fix; `git ls-files | wc -l` is at most v2.3.0's 250 (279 today).

## Phase 5 — Release and announce

5.1 Delete `docs/ai-sdlc/open-source-ready/` in the release PR. 5.2 Merge the Release Please PR for `v2.3.0`
(v2.3.0 Phase 2). 5.3 Verify the image and signature (AC-PR-10) and the cold-start run (AC-PR-08). 5.4 Run the
`release` skill for the dev.to and LinkedIn drafts. The owner reads and posts them; nothing is posted by an agent.

## Verification Strategy

| Criterion | Evidence |
| --- | --- |
| AC-PR-01 | `scripts/check-links.sh` exit 0 in CI |
| AC-PR-02 | the grep from the spec, empty, pasted in the PR |
| AC-PR-03 | `scripts/check-orphans.sh` prints nothing |
| AC-PR-04 | `ls docs/ai-sdlc/`, and `git show v2.2.0:docs/ai-sdlc/v2.2.0/spec.md` still works |
| AC-PR-05 | second `/ponytail-audit` report linked from the release PR |
| AC-PR-06 | `scripts/check-readme-claims.sh` passes; badge URLs return 200 |
| AC-PR-07 | `gh api .../community/profile` output |
| AC-PR-08 | `live-acceptance.yml` run link |
| AC-PR-09 | the four version files, printed side by side in the release PR |
| AC-PR-10 | `docker manifest inspect` and `cosign verify` output; #252 and #309 closed |
| Nothing else broke | `scripts/run-unit-tests.sh` and `pre-commit run --all-files` on every PR |

### Make commands

| Command | Proves | Needs |
| --- | --- | --- |
| `make validate` | Every pre-commit hook passes on every file | Nothing |
| `make doctor` | This clone's hooks are installed and its tools are present | Nothing |

New checks have no `make` target yet; run them directly.

## Risks

- **A deleted file was still needed.** One PR per row, the orphan check, the eval gate, and the `v2.2.0` tag.
- **The orphan check is noisy.** Basename matching flags slash commands and GitHub-convention files. The allow-list
  is part of step 1.2, and the check stays non-blocking until Phase 4.
- **Two plans delete the same file.** `templates/tests/` belongs to v2.3.0 Phase 1 only; this plan never lists it.
- **Deleting finished chains removes links other docs follow.** Step 3.3 removes inbound links first and
  `check-links.sh` proves none remain.
- **Posts go out before the image exists.** Phase 5 orders the image check before the drafts.
