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

- npm package renamed `copilot-starter-template` → `ufawkesai`
- The gitops image variant and the polyglot (Java) variant are removed
- The devcontainer image is `ghcr.io/paruff/fawkes-space` (bases `fawkes-space-ai`, `fawkes-core`), released by the template's own `vX.Y.Z` tag; `image-v*` tags are retired after v2.1.0

### Changed

- Devcontainer image pin updated to fawkes-space:2.0.0
- AGENTS.md updated with v2.0 contract

### Removed

- gitops image variant
- polyglot (Java) variant
- `image-v*` tags (retired after v2.1.0)
