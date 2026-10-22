# Changelog

All notable changes to uFawkesAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.2.0](https://github.com/paruff/uFawkesAI/compare/v2.1.0...v2.2.0) (2026-10-22)


### Added

* **image:** v2.2.0 — OpenCode 2.1.2, review before commit, image-only bake ([#250](https://github.com/paruff/uFawkesAI/issues/250)) ([2bd6e68](https://github.com/paruff/uFawkesAI/commit/2bd6e685faf36c8f38b098ae2e2a2d7bce0f2f04))


### Fixed

* address the last-5-PR review findings ([#243](https://github.com/paruff/uFawkesAI/issues/243)) ([4ea148f](https://github.com/paruff/uFawkesAI/commit/4ea148f9e62d663d5b23e5e7da3a9bff67a9d899))


### Docs

* **plan:** plan v2.3.0 with Anthropic, AWS AI-DLC and Google lifecycles ([#257](https://github.com/paruff/uFawkesAI/issues/257)) ([fbab21e](https://github.com/paruff/uFawkesAI/commit/fbab21e2891d105628399cad351235e1c9e54aa4))
* **plan:** record the Codespaces onboarding result ([#259](https://github.com/paruff/uFawkesAI/issues/259)) ([946bced](https://github.com/paruff/uFawkesAI/commit/946bced9bbc32cbb4e44a1a088bc59a78c4e9d7b))
* **readme:** centre on the Anthropic AI-native SDLC with Superpowers ([#258](https://github.com/paruff/uFawkesAI/issues/258)) ([6ff374d](https://github.com/paruff/uFawkesAI/commit/6ff374dbcd30986ab25dc42afde13db916470057))


### Changed

* **ci:** publish the ai base as fawkes-space:base-&lt;version&gt; ([#247](https://github.com/paruff/uFawkesAI/issues/247)) ([395f03e](https://github.com/paruff/uFawkesAI/commit/395f03e6ce3adc80ef8b80b7aeca965d8cddd954))


### Chores

* slim the repo for open source (README, leakage, skills, docs) ([#251](https://github.com/paruff/uFawkesAI/issues/251)) ([641f4e9](https://github.com/paruff/uFawkesAI/commit/641f4e95ce58f365bda102fcf0e5b11e84274f0c))

## [2.1.0](https://github.com/paruff/uFawkesAI/compare/v2.0.0...v2.1.0) (2026-10-19)


### Added

* **ci:** add REVIEW.md and an agent PR-review job ([#158](https://github.com/paruff/uFawkesAI/issues/158)) ([#232](https://github.com/paruff/uFawkesAI/issues/232)) ([eafc523](https://github.com/paruff/uFawkesAI/commit/eafc52373f3c36d42b132d60b3a80fcaaf02fb13))
* **devcontainer:** bake hook envs; Claude Code + OpenCode extensions ([#202](https://github.com/paruff/uFawkesAI/issues/202)) ([f287db4](https://github.com/paruff/uFawkesAI/commit/f287db4fd967ed0bbaf467e0e94043baa45823a5))
* **image:** kubeconform, kustomize, helm 3, mkdocs in core ([#193](https://github.com/paruff/uFawkesAI/issues/193)) ([#203](https://github.com/paruff/uFawkesAI/issues/203)) ([75ef306](https://github.com/paruff/uFawkesAI/commit/75ef306f444b36a13ddad40e2fd8ec2030fe4aa5))
* **image:** pin aidlc in the ai variant (AI-DLC R1–R6) ([#225](https://github.com/paruff/uFawkesAI/issues/225)) ([b53a791](https://github.com/paruff/uFawkesAI/commit/b53a7918cf48446c505343ae93c3a27d4dd61a04))
* **image:** verify TOFU tools against GitHub's release asset digests ([#207](https://github.com/paruff/uFawkesAI/issues/207)) ([38a39d9](https://github.com/paruff/uFawkesAI/commit/38a39d9d27ca9e6ca5d920945d27ff70437b31ba))
* **shift-left:** type-check with tsc --noEmit and mypy ([#192](https://github.com/paruff/uFawkesAI/issues/192)) ([#208](https://github.com/paruff/uFawkesAI/issues/208)) ([40bccef](https://github.com/paruff/uFawkesAI/commit/40bccefb953bc8ba95cd849c8622f7f2f5e27d62))


### Fixed

* **ci:** exempt the image lock-bump PR from the plan.md rule ([#205](https://github.com/paruff/uFawkesAI/issues/205)) ([81f3009](https://github.com/paruff/uFawkesAI/commit/81f3009486d501d35b1a78b2c436b33ddd40810f))
* **ci:** test for the Trivy report instead of swallowing cat's errors ([#180](https://github.com/paruff/uFawkesAI/issues/180)) ([#227](https://github.com/paruff/uFawkesAI/issues/227)) ([0189ddd](https://github.com/paruff/uFawkesAI/commit/0189dddbe000be51f63b2b93cc9e6e0c30b28b7c))
* **docs:** restore CHANGELOG history; repair security form and PR gate hint ([#217](https://github.com/paruff/uFawkesAI/issues/217)) ([16b71a3](https://github.com/paruff/uFawkesAI/commit/16b71a39ac5833f2d9dce530aae41e9908b6e673))
* **image:** patch npm security alerts; Codex 0.161, Gemini 0.63 ([#206](https://github.com/paruff/uFawkesAI/issues/206)) ([25cfb0e](https://github.com/paruff/uFawkesAI/commit/25cfb0ed7acb669c0e8ff7c58e366e65483d0cc0))
* **release:** add missing release-please-config.json; drop dangling labels ([#215](https://github.com/paruff/uFawkesAI/issues/215)) ([b952e2a](https://github.com/paruff/uFawkesAI/commit/b952e2a93e117517e89e27f4e40eca270905dfc5))


### Docs

* **ai-sdlc:** add AI-DLC opt-in intent, spec and plan ([#218](https://github.com/paruff/uFawkesAI/issues/218)) ([#221](https://github.com/paruff/uFawkesAI/issues/221)) ([22132ef](https://github.com/paruff/uFawkesAI/commit/22132efd0a5e50253ee727b9634d50f1758b2149))
* **changelog:** add Keep a Changelog header and Unreleased section ([#211](https://github.com/paruff/uFawkesAI/issues/211)) ([c8cc640](https://github.com/paruff/uFawkesAI/commit/c8cc6404398e48d737f6bda6b0b6741534a6776b))
* **governance:** add CODE_OF_CONDUCT ([#209](https://github.com/paruff/uFawkesAI/issues/209)) ([93afc91](https://github.com/paruff/uFawkesAI/commit/93afc91d5dc5b211971883ae7df5950f63ecea57))
* **issue-templates:** add security vulnerability template ([#213](https://github.com/paruff/uFawkesAI/issues/213)) ([f4af6ef](https://github.com/paruff/uFawkesAI/commit/f4af6ef128ded7a87a351ea4fad2d8698a648444))
* **pr-template:** fix uFawkesAI PR template ([#212](https://github.com/paruff/uFawkesAI/issues/212)) ([fcc9642](https://github.com/paruff/uFawkesAI/commit/fcc964267ea0047158fe851d3928372d450d9978))
* **readme:** cite research basis (paruff/uFawkes.dev[#65](https://github.com/paruff/uFawkesAI/issues/65)) ([#233](https://github.com/paruff/uFawkesAI/issues/233)) ([2d63571](https://github.com/paruff/uFawkesAI/commit/2d63571b2986bd42133d2fa38973ae55b1ceba81))
* remove AI slop and placeholder ambiguity from public docs ([#214](https://github.com/paruff/uFawkesAI/issues/214)) ([eed2a49](https://github.com/paruff/uFawkesAI/commit/eed2a4911d3870379df1d312d217c0c829d33962))


### Chores

* **ci:** adopt Pipe v1.15.0-beta.1; drop local lint copy ([#181](https://github.com/paruff/uFawkesAI/issues/181)) ([#228](https://github.com/paruff/uFawkesAI/issues/228)) ([94c683b](https://github.com/paruff/uFawkesAI/commit/94c683ba8cfa843a0682b3b708c6551506c3c3ce))
* **ci:** bump uFawkesPipe reusables to v1.16.0-beta.1 ([#230](https://github.com/paruff/uFawkesAI/issues/230)) ([a49768c](https://github.com/paruff/uFawkesAI/commit/a49768ca3f2105e8ba628bb837f3db067015278b))
* **image:** bump locked toolchain (2026-10-04) ([#189](https://github.com/paruff/uFawkesAI/issues/189)) ([955dfbc](https://github.com/paruff/uFawkesAI/commit/955dfbc27afd897682bf1df8a6d8c4fc514d15e4))
* **image:** bump locked toolchain (2026-10-11) ([#224](https://github.com/paruff/uFawkesAI/issues/224)) ([d86452a](https://github.com/paruff/uFawkesAI/commit/d86452a8163982eb5d57193a6c0a4d181ce4f663))
* **image:** bump locked toolchain (2026-10-18) ([#242](https://github.com/paruff/uFawkesAI/issues/242)) ([24bd70e](https://github.com/paruff/uFawkesAI/commit/24bd70ebbc30e4a294cc49972f27f6b72c34f5ad))
* **infra:** adopt the OpenCode shift-left plugin ([#153](https://github.com/paruff/uFawkesAI/issues/153)) ([#229](https://github.com/paruff/uFawkesAI/issues/229)) ([b8028f4](https://github.com/paruff/uFawkesAI/commit/b8028f478699edb41df16501f2284e75eab4e771))

## [Unreleased]

### Changed

- The ai base image is no longer a separate `fawkes-space-ai` package: it is published as `ghcr.io/paruff/fawkes-space:base-<version>`. Consumers of `fawkes-space` and `fawkes-core` are unaffected.

### Added

- Governance baseline (CODE_OF_CONDUCT)
- release-please workflow automation

## [2.0.0] — 2026-10-03

The 2.0 contract and the 1.x upgrade path: [`docs/ai-sdlc/v2.0.0/spec.md`](docs/ai-sdlc/v2.0.0/spec.md).

### Breaking

- npm package renamed `copilot-starter-template` → `ufawkesai`.
- The gitops image variant and the polyglot (Java) variant are removed.
- The devcontainer image is `ghcr.io/paruff/fawkes-space` (bases `fawkes-space-ai`, `fawkes-core`), released by the template's own `vX.Y.Z` tag; `image-v*` tags are retired after v2.1.0.

### Added

- Pinnable, cosign-signed (keyless, v3) devcontainer image with its digest in each GitHub Release (AC-AI-01).
- Live acceptance tests and a cold/warm start benchmark on every release; a regression of over 10% and 50 ms fails it (AC-AI-08).
- Agent evals scored on task success, tool use and trajectory; a required check (AC-AI-07).
- Placeholder audit that gates generated repos (AC-AI-02), README claims check (AC-AI-04), delivery events verified in uFawkesObs's Loki (AC-AI-06).
- Monthly `pre-commit autoupdate` PR; pre-commit.ci retired (AC-AI-09).
- `hostRequirements` (2 CPUs, 4 GB) in the devcontainer.

### Changed

- `/plan` and `/implement` use `docs/ai-sdlc/<feature>/`; the v1 chain moved to `docs/ai-sdlc/dual-harness-template/`.
- The image ships `curl`; pre-commit hook environments install once on first run.

## [1.0.0] — 2026-05-10

### Added

- Initial release as uFawkesAI (renamed from copilot-starter-template)
- AGENTS.md with full DORA AI Capabilities mapping
- CLAUDE.md and .cursorrules symlinks
- Agent Skills infrastructure (.github/skills/)
- Updated DORA 2025/2026 research integration
