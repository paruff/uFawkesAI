# AI-Native SDLC Setup

This repository includes AI SDLC scaffolding for planning, implementation, verification, review, and shipping.

## Structure

- `docs/ai-sdlc/`: artifact chain templates (`intent.md` → `spec.md` → `plan.md`)
- `.opencode/commands/`: reusable OpenCode slash commands
- `.opencode/agents/`: focused review subagents
- `.opencode/plugins/ai-sdlc-hooks.ts`: edit protection, formatting, and compact-session reinjection hooks
- `rules/`: modular project rules for testing, security, API design, and GitOps
- `opencode.json`: MCP server registrations
- `.claude/commands`, `.claude/skills`, `.claude/settings.json`: Claude Code compatibility

## Commands

- `/plan`: produce `intent.md`, `spec.md`, and `plan.md`
- `/implement`: execute `plan.md` phase-by-phase with checkpoints
- `/verify`: run typecheck/lint/test/build gates with evidence
- `/review`: run focused reviewers using BASE/HEAD SHA context
- `/ship`: run pre-commit, commit, push, and open a PR
- `/doctor`: validate OpenCode config, models, plugins, and provider health
- `/tdd`: enforce red-green-refactor flow with `/verify`

## Manual Configuration Required

1. Set API credentials in your environment:
   - `CONTEXT7_API_KEY`
   - `GITHUB_TOKEN`
   - `SENTRY_API_KEY`
2. Ensure formatter tools are installed and available in PATH:
   - `prettier` (TS/JS)
   - `black` (Python)
   - `gofmt` (Go)
   - `rustfmt` (Rust)
3. Use the project package manager consistently for dependency and script execution.
4. Review `opencode.json` and remove MCP servers you do not need.
