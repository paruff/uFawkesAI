# Changelog

All notable changes to uFawkesAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0](https://github.com/paruff/uFawkesAI/compare/v2.0.0...v2.1.0) (2026-10-09)


### Added

* **devcontainer:** bake hook envs; Claude Code + OpenCode extensions ([#202](https://github.com/paruff/uFawkesAI/issues/202)) ([f287db4](https://github.com/paruff/uFawkesAI/commit/f287db4fd967ed0bbaf467e0e94043baa45823a5))
* **image:** kubeconform, kustomize, helm 3, mkdocs in core ([#193](https://github.com/paruff/uFawkesAI/issues/193)) ([#203](https://github.com/paruff/uFawkesAI/issues/203)) ([75ef306](https://github.com/paruff/uFawkesAI/commit/75ef306f444b36a13ddad40e2fd8ec2030fe4aa5))
* **image:** verify TOFU tools against GitHub's release asset digests ([#207](https://github.com/paruff/uFawkesAI/issues/207)) ([38a39d9](https://github.com/paruff/uFawkesAI/commit/38a39d9d27ca9e6ca5d920945d27ff70437b31ba))
* **shift-left:** type-check with tsc --noEmit and mypy ([#192](https://github.com/paruff/uFawkesAI/issues/192)) ([#208](https://github.com/paruff/uFawkesAI/issues/208)) ([40bccef](https://github.com/paruff/uFawkesAI/commit/40bccefb953bc8ba95cd849c8622f7f2f5e27d62))


### Fixed

* **ci:** exempt the image lock-bump PR from the plan.md rule ([#205](https://github.com/paruff/uFawkesAI/issues/205)) ([81f3009](https://github.com/paruff/uFawkesAI/commit/81f3009486d501d35b1a78b2c436b33ddd40810f))
* **docs:** restore CHANGELOG history; repair security form and PR gate hint ([#217](https://github.com/paruff/uFawkesAI/issues/217)) ([16b71a3](https://github.com/paruff/uFawkesAI/commit/16b71a39ac5833f2d9dce530aae41e9908b6e673))
* **image:** patch npm security alerts; Codex 0.161, Gemini 0.63 ([#206](https://github.com/paruff/uFawkesAI/issues/206)) ([25cfb0e](https://github.com/paruff/uFawkesAI/commit/25cfb0ed7acb669c0e8ff7c58e366e65483d0cc0))
* **release:** add missing release-please-config.json; drop dangling labels ([#215](https://github.com/paruff/uFawkesAI/issues/215)) ([b952e2a](https://github.com/paruff/uFawkesAI/commit/b952e2a93e117517e89e27f4e40eca270905dfc5))


### Docs

* **ai-sdlc:** add AI-DLC opt-in intent, spec and plan ([#218](https://github.com/paruff/uFawkesAI/issues/218)) ([#221](https://github.com/paruff/uFawkesAI/issues/221)) ([22132ef](https://github.com/paruff/uFawkesAI/commit/22132efd0a5e50253ee727b9634d50f1758b2149))
* **changelog:** add Keep a Changelog header and Unreleased section ([#211](https://github.com/paruff/uFawkesAI/issues/211)) ([c8cc640](https://github.com/paruff/uFawkesAI/commit/c8cc6404398e48d737f6bda6b0b6741534a6776b))
* **governance:** add CODE_OF_CONDUCT ([#209](https://github.com/paruff/uFawkesAI/issues/209)) ([93afc91](https://github.com/paruff/uFawkesAI/commit/93afc91d5dc5b211971883ae7df5950f63ecea57))
* **issue-templates:** add security vulnerability template ([#213](https://github.com/paruff/uFawkesAI/issues/213)) ([f4af6ef](https://github.com/paruff/uFawkesAI/commit/f4af6ef128ded7a87a351ea4fad2d8698a648444))
* **pr-template:** fix uFawkesAI PR template ([#212](https://github.com/paruff/uFawkesAI/issues/212)) ([fcc9642](https://github.com/paruff/uFawkesAI/commit/fcc964267ea0047158fe851d3928372d450d9978))
* remove AI slop and placeholder ambiguity from public docs ([#214](https://github.com/paruff/uFawkesAI/issues/214)) ([eed2a49](https://github.com/paruff/uFawkesAI/commit/eed2a4911d3870379df1d312d217c0c829d33962))


### Chores

* **image:** bump locked toolchain (2026-10-04) ([#189](https://github.com/paruff/uFawkesAI/issues/189)) ([955dfbc](https://github.com/paruff/uFawkesAI/commit/955dfbc27afd897682bf1df8a6d8c4fc514d15e4))

## [Unreleased]

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
