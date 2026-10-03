# Plan — uFawkesAI v2.0.0

**Traces to:** [`spec.md`](spec.md) | **Status:** Draft | **Revision:** 1

Tasks are issues under goal #145; this plan holds order and verification, not
task status.

## Already landed

| REQ | What | PR |
|---|---|---|
| REQ-004 | Harness anatomy, DORA AI and playbook-stage maps in the README | #167 |
| REQ-006 | Emitter works outside CI (GAP-01, GAP-02) | #161 |
| REQ-007 | Cold/warm start benchmark | #164, #167 |
| REQ-008 | Hook environments pre-baked in the image; no `ci:` block here | #162 |

## Task order

1. **This artifact chain** (#146). Close #155: its spec and plan are on `main`.
2. **Publish path** (#111), the critical path:
   - Finish the #165 rename. `.devcontainer/` already says `fawkes-space`,
     but `build-devsecops-images.yml` still publishes and benchmarks
     `fawkes-space-devcontainer`.
   - Trigger the publish on `v*` tags (keep `image-v*` for one release),
     tagging `X.Y.Z` and `X.Y`; write the digest into the Release.
   - Amend `devsecops-image/spec.md` R6 and `image-benchmark/spec.md` R1,
     which name `image-v*`.
   - Prove it on `v2.0.0-rc.1`.
3. **Hygiene**, parallel with 2: placeholder audit (#28), move the v1 chain
   (#154).
4. **Delivery events to Obs** (#157): real event in Loki with LogQL, or remove
   the claim (README Observability row, `docs/UFAWKES_INTEGRATION.md`).
5. **Evals gate** (#148): weekly `schedule:` and hook paths on
   `agent-config-ci.yml`, per-task rubrics.
6. **Hook gate**: monthly `pre-commit autoupdate` workflow; sync Pre-flight
   and the absence of `ci:` blocks to the six other repos.
7. **On rc.1**: record the benchmark baseline, DevEx grounding (#150),
   "Use this template" run (#152).
8. **Release**: tag `v2.0.0`, run the `release` agent, add the
   `/compatibility/` row. Within a week: pins (#153, AC-AI-05).

### Owner actions (admin only)

- Protect `main` (it has no protection today): require Pre-flight, the unit
  tests and the eval job. Without this, REQ-005 and REQ-008 can't pass.
- Delete the retired `image-v0.1.0` and `v0.1.0-devcontainer` tags and any
  stale GHCR packages, after step 2 is proven.
- Update uFawkes.dev `suite-release/spec.md`, `acceptance.yml` (AC-AI-01,
  AC-AI-05) and the titles of #111 and #153 to the `fawkes-space` name.

## Verification Strategy

| REQ | AC | Check |
|---|---|---|
| REQ-001 | AC-AI-01 | `docker manifest inspect ghcr.io/paruff/fawkes-space:2.0.0` from an unauthenticated machine; `cosign verify ghcr.io/paruff/fawkes-space@<digest> --certificate-identity-regexp '^https://github.com/paruff/uFawkesAI/' --certificate-oidc-issuer https://token.actions.githubusercontent.com`; digest present in `gh release view v2.0.0` |
| REQ-002 | AC-AI-02 | Transcript of the #152 run, linked from the release |
| REQ-003 | AC-AI-03 | `curl -fsSL -o /dev/null https://raw.githubusercontent.com/paruff/uFawkesAI/main/docs/ai-sdlc/v2.0.0/spec.md`; release notes link it |
| REQ-004 | AC-AI-04 | Every file in the three README maps exists (`test -e`); every tool exists in `images/devsecops/tests/verify-tools.sh` output |
| REQ-005 | AC-AI-07 | `gh api repos/paruff/uFawkesAI/branches/main/protection` lists the eval job; a test PR breaking a rule file fails it |
| REQ-006 | AC-AI-06 | LogQL query in uFawkesObs returns the emitted event, or `grep -i uFawkesObs README.md docs/UFAWKES_INTEGRATION.md` shows no feed claim |
| REQ-007 | AC-AI-08 | `images/devsecops/benchmarks/baseline.json` updated from the rc.1 run; benchmark table in the release notes |
| REQ-008 | AC-AI-09 | No `^ci:` in any suite repo's `.pre-commit-config.yaml`; protection lists Pre-flight; `pre-commit run --all-files` passes as `dev` in a fresh devcontainer (the live acceptance tests run it; network allowed for the one-time hook download) |
| REQ-009 | AC-SITE-01 | ufawkes.dev `/compatibility/` shows uFawkesAI `v2.0.0` |

## Risks

| Risk | Likelihood | Mitigation |
|---|---|---|
| The signed tag publish has never run | High | Step 2 first, proven on rc.1. Slip > 2 weeks → Obs ships first |
| Half-done rename leaves `devcontainer.json` pointing at an unpublished image | Certain until step 2 | Step 2 fixes the workflow before rc.1 |
| `main` unprotected, so gates are advisory | Certain until owner acts | Owner actions above, before rc.1 |
| uFawkesObs claim stays unverified | Medium | Step 4's fallback removes the claim |
