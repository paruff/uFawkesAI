# Plan — remove AWS AI-DLC from the image

Status: owner decision, 2026-11-05. Reverses `aidlc-workflows` (recoverable from git history).

## Why

The owner has stopped using AI-DLC. The `ai` image carried it as an opt-in binary, off by default, along with its
own install path and release runtime. This template's intent → spec → plan chain stays the one lifecycle shipped.

## Changes

| File | Change |
| --- | --- |
| `images/devsecops/Dockerfile` | Remove the offline install step and `AIDLC_*` environment |
| `images/devsecops/tools.lock.json` | Remove the `aidlc` entry |
| `images/devsecops/install-tools.sh`, `scripts/image-lock-refresh.sh` | Remove `release-dir`, used only by AI-DLC |
| `README.md`, `docs/DEVCONTAINER.md` | Remove the opt-in description |
| `docs/ai-sdlc/aidlc-workflows/` | Remove |
| `docs/ai-sdlc/v2.3.0/{intent,plan}.md` | Note the decision; these are drafts |

Kept as history: `CHANGELOG.md`, and released plans that mention it.

## Verification Strategy

- `git grep -iE "aidlc|ai-dlc"` finds only `CHANGELOG.md`, the v2.2.0 and v2.3.0 docs, and this plan.
- `jq` parses `tools.lock.json`, and no entry uses `release-dir`.
- `scripts/test-image-lock-refresh.sh` and `scripts/test-artifact-chain.sh` pass.
- `pre-commit run --all-files` passes.
- CI builds the image and its smoke test passes.

## Risks

- Anyone using `aidlc` from this image loses it at the next image update. Pin the previous image tag to keep it.
