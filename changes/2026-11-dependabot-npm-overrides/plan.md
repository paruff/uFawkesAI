---
change: dependabot-npm-overrides
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# Override vulnerable transitive npm dependencies: plan

Already implemented on this branch in one commit (03214cc); this plan records it for approval.

1. Add the overrides from the spec to the three `package.json` files (R1 to R3).
2. Regenerate the three `package-lock.json` files with `npm install --package-lock-only` (R4).
3. Verify in the root and in Docker as listed in the spec, then open the PR (R5).

## Verification

- R1: audit clean, Stryker dry run passes.
- R2, R3: Docker checks pass (plugin imports, LSP session).
- R4: `npm ci` in each directory.
- R5: image gate green on the PR.
