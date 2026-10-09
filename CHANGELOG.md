# Changelog

All notable changes to uFawkesAI will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
