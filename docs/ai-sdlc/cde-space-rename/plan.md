# Plan — CDE Space image workflow rename

1. `git mv` the build workflow; rename display names; update references in workflows, scripts, README, CONTRIBUTING, docs and comments.
2. Rename the concurrency group; leave `images/devsecops/` alone.

## Verification Strategy

| Criterion | How it is verified |
| --- | --- |
| REQ-001, REQ-002 names and file | `grep -n '^name:' .github/workflows/build-cde-space-image.yml .github/workflows/image-lock-bump.yml` |
| REQ-002 dispatch target exists | `grep -n 'gh workflow run' .github/workflows/image-lock-bump.yml` names `build-cde-space-image.yml`, which exists |
| REQ-003 no stale references | `git grep -n build-devsecops-images -- . ':!CHANGELOG.md' ':!docs/ai-sdlc'` is empty |
| REQ-004 behaviour unchanged | `actionlint .github/workflows/*.yml` is clean; the image workflow runs on this PR (it watches its own path) and passes both arches |
