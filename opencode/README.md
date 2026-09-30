# opencode/ — versioned opencode configuration (single source of truth)

This directory (in **paruff/uFawkesAI**, moved from learn-languages) is the **canonical** global opencode configuration for every uFawkes-suite repo and the
machine it runs on.

## Where it gets installed

- **Devcontainer: nothing to do.** The `ufawkes-devsecops-ai` image bakes this
  config, its pinned plugins, the four uFawkesAI agents (planner, builder,
  verifier, operator; also in `~/.claude/agents`) and the tier subagents in at
  build time. Rebuild or pull the image to pick up a change.
- **Host machine: `sync.sh`, preview first.**

```bash
bash opencode/sync.sh          # preview: lists every file that would change, writes nothing
bash opencode/sync.sh --apply  # backs up ~/.config/opencode to ~/opencode-config-backup-*.tgz, then installs
```

`--apply` renders `__HOME__`, copies `opencode.jsonc`, `fallback.json`,
`package.json`, `package-lock.json`, the global `AGENTS.md`, `commands/*.md`
and `../.agents/agents/*.md` into `$OPENCODE_CONFIG_DIR` (default
`~/.config/opencode`), removes stale files from earlier layouts (`tiers.json`,
the retired superpowers bridge, a duplicate `skills/superpowers` link), runs
`npm ci` for the exact-pinned plugins, then `validate.sh`. It never touches
`~/.claude`. Restart OpenCode afterwards — config loads once at boot.

## Files

| File                  | Purpose                                                                                                     |
| --------------------- | ----------------------------------------------------------------------------------------------------------- |
| `opencode.jsonc`      | Main config: providers + model definitions, default/agent models, plugin list, skills paths, MCP servers    |
| `fallback.json`       | Per-agent fallback chains for `opencode-auto-fallback`                                                      |
| `AGENTS.md`           | Global stance loaded into every OpenCode session in every repo (repo `AGENTS.md` wins on specifics)        |
| `package.json`(+lock) | Exact-pinned plugin dependencies (git deps SHA-pinned)                                                      |
| `commands/doctor.md`  | Global `/doctor` command: config/tier/fallback health check (installed to `~/.config/opencode/commands/`)   |
| `sync.sh`             | Install script (above)                                                                                      |
| `validate.sh`         | Determinism invariants (below)                                                                              |

## Determinism

The same prompt must run on the same model every time, so a run can be
reproduced and evaluated:

- **No tier routing.** `opencode-tui-model-router` (with `tiers.json`) picked the
  model by LLM-classified rules; removed. Each agent names one model.
- **No silent fallback.** `opencode-auto-fallback` stays installed but
  `fallback.json` has `"enabled": false`. Turn it on per machine only if you
  accept that a quota error changes which model answered.
- **Pinned MCP servers.** `uvx --from <pkg>==<version>`, never a floating name.
- `validate.sh` enforces all three, and fails on a stale `tiers.json`.
- Automation (CI, `scripts/run-evals.sh`) should also set an empty
  `XDG_CONFIG_HOME` so no machine-local plugin changes the result.

## superpowers loads via a SHA-pinned git-spec entry

The `plugin` list references superpowers as
`superpowers@git+https://github.com/obra/superpowers.git#<40-hex SHA>` — the
same commit `package.json` pins. Never write the bare package name: on the npm
registry, `superpowers` is an abandoned **0.0.2 stub** that installs as a
silent no-op, so a bare `"superpowers"` entry "succeeds" while loading
nothing. The old `plugins/superpowers-bridge.js` shim (retired 2026-09-26)
was a workaround that pointed at an absolute installed path; the git-spec
entry supersedes it. obra's repo ships a clean
`export default { id, server }` that opencode
1.18.30's primary loader path accepts. Invariants (enforced by
`validate.sh`):

- the plugin list carries the git-spec entry, full-SHA-pinned (40 hex) —
  an absent or unpinned spec fails validation;
- bare `"superpowers"` never appears;
- no stale `plugins/superpowers-bridge.js` lingers in the config dir.

The `superpowers` npm dependency in `package.json` remains, but solely to
supply `skills.paths` (below) — it installs the skill files that the boot-time
scan reads.

Superpowers **skills** are registered file-side via `skills.paths` in
`opencode.jsonc`. Since the git-spec entry (2026-09-26) the plugin's
config-hook injection is _also_ picked up at boot, but the file-side entry
stays as the source of truth: it works with a cold plugin cache, and the
loader dedupes both registrations (no duplicate-name warnings).

## Model definitions live in opencode.jsonc (README step 3)

`opencode-antigravity-auth` has **no runtime config hook**: the Google models
tier routing depends on (Gemini CLI free models) must be declared under
`provider.google.models` in `opencode.jsonc`. A model referenced by a tier,
fallback chain, or default that isn't declared there is a validation failure.

## Removed things and re-add conditions

| Removed (2026-09-25)                                   | Why                                                                                                                           | Re-add when                                                    |
| ------------------------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| nim-proxy (local launchd, :3456)                       | SPOF; upstream NIM timed out on ~58% of requests; launchd job + plist + `~/.config/opencode/nim-proxy.*` deleted              | never — replaced by direct provider calls                      |
| headroom                                               | zero measurable savings (6 lifetime tool calls); incompatible with opencode 1.18.30; broken MCP shebang; config contradiction | a fixed upstream build, re-tested                              |
| `nvidia-proxy` provider                                | same nim-proxy SPOF                                                                                                           | never                                                          |
| `ollama` provider                                      | `192.168.1.194` unreachable (connection refused)                                                                              | the LAN box is back                                            |
| `opencode-go` (disabled provider)                      | not used                                                                                                                      | if a real need appears                                         |
| openrouter fallback hops                               | all free hops failing on test day (404 ZDR guardrail / empty responses)                                                       | re-test the free models, then add hops back to `fallback.json` |
| `google/gemini-2.5-pro`, `google/gemini-3-pro-preview` | API 404 "no longer available to new users" (non-retryable)                                                                    | never                                                          |

Live-tested working models (2026-09-25): `google/gemini-2.5-flash`,
`google/gemini-3-flash-preview`, `opencode/mimo-v2.6-flash-free`,
`opencode/nemotron-3.5-lightning-free`, `opencode/big-pickle`.
`google/gemini-3.1-pro-preview` is kept declared but quota-limited (429) —
promote it back to the `@heavy` primary when quota allows.

Note: Google free-tier quota (`generate_content_free_tier_requests`, limit 20)
is shared with Gemini CLI usage; expect occasional quota/demand errors — the
fallback chains absorb them (verified: chain-walked `2.5-flash` →
`3-flash-preview` on a live host session).

## validate.sh invariants

Fails the sync (and should gate CI if wired in) when any of these regress:

1. removed providers (`nvidia-proxy`, `ollama`) reappear
2. MCP server enabled while listed in `disabled_providers` (incl. stale headroom)
3. removed plugins reappear; bare `"superpowers"` sneaks in; the SHA-pinned
   `superpowers@git+…#<40-hex>` git-spec entry is absent or not full-SHA-pinned
4. default/agent models unqualified, on a removed provider, or unknown
5. plugin deps not exact-pinned; git deps not pinned to a full 40-hex SHA
   5b. stale `plugins/superpowers-bridge.js` still present in the config dir
6. fallback hops / `largeContextModel` unqualified or on removed providers
7. determinism: no model-router plugin, fallback disabled, MCP servers pinned,
   no stale `tiers.json`, global `AGENTS.md` installed

## Devcontainer parity

The image (`.devcontainer/Dockerfile`) bakes the pinned `opencode-ai@1.18.30`
(keep in sync with host Homebrew), uv/uvx + the serena cache, Playwright
browsers, and `~/.config/opencode` (via `sync.sh`). At container create,
`.devcontainer/post-create.sh` runs only `npm ci` (blocking), then detaches
`.devcontainer/setup-bg.sh` — config re-sync, browser top-up, missing-tool
guards — logged to `~/.devcontainer-setup.log` with a
`~/.devcontainer-setup.done` marker (check via
`.devcontainer/wait-setup.sh`). `postStartCommand` re-launches it, so a
failed background run retries on the next container start instead of
requiring a rebuild. `GEMINI_API_KEY` is injected via `containerEnv`
(opencode reads it as `GOOGLE_GENERATIVE_AI_API_KEY` for the Google provider).

## Host cleanup performed (2026-09-25)

- launchd job `com.philruff.nim-proxy` booted out; plist, `nim-proxy.mjs`,
  logs, and `/usr/local/bin/headroom` deleted; port 3456 free.
- `~/.config/opencode/_archive/` and `opencode-model-fallback.log` removed.
- Package cache: cruft deleted (~800 MB). **Kept** `opencode-cross-repo`
  (referenced by `uFawkes.dev/opencode.json`) and `opencode-auto-fallback`
  (referenced by `uFawkesObs/opencode.json`) — do not delete those caches
  while those repos still spec them.
- `NVIDIA_API_KEY` export remains in `~/.zshrc` (report-only; no config refs).
