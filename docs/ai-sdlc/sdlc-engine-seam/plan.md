# Design: SDLC engine seam

Implements [spec.md](spec.md) (intent: [intent.md](intent.md)).

> **For agentic workers:** each phase is a goal issue on Project #7, and its
> child issues carry the steps. Use `superpowers:subagent-driven-development`
> or `superpowers:executing-plans` per child issue, and
> `superpowers:test-driven-development` for every code task.

## Architecture Overview

One TypeScript CLI, `scripts/sdlc-seam`, sits between everything in the repo
and whichever SDLC engine is installed. It reads `.sdlc-engine.json`, loads
one adapter, and answers the R1 subcommands. Gate verdicts (`gate`, `ci`) are
computed once in the CLI from the adapter's `status`, so no adapter
implements gate logic. Hooks (git, Claude Code, OpenCode) and CI call only
the CLI. Node ≥ 22.18 runs the `.ts` files directly (type stripping), so
there is no build step.

```
agents / commands / hooks / plugin / CI
              │  scripts/sdlc-seam <subcommand>
              ▼
   cli.ts ── gate + ci logic (engine-neutral)
              │  SdlcEngine interface (contract.ts)
       ┌──────┴───────┐
 adapters/fake.ts   adapters/morsadev.ts ── npx sdlc … --json
```

## Components

### Component: `scripts/seam/contract.ts`

- **Purpose:** the seam's types, and the only interface adapters implement.
- **Runtime/deployed:** no. It runs on workstations and in CI.

```ts
export type Stage = "intent" | "spec" | "plan" | "build" | "ship" | "incident";
export type GateStage = "intent" | "spec" | "plan";
export type GateState = "approved" | "rejected" | "pending";
export interface GateRecord { state: GateState; approver: string | null; commit: string | null }
export interface ChangeStatus {
  schema: 1; change: string; stage: Stage; artifactsDir: string;
  gates: Record<GateStage, GateRecord>;
}
export interface NextAction { schema: 1; change: string | null; stage: Stage | null; action: string }
export interface SdlcEngine {
  readonly name: string;
  version(): string;
  next(): NextAction;
  status(change: string): ChangeStatus | null;      // null = unknown change
  changesTouchedSince(base: string): string[];       // change slugs in the diff
  newChange(slug: string, title: string): string;     // returns artifactsDir
  approve(change: string, stage: GateStage): void;    // throws SeamError on refusal
  reject(change: string, stage: GateStage): void;
}
export class SeamError extends Error { constructor(msg: string, readonly exitCode: 1 | 2) }
```

### Component: `scripts/seam/cli.ts` plus the `scripts/sdlc-seam` wrapper

- **Purpose:** argument parsing, adapter loading (`config.ts`), and the
  engine-neutral `gate` and `ci` logic. `ci` reads code paths from
  `.artifact-chain-paths` (default `src/`).
- **Exit codes:** these are the ones in spec R1.

### Component: `scripts/seam/adapters/fake.ts`

- **Purpose:** the second engine that proves the seam (R3.2).
- **How it works:** artifacts live in `.sdlc-fake/<slug>/`, and an approval
  is a commit of `.sdlc-fake/<slug>/<stage>.gate` (`approved|rejected <email>`),
  read at `HEAD`. The record's commit is the last one touching that file.
  **Builder's call (changed from empty trailer commits):** an empty commit
  vanishes in `git merge --squash`, which Review Focus 2 forbids; a file
  survives. The approver is read from the file, not the commit author, since
  a squash rewrites the author.
  It refuses an approver whose email is in `botIdentities`, or who authored
  the stage's artifact. The approver identity is `git var GIT_AUTHOR_IDENT`,
  so the bot env vars of R6a take effect.
- **Branch → change:** `scripts/seam/branch.ts` maps `change/<slug>` (or the
  last segment of `<type>/<slug>`) to a change the engine knows. `gate <stage>`
  and `next` use it.
- **Deferred to phase 2/3:** the bot-PR exemption of R6.5 (dependabot, the
  image-lock bot) stays in the workflow, because the agent bot of D5 must
  *not* be exempt, and `ci` cannot tell them apart from a PR alone.

### Component: `scripts/seam/adapters/morsadev.ts`

- **Purpose:** adapter #1. It is the only file that names `sdlc` commands
  or `changes/` (R2.3).

### Component: `scripts/seam/setup.sh`

- **Purpose:** runs `npx sdlc init`/`sync`, then enforces the R4.1
  overrides: CLAUDE.md is a symlink, the engine's agents are installed as
  `sdlc-*`, the engine's Claude hooks are stripped, `core.hooksPath` is
  unset, and there is one skills copy. Running it twice is a no-op.

### Component: `.sdlc-engine.json`

```json
{ "engine": "morsadev", "version": "1.4.0",
  "botIdentities": ["ufawkes-bot@users.noreply.github.com"] }
```

The bot's name and email are the builder's call (R6a.4). Whatever is chosen
goes here, in both harness configs, and in the engine's refusal list.

### Component: `scripts/test-sdlc-seam.sh`

- **Purpose:** the conformance suite. `SEAM_ADAPTER=fake|morsadev` selects
  the engine, and each run happens in a throwaway git repo, following the
  pattern of `scripts/test-artifact-chain.sh`. The test cases are the
  scenario table under Verification Strategy.

## Tradeoffs

| Decision | Chosen | Rejected | Rationale |
| --- | --- | --- | --- |
| Seam language | TypeScript, no build | bash | Typed contract; the stack is already Node 22 |
| Gate logic home | CLI, derived from `status` | Per adapter | Adapters can't drift on verdicts |
| Fake engine storage | Commit trailers | JSON state file | Proves "commits are the record" (D3) without morsadev |
| Downstream safety | New workflow body only in the next major tag | Inputs or a fallback path | `artifact-chain.yml` has no inputs and runs the caller's scripts |
| Static analysis | Semgrep (decided in #361): `agent-ci.yml` SAST job gains `p/typescript` and `p/secrets` beside `p/ci` | CodeQL | Already in CI and runs in Docker; 0 findings in 72s on 288 files. CodeQL cannot run locally or in `fawkes-space`, so its results could not be checked before a PR |
| Mutation testing | Stryker `command` runner on `scripts/seam/**/*.ts`, `thresholds.break` 45 (#362) | Unit-level runner | First full run (fake adapter, 688 mutants, 62 min): 50.73%, so break = 50.73 - 5 = 45. `morsadev.ts` scores 4.8% because the fake run does not exercise it; raising that is follow-up work. The job mutates the whole tree on PRs that touch the seam and on pushes to `main`, so the floor always applies to the score it was set from |

## Governance Alignment

| Requirement | Design Decision | Status |
| --- | --- | --- |
| Hard Rule 3 (AGENTS.md) | Managed block added once with owner approval; CI drift check | COVERED (Needs human) |
| AI policy | `AI_STANCE.md` updated in the PR that adopts each of `@morsadev/sdlc`, Semgrep/CodeQL and Stryker | COVERED |
| Humans decide | Bot identity for agent commits; bot and self-approval refused (D5) | COVERED |
| Security | No tokens in files; the board mirror uses `GITHUB_TOKEN` | COVERED |

## Global Constraints

- Node `>=22.18` (the engine's floor). `package.json` `engines` is bumped to match.
- `@morsadev/sdlc` is pinned exactly to `1.4.0` in `devDependencies`. An upgrade is a PR that passes the conformance suite.
- The JSON output carries `"schema": 1`, with its schema in `.agents/schema/sdlc-seam.schema.json`.
- `gates_self_approval: false`.
- `CLAUDE.md` stays a symlink to `AGENTS.md`.
- Nothing outside `adapters/morsadev.ts` and `setup.sh` names `sdlc` or `changes/`.
- `pre-commit run --all-files` passes before every commit (Hard Rule 4).

## Review Focus

1. **A branch with no change, or two changes.** `gate` on a branch whose name
   maps to no change exits 2 with "no change for branch <b>", not 0. A PR
   touching two changes checks both. The tests belong to #343.
2. **An approval commit removed by a rebase or a squash.** After a squash
   merge, the gate must still read as approved on `main`. The suite runs
   `git merge --squash` and asserts that `gate` still passes. The test belongs
   to #342 (fake) and #347 (morsadev).
3. **The bot identity leaking into the human's terminal.** `git var
   GIT_AUTHOR_IDENT` in a plain shell must not be the bot. Parity checks only
   the harness configs. The test belongs to #350.
4. **`sdlc sync` rerun after a version bump.** It must not re-add the
   stripped hooks, the unprefixed agents or the CLAUDE.md file. The test
   runs `setup.sh` twice and asserts that the tree is clean. It belongs to
   #346.
5. **The engine is missing or `npx` is offline.** Every subcommand must exit
   2 with "engine <name> not installed: run npm ci", and never 0. The test
   belongs to #347.

## Implementation Sequence

| Phase | Goal issue | Child issues |
| --- | --- | --- |
| 0 | #340 Seam contract and fake engine | #341, #342, #343 |
| 1 | #344 morsadev adapter and install | #345, #346, #347, #348 |
| 2 | #349 Enforcement and agent identity | #350, #351, #352, #353 |
| 3 | #354 Retire the hand-built loop | #355 |
| 4 | #356 Superpowers and the board mirror | #357, #358, #359 |
| 5 | #360 Verification stack | #361, #362, #363 |
| 6 | #364 Downstream repos (separate intent) | filed when phase 5 closes |

## Verification Strategy

| Req | How it is proven | test_type | Command / CI job |
| --- | --- | --- | --- |
| R1 | Every subcommand and exit code; JSON validates against the schema | unit | `scripts/test-sdlc-seam.sh` |
| R3.1 | new → intent → approve → `gate` 0; reject → `gate` 1; `ci` fails on an unapproved plan | integration | `SEAM_ADAPTER=fake` and `SEAM_ADAPTER=morsadev` `scripts/test-sdlc-seam.sh` |
| R3.1a | bot-authored artifact plus human approval passes; bot approves → refused; human approves their own artifact → refused | integration | the same, both adapters |
| R3.3 | Both adapters run on PRs touching `scripts/seam/` | ci | `ci-quality.yml` › seam conformance |
| R4.1 | `setup.sh` twice leaves a clean tree (the committed AGENTS.md block is kept when only blank lines differ); CLAUDE.md is a symlink; no `sdlc hook` in settings; `core.hooksPath` unset | integration | `scripts/test-sdlc-seam-setup.sh` |
| R4.1 drift | The AGENTS.md block matches a fresh `sync` | ci | `agent-config-ci.yml` |
| R6.1–R6.4 | Commit and push blocked on an unapproved plan in each path; a `--no-verify` push is red | integration, live-system | `scripts/test-sdlc-seam-hooks.sh`; a throwaway PR |
| R6a | Parity check; a plain-shell identity is not the bot | unit | `scripts/check-harness-parity.sh` |
| R7 | Status transitions against a fixture `status --json` | unit | `scripts/test-board-mirror.sh` |
| R8 | One change completes in OpenCode and in Claude Code with the same verdicts | live-system | #359 |
| R9 | Semgrep/CodeQL and Stryker jobs run; Stryker meets its threshold | ci | `ci-quality.yml` |

Prerequisites for local verification: Node ≥ 22.18, `git`, `bash`, `jq`.
Run everything inside the `fawkes-space` devcontainer, and install nothing on
the host.
