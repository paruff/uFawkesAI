# Specification — SDLC engine seam

Intent: [intent.md](intent.md)

## Approaches

| Option | What it is | Trade-off | Verdict |
| --- | --- | --- | --- |
| A. Adopt `@morsadev/sdlc` directly | Its CLI, `changes/` layout and generated files become the process layer | Least code; a stall or breaking change in a 1.x single-maintainer package means migrating again | Rejected |
| **B. Seam plus adapter** | uFawkesAI defines the contract; `@morsadev/sdlc` is adapter #1 | A little more up front; swapping engines later is one adapter plus a conformance run | **Chosen (owner)** |
| C. Keep the hand-built layer | Status quo | Rewrites every time the field moves; the problem in the intent | Rejected |

## Decisions already made (owner)

- D1. Approach B, the seam.
- D2. Downstream uFawkes* repos migrate in a later, separate phase.
- D3. **Commits are the record of approval; Project #7 mirrors them.** An
  approve commit moves the item to the next status, and a reject commit
  moves it back. The board is never read to decide a gate.
- D5. **Agents commit under a bot identity; self-approval stays off.**
  Commits from agent sessions (Claude Code and OpenCode) carry a distinct
  bot author, so their artifacts are authored by the bot and only the human
  can approve them. `gates_self_approval` is `false`.
- D4. The four agents stay as stage roles, AGENTS.md stays hand-owned, the
  engine writes artifacts to its own layout, and the OpenCode plugin shrinks
  to a thin shim (all proposed by Claude, accepted by owner).

## Requirements

### R1. The seam contract

A single CLI entry point, `scripts/sdlc-seam` (TypeScript, Node 22, run with
`node`). Agents, skills, commands, hooks, plugins and CI call **only** this.
It has these subcommands:

| Subcommand | Returns | Exit code |
| --- | --- | --- |
| `next [--json]` | The one next action and which stage it belongs to | 0 |
| `status <change> --json` | `{change, stage, artifactsDir, gates: {intent, spec, plan}: {state: approved\|rejected\|pending, approver, commit}}` | 0, or 2 if the change is unknown |
| `gate <change> <stage>` | Nothing on stdout | 0 if approved, 1 if not, 2 on error |
| `new <slug> --title <t>` | Path of the new artifacts dir | 0 / 2 |
| `approve` / `reject <change> <stage>` | Passes through to the engine, which refuses agents and bots | the engine's |
| `ci` | One check covering artifacts present and gates approved for the PR's changes | 0 pass, 1 fail |
| `engine` | The adapter name and engine version | 0 |

The JSON shape is versioned (`"schema": 1`) and described in
`.agents/schema/sdlc-seam.schema.json`.

### R2. The adapter

- R2.1 The adapter is chosen by `.sdlc-engine.json`, for example
  `{"engine": "morsadev", "version": "1.4.0"}`. The engine version is pinned
  exactly in `package.json` devDependencies.
- R2.2 The adapters live in `scripts/seam/adapters/<engine>.ts`, and
  each adapter exports one object that implements the contract.
- R2.3 The morsadev adapter maps the contract onto `npx sdlc` (using its
  `--json` output where it exists). It is the **only** file in the repo that
  names `sdlc` commands or the `changes/` path.

### R3. Conformance

- R3.1 `scripts/test-sdlc-seam.sh` runs the same scenario suite against any
  adapter in a throwaway git repo: new → intent written → approve → gate
  passes; an agent identity approving is refused; reject moves the gate
  back; `ci` fails on an unapproved plan.
- R3.1a Identity scenarios (D5): an artifact committed by the bot identity
  is approved by the human, which passes. The bot approving anything is
  refused. The human approving an artifact they authored themselves is
  refused.
- R3.2 A `fake` adapter (in-memory, commit-backed) passes the same suite.
  This is the proof that the seam is not morsadev-shaped.
- R3.3 Both adapters run in CI on every PR that touches `scripts/seam/`.

### R4. Engine install without layout collisions

- R4.1 The engine is installed with `sdlc init` on a branch, with the
  following overrides recorded in the plan:
  - `CLAUDE.md` stays a symlink to `AGENTS.md`. The engine must not replace
    it. If `sdlc sync` would write it, the adapter's setup step restores the
    symlink and `scripts/check-harness-parity.sh` fails if it is a regular
    file.
  - The engine's managed block in `AGENTS.md` is a one-time, owner-approved
    edit (Hard Rule 3). `sdlc sync` rewrites that block silently and never
    reports drift, so **we build the drift check**: CI runs `sync` into a
    temp copy and fails if the block differs from the committed one.
  - Generated loop skills land in `.agents/skills/sdlc-*`, which `.claude/skills`
    already symlinks to. The engine writes both paths with separate manifest
    entries, so the adapter's setup step makes sure only one physical copy
    results (it either disables the `.claude/skills` target or verifies
    the two paths resolve to the same files). The skills are gitignored or
    committed per R4.2, and never hand-edited.
  - **Our agents win on name collisions (Claude's call).** `sync` writes the
    engine's `verifier`, `spec-reviewer`, `simplifier` and `researcher` to
    `.agents/agents/` and `.claude/agents/`, and its `verifier` would overwrite
    ours. The adapter's setup step installs them as `sdlc-verifier`,
    `sdlc-spec-reviewer` and so on, and the conformance suite fails if
    `.agents/agents/verifier.md` is no longer ours.
  - **The engine's harness hooks are off (Claude's call).** `sync` with the
    `claude` agent merges `sdlc hook … --agent claude` entries into
    `.claude/settings.json`. Those would be a second gate engine, so they
    are disabled, and the only gate hooks are R6's. The builder finds the
    `agents` config that stops `sync` from writing them. If no config
    does, the adapter's setup step strips them, and a check fails if they
    come back.
  - **`core.hooksPath` is set explicitly (Claude's call).** `init` and `sync`
    set `core.hooksPath=.sdlc/git-hooks` when it is unset, and this repo
    leaves it unset. That would silently bypass all five pre-commit framework
    hook types. The setup step keeps the pre-commit framework in charge,
    and `scripts/preflight.sh` fails if `core.hooksPath` is set.
- R4.2 Whether generated skills are committed or regenerated on setup is
  the builder's call. The rule is that exactly one copy exists.

### R5. Retire the hand-built loop

All of these go, in one PR, after R3 passes:

- `scripts/check-artifact-chain.sh` and `scripts/test-artifact-chain.sh`:
  replaced by `sdlc-seam ci`.
- The loop parts of `.agents/commands/{plan,implement,ship,verify,tdd}.md`
  and their `.opencode/commands/` copies. Each command that survives
  becomes a one-paragraph pointer: "run `sdlc-seam next`, then load the
  stage's skill".
- The gate prose in the four agent files. Each agent says which stages it
  owns and calls the seam. It no longer describes the gates itself.

These stay: `scripts/check-*` that are not about the loop (links,
placeholders, secrets, DORA vocabulary, README claims), the eight repo
skills, the evals, and the DORA event scripts.

`.github/workflows/artifact-chain.yml` stays a reusable workflow, and its
body runs `sdlc-seam ci`. It has no inputs and runs the **caller's**
`scripts/`, so an unmigrated downstream repo would break on the new body.
**Version it instead (Claude's call):** the new body ships only in the next
major release tag. Downstream repos stay pinned to their current `v2.x` ref,
and phase 6 moves each one to the new major.

### R6. Enforcement in both harnesses

- R6.1 **Git hooks:** pre-commit (via the existing `.pre-commit-config.yaml`)
  and pre-push call `sdlc-seam gate` for the change on the current branch.
  The engine's own git hooks are disabled where they would duplicate this.
- R6.2 **Claude Code:** a PreToolUse Bash hook in `.claude/settings.json`
  blocks `git commit` and `git push` when `sdlc-seam gate <change> plan`
  fails. It reuses the existing commit matcher
  (`scripts/hooks/claude-pretooluse-secret-scan.js`).
- R6.3 **OpenCode:** `.opencode/plugins/ai-sdlc-hooks.ts` keeps its protected-path,
  format and secret-scan logic, and adds the same `sdlc-seam gate` call
  before commit and push, reusing its `GIT_COMMIT` regex. It holds no gate
  logic of its own.
- R6.4 **CI:** `sdlc-seam ci` runs as a required check through the CI
  Quality Gate. A `--no-verify` push is red.
- R6.5 **PRs with no change (Claude's call, keeping today's rules):** `ci`
  passes when the PR touches no code path (from `.artifact-chain-paths`,
  default `src/`). Bot-authored PRs (dependabot, the image-lock bot) are
  exempt as they are now. A PR that touches code paths without an approved
  change fails. The quick lane (`sdlc quick`) is the route for small fixes.

### R6a. Agent commit identity (D5)

- R6a.1 Both harnesses set `GIT_AUTHOR_NAME`, `GIT_AUTHOR_EMAIL`,
  `GIT_COMMITTER_NAME` and `GIT_COMMITTER_EMAIL` to the bot identity for
  agent sessions: `env` in `.claude/settings.json`, and the equivalent
  in the OpenCode config or plugin. The human's own terminal is untouched.
- R6a.2 The bot identity (a name and a noreply email) is listed in the
  engine's bot and agent refusal list, so it can never approve.
- R6a.3 `scripts/check-harness-parity.sh` fails if the two harnesses set
  different identities, or if either one sets none.
- R6a.4 The bot's exact name and email, and whether it is a real GitHub
  account or just a git identity, are the builder's call. Commit signing
  is out of scope for v1.

### R7. Board mirror (D3)

A workflow on push to any `change/*` branch (and on merge) reads
`sdlc-seam status --json` and sets the linked Project #7 item's Status:
plan approved → "Ready for agent"; awaiting a human gate → "Needs human"
with Gate set to the stage name; PR open → "Needs human" with Gate set to
"PR review". It writes to the board only, and is idempotent. The link from
a change to its issue is the issue number in the change's `intent.md`
front matter.

### R8. Superpowers in both harnesses

- R8.1 Claude Code: the Superpowers plugin is already installed at the
  user level. The template documents it in `SETUP.md`, which the engine's
  `init` scaffolds and phase 4 completes, and pins the version.
- R8.2 OpenCode: Superpowers is added to the `plugin` array in
  `opencode.json`, pinned to a tag.
- R8.3 Stage mapping. The agent files and the stage pointers in R5 name
  these. They are the only Superpowers skills the loop requires:

| Stage | Superpowers skill | Owner agent |
| --- | --- | --- |
| spec | `brainstorming` | planner |
| plan | `writing-plans` | planner |
| build | `test-driven-development`, `systematic-debugging` on failure | builder |
| review | `requesting-code-review`, then `receiving-code-review` | verifier |
| ship | `verification-before-completion`, `finishing-a-development-branch` | verifier → operator |

- R8.4 The engine's own `sdlc-build` loop and its `spec-reviewer` and
  `verifier` subagents may be used as tools by the owner agent. They do not
  replace the Superpowers skill at that stage. Where the two conflict, the
  Superpowers skill wins and the engine's state stays the record.

### R9. Verification stack

Two layers. Each item is adopted only if it runs in the `fawkes-space` image
and in CI:

| Layer | Tool | Gate |
| --- | --- | --- |
| Agent-side | `verification-before-completion` (Superpowers) | builder may not report done without command output |
| Agent-side | `requesting-code-review` plus the repo `/code-review` (Standards and Spec) | verifier runs both before ship |
| Deterministic | existing pre-commit, typecheck, lint, unit tests | unchanged |
| Deterministic | **Semgrep** (OSS rules, `p/typescript`, `p/secrets`) | CI, blocks on ERROR |
| Deterministic | **Stryker** mutation testing on `scripts/seam/` | CI, reported; blocks under a threshold the builder sets from the first run |
| Deterministic | `sdlc-seam ci` | required check |

CodeQL is the alternative to Semgrep. The builder picks one, not both, and
records why in the plan.

## Phases

Each phase is one GitHub goal issue on Project #7, with child issues
created from the plan.

| # | Goal | Exit criterion |
| --- | --- | --- |
| 0 | Seam contract and conformance suite, fake adapter | R1, R3 with the fake adapter green |
| 1 | morsadev adapter and engine install | R2, R4; conformance green on morsadev |
| 2 | Enforcement and agent identity in Claude Code, OpenCode, git and CI | R6, R6a; a `--no-verify` push is red; the bot cannot approve |
| 3 | Retire the hand-built loop | R5; no duplicate loop skill or script |
| 4 | Superpowers wiring and the board mirror | R7, R8; one change completes in both harnesses with the same verdicts |
| 5 | Verification stack | R9 |
| 6 | Downstream repos (later; separate intent) | each repo green on the new `artifact-chain.yml` |

## Security / policy constraints

- Approvals are commits by a human identity. The engine refuses agents and
  bots, and the conformance suite tests this (R3.1).
- No tokens are stored in files. The board mirror uses the workflow's
  `GITHUB_TOKEN` or an existing project secret.
- Adopting `@morsadev/sdlc`, Semgrep and Stryker means updating
  `AI_STANCE.md` in the same PR (ai-policy rule).
- The engine version is pinned exactly. Upgrading it is a PR that must pass
  the conformance suite.

## Flagged concerns

- F1. `@morsadev/sdlc` v1.4.0 has no OpenCode-specific integration. OpenCode
  is served through AGENTS.md and `.agents/skills`, and enforcement is our
  shim (R6.3). If a later version adds one, the adapter decides whether to
  use it.
- F2. `sdlc init` and `sdlc sync` may overwrite files the repo owns
  (CLAUDE.md, AGENTS.md, `.claude/settings.json`). Phase 1 runs it on a
  branch and the diff is reviewed by hand before anything is kept.
- F3. The engine's `tracker.provider` (`jira | github | linear`) covers GitHub
  Issues only and has no Projects v2 support, so R7 stays our own workflow.
- F4. The builder check came from reading `dist/sdlc.mjs`, not from running
  `init` or `sync`. Phase 1 confirms each R4.1 override against a real run.

## Left to the builder

- Internal layout of `scripts/seam/`, and how the change slug is
  derived from the branch name.
- Whether generated skills are committed (R4.2).
- Semgrep or CodeQL; the Stryker threshold.
- The exact `fake` adapter storage, as long as it is commit-backed.

## Phase 1 findings (engine 1.4.0, from real `init`/`sync` runs)

- **R4.2 decision: regenerate, do not commit.** The engine's skills, `.sdlc/` runtime files
  and CI templates are gitignored; `scripts/seam/setup.sh` regenerates them (one copy in
  `.agents/skills`, which `.claude/skills` symlinks to) and a second run leaves the tree
  clean (`scripts/test-sdlc-seam-setup.sh`). Committing them fought markdownlint, the
  license-header hook, yamllint and the orphan check. Committed: `.sdlc/config.json`,
  the AGENTS.md block and `SETUP.md`. `init`'s one-time scaffold (`evals/`, `lessons/`,
  `ops/`, `changes/_templates`) is not kept: `sdlc new` works without it.
- `.sdlc/config.json` sets `agents: ["agents-md"]`: the `claude` target is what writes
  the `sdlc hook` entries into `.claude/settings.json`, and `.claude/agents/verifier.md`.
  No stripping step is needed; `setup.sh` still checks and strips as a guard.
- `sync` keeps an existing `.agents/agents/verifier.md` ("conflict ... kept") unless
  `--force`; we never force. `researcher`, `simplifier` and `spec-reviewer` land unprefixed,
  with no collision, but `scripts/check-agents.sh` allows only our four agents, so
  `setup.sh` deletes them after each sync (not renamed to `sdlc-*`).
- `init` and `sync` set `core.hooksPath=.sdlc/git-hooks` in the shared `.git/config`
  (also from a `git worktree`). `setup.sh` unsets it; `preflight.sh` fails if it is set.
  Run spikes in a separate `git clone`, never a worktree.
- `CLAUDE.md` stayed a symlink in every run.
- **The engine reads identity from `git config user.name/email`, not `GIT_AUTHOR_*`.**
  The adapter passes the session identity through `GIT_CONFIG_COUNT` env config, with the
  email as the name so two people sharing a display name stay distinct. The engine's agent
  test is a fixed regex (`bot`, `claude`, `anthropic`, `cursor`, `codex`, `copilot`) with no
  config key, so the bot refusal list lives in the adapter (`botIdentities`), and the bot
  email `ufawkes-bot@…` also matches the engine's own regex.
- The engine exempts `intent` from its self-approval rule; the adapter enforces it for all stages.
- `status --json` prints one JSON object per line per change (`statuses` = `intent/spec/plan`);
  `next --json` has `kind`, `change`, `stage`, `command`, `message`. `sdlc new` writes only
  `intent.md`, so the adapter writes the spec and plan stubs the later gates need.
