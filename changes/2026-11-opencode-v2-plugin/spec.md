---
change: opencode-v2-plugin
status: draft
author: ufawkes-bot@users.noreply.github.com
---
# OpenCode 2.x gate plugin: spec

## Requirements

- R6.3 The plugin has a default export `{ id, setup }` that registers `ctx.tool.hook("execute.before")` for OpenCode 2.x and keeps the named export for 1.x. Both call one `guardBash`.

## Verification Strategy

| Req | Proof | Command |
| --- | --- | --- |
| R6.3 | live-system | `bash scripts/test-opencode-live.sh` |
| R6.3 | integration | `bash scripts/test-sdlc-seam-hooks.sh` (1.x export) |
