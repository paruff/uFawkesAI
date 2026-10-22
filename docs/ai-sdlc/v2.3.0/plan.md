# Plan — v2.3.0: Anthropic, AWS AI-DLC and Google lifecycles in one image

Status: DRAFT for owner decisions. Written 2026-10-22, after v2.2.0-rc.1 was tagged.

## Where each lifecycle stands

| Lifecycle | In the image today | Upstream (checked 2026-10-22) | Gap |
| --- | --- | --- | --- |
| Anthropic AI-native SDLC | Claude Code, `AGENTS.md`/`CLAUDE.md`, four agents, intent/spec/plan chain, `REVIEW.md`, `/review-local`, Superpowers | The AI-Native SDLC Playbook (Anthropic, 2026-08-21) | Complete for v2.2.0. Needs only a Codespace onboarding run |
| AWS AI-DLC | `aidlc` 2.11.0 pinned as an opt-in binary (`docs/ai-sdlc/aidlc-workflows`); nothing configured by default | [awslabs/aidlc-workflows](https://github.com/awslabs/aidlc-workflows) is at 2.11.1 stable; 2.11.2 previews exist. Phases: Inception, Construction, a future Operations | One patch behind. No mapping to our artifact chain, no review gate, no check that `aidlc config` works for both harnesses in the image |
| Google | `@google/gemini-cli` 0.63.0 pinned; `GEMINI.md` symlink | **No official Google "AI SDLC" framework found.** Google is moving its terminal agent from Gemini CLI to the closed-source Antigravity CLI ([discussion](https://github.com/google-gemini/gemini-cli/discussions/27274)); Gemini CLI stops serving most individual users June 18, 2026 ([The Register](https://www.theregister.com/ai-ml/2026/05/20/bye-bye-gemini-cli-google-nudges-devs-toward-antigravity/5243605)). A spec-driven multi-agent pattern for Antigravity exists only as a community tutorial | The target is undefined and the tool we ship is being replaced |

## Decisions needed

- **G1 — What does "Google AI SDLC" mean here?** (a) Support the Antigravity CLI as a fifth harness; (b) keep Gemini CLI as a compatibility
  harness only; (c) a documented spec-driven pattern on Antigravity, written by us. I could not find a Google-published lifecycle to adopt.
  Recommend (a) plus (c) as an adapter page, after a spike on how Antigravity CLI can be installed and pinned (it is closed-source: like Claude Code,
  install at container create from a pinned version, not baked in).
- **G2 — One chain or three?** Recommend **one** artifact chain (`intent.md` → `spec.md` → `plan.md`) with a thin adapter per lifecycle
  that maps its vocabulary onto it, instead of three parallel processes. AI-DLC Inception maps to intent + spec; Construction to plan + build;
  Anthropic's verify/review stages map to the review gate that all three share.
- **G3 — File budget.** Recommend a ceiling of **250 tracked files** with all three lifecycles in, which means a net cut of 22+ while adding three adapters.
- **G4 — Version.** Recommend v2.3.0 (new capability, no contract break), with a `-rc.1` first.

## Phases

0. **Finish v2.2.0 (now).** rc.1 publish green; Codespace onboarding run on a pinned rc digest; tag `v2.2.0`; point `devcontainer.json` at the release digest.
   Fix #252 so the next release publishes without a hand-pushed tag.
1. **Shared base.** Define the adapter contract in one page: each lifecycle supplies (a) install/pin, (b) a mapping to intent/spec/plan, (c) the review gate it uses
   (`REVIEW.md`), (d) a check that proves it works offline in the image. Write it before any adapter, so adapters stay small.
2. **AWS AI-DLC adapter.** Bump `aidlc` to 2.11.1 (stable only; previews are never selected). Add the mapping page. Add an image test: in a fresh repo with `--network none`,
   `aidlc config --harness claude --dry-run` and `--harness opencode --dry-run` succeed. Keep it opt-in; the template ships no AI-DLC files (spec R3 stays).
3. **Google adapter.** Run the Antigravity spike (install method, license for redistribution, version pinning, headless mode). Then build the adapter per G1.
   Update or retire the pinned Gemini CLI to match, and note the June 18 cutoff in the docs.
4. **Anthropic adapter.** Move today's README and `.agents/README.md` lifecycle text into the same adapter format so all three look alike.
5. **File diet (runs alongside).** Targets, each its own reviewable PR, recoverable from tags:
   - `templates/tests/` (10 files of scaffolds for sibling platform repos) out to the repo that uses them.
   - Merge the `test-*.sh` self-test scripts into one runner with per-script cases where they exercise one checker.
   - Collapse `.opencode/` and `.claude/` mounts that are symlinks to one canonical set, keeping only those a harness needs.
   - Re-audit `docs/` against inbound links after each phase; delete anything with none.
6. **Release.** `v2.3.0-rc.1` → Codespace run per lifecycle (three runs) → `v2.3.0`.

## Verification Strategy

| Criterion | How it is verified |
| --- | --- |
| Each lifecycle works offline in the image | one image test per adapter in `images/devsecops/tests/verify-tools.sh`, run in CI on both arches |
| One chain, one review gate | `scripts/check-artifact-chain.sh` and `scripts/check-review-md.sh` pass; each adapter page links to `REVIEW.md` and the chain |
| AI-DLC stays opt-in | the image's default `git status` in a fresh repo shows no AI-DLC files (existing spec R3 test) |
| Five-minute onboarding per lifecycle | a timed Codespace run per adapter, recorded in the release PR |
| File budget | `git ls-files \| wc -l` is at most 250 at the release tag |
| Pins stay pinned | `tools.lock.json` entries carry versions and sha256; Antigravity, if added, is pinned by version at create time |

## Risks

- Google's tooling is moving: a pinned Antigravity version may change licence or behaviour. Mitigation: treat it as a create-time install behind a version pin, not baked in.
- Three lifecycles invite three sets of docs. Mitigation: the adapter contract and a page cap of one per lifecycle.
- AI-DLC previews ship daily; the bump script already skips previews, and the image test catches a stable release that breaks `aidlc config`.
