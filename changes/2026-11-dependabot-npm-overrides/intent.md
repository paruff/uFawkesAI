---
change: dependabot-npm-overrides
status: accepted         # draft → accepted (Product Owner) | rejected
author: ufawkes-bot@users.noreply.github.com
origin: idea             # idea | ticket | incident | review
ticket:                  # PROJ-123 if the project uses Jira
created: 2026-11-25
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-25
approved_sha: 851d373
---
# Intent: Override vulnerable transitive npm dependencies

## Problem

Seven Dependabot alerts (19, 24, 28, 29, 38, 41, 42) are open on `qs`, `minimatch`, `zod` and `effect`, and the three Dependabot npm update jobs fail on every push to main. Dependabot cannot fix them: a parent package pins each vulnerable version (Stryker through `typed-rest-client` and `minimatch`, the opencode plugin's exact `zod 4.1.8`, `bash-language-server`'s `zod` 3 and `editorconfig`'s `minimatch ~10.2.4`).

## Proposed outcome

npm `overrides` in the root, `opencode/` and `images/devsecops/node-ai/` manifests resolve each package to a patched version, so the alerts close and the update jobs stop failing.

## Affected users and systems

Maintainers; the baked `fawkes-space` ai image (`opencode/` and `node-ai/` are installed with `npm ci` into it) and the Stryker dev tooling at the root.

## Constraints

Only `overrides` and the regenerated lockfiles change; no tool is installed on the host; the image Trivy gate must pass; the fix must be reversible by reverting one commit.

## How we know it worked

`npm audit` is clean in the root, the image build and Trivy gate pass on both architectures, `bash-language-server` completes an LSP session on zod 4, and the Dependabot alerts close.

## Out of scope

Replacing `bash-language-server`; fixing the `opencode-antigravity-auth` Node import failure (it also fails on main); the lock-bump snapshot design.

## Open questions

None.
