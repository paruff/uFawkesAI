---
change: dependabot-npm-overrides
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Override vulnerable transitive npm dependencies: spec

## Requirements

- R1. Root `package.json` overrides `qs` to `^6.16.1` and `minimatch` to `^11.0.1`, and `npm audit` reports no vulnerabilities.
- R2. `opencode/package.json` overrides `zod` to `4.6.7` and `effect` to `4.0.0-beta.103`.
- R3. `images/devsecops/node-ai/package.json` overrides `minimatch` to `^11.0.1` and `zod` to `^4.6.7`.
- R4. Each lockfile is regenerated and `npm ci` succeeds in each directory.
- R5. The image build and Trivy gate (`build-cde-space-image.yml`) pass on amd64 and arm64.

## Design

Use npm `overrides`, the mechanism the repo already uses (`toml`, `simple-git`). Pin `opencode/` exactly, as its other pins are exact; use caret ranges where the manifest already does. A parent's own range is overridden, so each override is a risk: `minimatch` moves a major (10 to 11) for Stryker and `editorconfig`, and `bash-language-server` moves from `zod` 3 to 4.

## Verification

- R1: `npm ci` and `npm audit` in the root; `stryker run --dryRunOnly` passes.
- R2: in Docker, `npm ci`, then the plugins import; the same import failure of `opencode-antigravity-auth` occurs on main.
- R3: in Docker, `npm ci`; an LSP session on `bash-language-server` (initialize, config change, open, hover) with no stderr.
- R4: `npm ci` in all three directories.
- R5: CI on the PR.

## Areas of concern

Supply chain and the image toolchain: the overrides apply to code baked into a published image. If a tool breaks on `zod` 4, drop that override and record a `.trivyignore` entry with a reason and an expiry.
