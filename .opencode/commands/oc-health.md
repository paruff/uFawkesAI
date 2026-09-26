---
description: Verify OpenCode configuration, model tiers, and provider health
agent: general
---

You are a configuration diagnostician for OpenCode. Perform a comprehensive
health check on this setup. The canonical config lives in this repo's
`opencode/` directory and is installed to `~/.config/opencode/` by
`opencode/sync.sh` — check the **installed** files (that is what opencode
boots from). Never print a full API key — first 8 characters only.

## 1. Check Core Configuration Files

Verify existence and syntax of:

- `~/.config/opencode/opencode.jsonc` (JSONC — validate by running
  `opencode debug config` and checking it exits 0)
- `~/.config/opencode/tiers.json` (pure JSON — `python3 -m json.tool <file>`)
- `~/.config/opencode/fallback.json` (pure JSON — `python3 -m json.tool <file>`)

For each file, report: exists (yes/no), valid syntax (yes/no).

## 2. Verify Provider Authentication

This setup runs on **free channels only**: Google models come from
`opencode-antigravity-auth`'s OAuth (Gemini CLI + Antigravity quotas), and the
`opencode` provider hosts free models — no paid API keys required.

Use `!echo $VARIABLE | head -c 8` (first chars only, never the full key):

- `GEMINI_API_KEY` — optional; OAuth is the primary path. Unset is fine (⚠ info).
- `NVIDIA_API_KEY` — leftover export in `~/.zshrc`; nvidia-proxy is REMOVED,
  so this key is unused → warn if set.
- `OPENROUTER_API_KEY` — openrouter fallback hops were removed → info only.
- `OPENCODE_ZEN_TOKEN` — unset is fine if auth is stored via `opencode auth`.

Also confirm `opencode-antigravity-auth` is registered (step 4) — without it
the `google/*` tier models have no quota source.

## 3. Validate Tier Model Availability

Parse the active preset in `tiers.json` and list each tier's model ID
(`@fast`, `@medium`, `@heavy`). For each ID:

- verify it is **declared** in the installed `opencode.jsonc` under
  `provider.<name>.models` (model definitions must live there — the auth
  plugin has no config hook; an undeclared model is a validation failure → ✗)
- live quota is not testable without spending requests — list the ID for
  manual verification if you cannot confirm it locally

## 4. Check Plugin Registration

Verify the `plugin` array in the installed `opencode.jsonc` contains:

- `opencode-tui-model-router`
- `opencode-auto-fallback`
- `opencode-antigravity-auth`
- `superpowers@git+https://github.com/obra/superpowers.git#<40-hex SHA>`

Flag as ✗: bare `"superpowers"` (abandoned npm stub), any
`superpowers-bridge.js` entry (retired), removed plugins (headroom, ghilteras,
nim-proxy/nvidia-proxy anything). Cross-check against `opencode debug info`
(what actually loaded) and report any diff.

## 5. Check Fallback Chain

Read the installed `fallback.json` and verify:

- `enabled` is `true`
- `defaultFallback` and every per-agent `fallback` array is non-empty
- every entry matches `provider/model` format (e.g. `google/gemini-2.5-flash`)
- free-only: every entry's provider is `google` or `opencode` (both free
  channels here) — anything else → ✗
- a tier's primary model repeated as its own first fallback → ⚠ (no-op hop)

## Output Format

Report a summary table with columns: Check | Status (✓/✗/⚠) | Details.
End with a final count: "X passed, Y warnings, Z failures."
