# AI-Native SDLC Setup

This repository includes AI SDLC scaffolding for planning, implementation, verification, review, and shipping — working identically under **OpenCode** and **Claude Code**. Both CLIs are installed automatically in the devcontainer (`.devcontainer/devcontainer.json`).

## Structure

- `docs/ai-sdlc/`: artifact chain templates (`intent.md` → `spec.md` → `plan.md`)
- `.agents/commands/`: reusable slash commands — also visible at `.agents/commands/` (symlink, so there is exactly one copy of each)
- `.opencode/skills/`: on-demand skills, including the migrated testing/security/api-design/gitops rules (see below) — also visible at `.claude/skills/` (symlink)
- `.opencode/agents/`: focused review subagents
- `.opencode/plugins/ai-sdlc-hooks.ts`: OpenCode's edit protection, formatting, and compact-session reinjection hooks
- `.claude/settings.json`: Claude Code's equivalent hooks (same protected-path list, shared via `scripts/hooks/protected-paths.json`)
- `scripts/hooks/protected-paths.json`: the one thing shared between the two hook implementations above — see `docs/KNOWN_LIMITATIONS.md` (L-004) for what's *not* shared
- `scripts/check-harness-parity.sh`: verifies the two harnesses haven't drifted apart (symlinks intact, MCP server sets match, no reserved-name collisions); run in CI
- `scripts/dual-harness-smoke.sh`: the full smoke test proving one example each of MCP server, skill, hook, command, and rule works under both harnesses; run in CI
- `rules/`: now just a pointer — the rule content that used to live here moved to `.opencode/skills/*-rules/` (see `rules/README.md`)
- `scripts/AGENTS.md` (+ `scripts/CLAUDE.md` symlink): example of a nested, directory-scoped rule file — loads only when working under `scripts/`
- `opencode.json`: OpenCode's MCP server registrations
- `.mcp.json`: Claude Code's MCP server registrations (same servers as `opencode.json`, different schema — kept in sync by `scripts/check-harness-parity.sh`)

## Commands

- `/plan`: produce `intent.md`, `spec.md`, and `plan.md`
- `/implement`: execute `plan.md` phase-by-phase with checkpoints
- `/verify`: run typecheck/lint/test/build gates with evidence
- `/review-agents`: run focused reviewers using BASE/HEAD SHA context (renamed from `/review` — Claude Code has its own built-in `/review`, and this project command was silently shadowing it, the same class of bug as the `doctor`/`oc-health` collision)
- `/ship`: run pre-commit, commit, push, and open a PR
- `/oc-health` (OpenCode only): validate OpenCode config, models, plugins, and provider health. Claude Code has its own built-in `/doctor` for the same purpose — the two used to collide under one name; they're separate commands now.
- `/tdd`: enforce red-green-refactor flow with `/verify`

## MCP servers: default-on vs. opt-in

- **Default-on, no secret required**: `playwright`
- **Opt-in**: `context7` (`CONTEXT7_API_KEY`), `github` (`GITHUB_TOKEN`), `sentry` (`SENTRY_API_KEY`) — present in config but disabled by default in `opencode.json` (`"enabled": false`) until you add the key and flip it to `true`. `.mcp.json` has no equivalent disable flag for Claude Code; those three simply won't authenticate there until the corresponding environment variable is set. `serena` is also opt-in (`"enabled": false`) even though it needs no secret — it requires `uv`/`uvx` (Python), which the devcontainer doesn't install yet. Flip it to `true` once you've installed `uv` yourself, or once the devcontainer gets that install step added.

## Manual Configuration Required

1. Set API credentials in your environment, only if you want the opt-in MCP servers above:
   - `CONTEXT7_API_KEY`
   - `GITHUB_TOKEN`
   - `SENTRY_API_KEY`
2. Ensure formatter tools are installed and available in PATH:
   - `prettier` (TS/JS)
   - `black` (Python)
   - `gofmt` (Go)
   - `rustfmt` (Rust)
3. Use the project package manager consistently for dependency and script execution.
4. If you add or remove an MCP server, update both `opencode.json` and `.mcp.json` — `scripts/check-harness-parity.sh` fails CI if they drift apart.
