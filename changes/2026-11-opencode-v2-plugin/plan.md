---
change: opencode-v2-plugin
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# OpenCode 2.x gate plugin: plan

## Steps

1. Extract `guardBash`, add the 2.x default export (done, `4114737`).
2. Add the live test `scripts/test-opencode-live.sh` (done, `4114737`).

## Verification

- R6.3: `bash scripts/test-opencode-live.sh` (a real OpenCode 2.3.0 session is refused a commit)
- R6.3: `bash scripts/test-sdlc-seam-hooks.sh` (the 1.x named export still blocks)
