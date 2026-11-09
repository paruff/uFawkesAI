# Plan — v2.3.0: Anthropic and Google lifecycles in one image

Status: DRAFT for owner decisions. Written 2026-10-22, after v2.2.0-rc.1 was tagged. AWS AI-DLC was dropped on
2026-11-05 (`docs/ai-sdlc/remove-aidlc/plan.md`); this plan no longer covers it.

## Where each lifecycle stands

| Lifecycle | In the image today | Upstream (checked 2026-10-22) | Gap |
| --- | --- | --- | --- |
| Anthropic AI-native SDLC | Claude Code, `AGENTS.md`/`CLAUDE.md`, four agents, intent/spec/plan chain, `REVIEW.md`, `/review-local`, Superpowers | The AI-Native SDLC Playbook (Anthropic, 2026-08-21) | Complete for v2.2.0. Needs only a Codespace onboarding run |
| Google | `@google/gemini-cli` 0.63.0 pinned; `GEMINI.md` symlink | **No official Google "AI SDLC" framework found.** Google moved its terminal agent from Gemini CLI to the closed-source Antigravity CLI ([discussion](https://github.com/google-gemini/gemini-cli/discussions/27274)); Gemini CLI stopped serving most individual users on June 18, 2026 ([The Register](https://www.theregister.com/ai-ml/2026/05/20/bye-bye-gemini-cli-google-nudges-devs-toward-antigravity/5243605)). A spec-driven multi-agent pattern for Antigravity exists only as a community tutorial | The target is undefined and the tool we ship has been replaced |

## Decisions needed

- **G1 — What does "Google AI SDLC" mean here?** (a) Support the Antigravity CLI as a fifth agent tool; (b) keep Gemini CLI as a
  compatibility tool only; (c) a documented spec-driven pattern on Antigravity, written by us. No Google-published lifecycle was found
  to adopt. Recommend (a) plus (c) as an adapter page, after a spike on how Antigravity CLI can be installed and pinned (it is
  closed-source: like Claude Code, install at container create from a pinned version, not baked in).
- **G2 — One chain.** Recommend **one** artifact chain (`intent.md` → `spec.md` → `plan.md`) with a thin adapter per lifecycle that maps
  its vocabulary onto it. Anthropic's verify/review stages map to the review gate both lifecycles share.
- **G3 — File budget.** Recommend a ceiling of **250 tracked files** with both lifecycles in, which means a net cut of 22+ while adding
  two adapters.
- **G4 — Version.** Recommend v2.3.0 (new capability, no contract break), with a `-rc.1` first.

## Phases

0. **Finish v2.2.0 (now).** rc.1 publish green; Codespace onboarding run on a pinned rc digest; tag `v2.2.0`; point `devcontainer.json`
   at the release digest. Fix uFawkesAI#252 so the next release publishes without a hand-pushed tag.
1. **Shared base.** Define the adapter contract in one page: each lifecycle supplies (a) install/pin, (b) a mapping to intent/spec/plan,
   (c) the review gate it uses (`REVIEW.md`), (d) a check that proves it works offline in the image. Write it before any adapter, so
   adapters stay small.
2. **Google adapter.** Run the Antigravity spike (install method, licence for redistribution, version pinning, headless mode). Then build
   the adapter per G1. Update or retire the pinned Gemini CLI to match.
3. **Anthropic adapter.** Move today's README and `.agents/README.md` lifecycle text into the same adapter format so both look alike.
4. **File diet (runs alongside).** Targets, each its own reviewable PR, recoverable from tags:
   - `templates/tests/` (10 files of scaffolds for sibling platform repos) out to the repo that uses them.
   - Fold the `test-*.sh` self-test scripts into the existing `scripts/run-unit-tests.sh` runner.
   - Collapse `.opencode/` and `.claude/` mounts that are symlinks to one canonical set, keeping only those an agent tool needs.
   - Re-audit `docs/` against inbound links after each phase; delete anything with none.
5. **Release.** `v2.3.0-rc.1` → Codespace run per lifecycle (two runs) → `v2.3.0`.

## Verification Strategy

| Criterion | How it is verified |
| --- | --- |
| Each lifecycle works offline in the image | one image test per adapter in `images/devsecops/tests/verify-tools.sh`, run in CI on both architectures (amd64, arm64) |
| One chain, one review gate | `scripts/check-artifact-chain.sh` and `scripts/check-review-md.sh` pass; each adapter page links to `REVIEW.md` and the chain |
| Five-minute onboarding per lifecycle | a timed Codespace run per adapter, recorded in the release PR |
| File budget | `git ls-files \| wc -l` is at most 250 at the release tag |
| Pins stay pinned | `images/devsecops/tools.lock.json` entries carry versions and sha256; Antigravity, if added, is pinned by version at create time |

## Risks

- Google's tooling is moving: a pinned Antigravity version may change licence or behaviour. Mitigation: treat it as a create-time
  install behind a version pin, not baked in.
- Two lifecycles invite two sets of docs. Mitigation: the adapter contract and a page cap of one per lifecycle.
