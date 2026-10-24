# Agent Instructions — uFawkesAI

> Loaded on every request, so it stays one page. Detail lives in
> `docs/AGENT_REFERENCE.md` (CI gates, commit/hook rules, metrics, assertion
> runner) and `.agents/README.md` (full routing); load them when relevant.

## 1. AI Policy

- AI agents implement. Humans decide. No AI-generated code merges without human review.
- No customer PII in AI prompts.
- Questions: read-only/question mode. Multi-file work: agentic mode. Unsure which model or mode: `docs/MODEL_ROUTING_GUIDE.md`.
- More than 3 files: state scope, list files, ask "Confirm I should proceed?" first.

## 2. Project

**uFawkesAI:** an agent orchestration template for platform engineering (agents, skills, hooks, rules, multi-harness config).
**Stack:** TypeScript · Node 22 · GitHub Actions · OpenTelemetry.
**Harnesses:** OpenCode and Claude Code first-class; Codex and Gemini CLI compatible. All four run in `ghcr.io/paruff/fawkes-space` and are verified by `scripts/multi-harness-smoke.sh` (`docs/ai-sdlc/dual-harness-template/spec.md` R1). `CLAUDE.md`, `.cursorrules`, `.github/copilot-instructions.md` and `.cursor/rules/AGENTS.md` are symlinks to this file.

## 3. Five Hard Rules

1. No secrets, API keys, or credentials in any file.
2. No merging your own PR.
3. No modifying `AGENTS.md` (edit the source, never its symlinks); owner approval only.
4. `pre-commit run --all-files` passes before every commit.
5. Agent reports satisfy `.agents/assertions/minimal-report.yaml`.

## 4. Routing

Four agents, each a boundary that can block, write or change repo state:

| Task | Agent | Owns |
| --- | --- | --- |
| "Plan how to build X" | `@planner` | scope, tasks, dependency order |
| "Implement feature X" | `@builder` | code, tests, manifests (the working tree) |
| "Prove it works" / "Review" | `@verifier` | the verdict; the only agent that can block |
| "Ship / release / tag" | `@operator` | commit, PR, tag, publish; never merges |

`@planner → @builder → @verifier → @operator → human merges`. A feature's
`docs/ai-sdlc/<feature>/{intent,spec,plan}.md` comes first (`/plan`).
Load the Superpowers skill for the stage (`brainstorming`, `writing-plans`,
`test-driven-development`, `verification-before-completion`,
`systematic-debugging`, …). Always-on rules: `.agents/rules/`. Changing any
agent configuration: `.agents/skills/continuous-evals/SKILL.md`.

## 5. Commits

Conventional Commits, `type(scope): description` (≤72 chars). Types: `feat`,
`fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `perf`, `build`,
`revert`. False-positive secret: trailing `# pragma: allowlist secret`.

## 6. Workflow: board, gates, review

- UI changes: read [DESIGN.md](https://github.com/paruff/uFawkes.dev/blob/main/DESIGN.md) first (tokens, components, do and don't)
- Reviewing a PR: apply REVIEW.md (what is Important, verification, validation, security)

Status lives only on [Project #7](https://github.com/users/paruff/projects/7):
no status labels, no ✅ in plans. Routing labels say who does the work, not its
state. Work traces to `docs/ai-sdlc/<feature>/` intent → spec → plan; plans link
issues, never list tasks. Statuses, Gate, lifecycle and owner decisions:
[the board rules](https://github.com/paruff/uFawkes.dev/blob/main/docs/ai-sdlc/suite-release/plan.md#the-board-statuses-gates-and-moves).

```bash
# 1. Next item for an agent (label: the routing label you run as, claude-code or opencode)
gh project item-list 7 --owner paruff --limit 300 --query 'status:"Ready for agent" is:open label:opencode' \
  --format json --jq '.items | sort_by(.priority // "P9", .content.number) | .[:1][] | "\(.content.repository)#\(.content.number) \(.title)"'
# 2. Waiting on a human, and which gate each waits on
gh project item-list 7 --owner paruff --limit 300 --query 'status:"Needs human" is:open' \
  --format json --jq '.items[] | "\(.gate // "-")\t\(.content.repository)#\(.content.number) \(.title)"'
# Move: "In Progress" before you start; "Needs human" plus Gate "PR review" when the PR is up
gh project item-edit 7 --owner paruff --url <issue url> --field Status --value "In Progress"
```
