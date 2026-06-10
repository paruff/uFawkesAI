# Skill: Token Budget

> **Load trigger:** `"load token-budget skill"`
> **DORA:** Cap 3 (Context Engineering)
> **Token cost:** Low (meta: about token cost itself)

## Purpose

Audit and manage the token footprint of agent sessions to stay within
AGENTS.md §4 budget protocols and avoid runaway Copilot billing.

## Token Cost Tiers (approximate — verify with current billing)

| Tier        | Use                                   | Context size   |
| ----------- | ------------------------------------- | -------------- |
| Low         | Routing, quick lookups, preflight     | < 8K tokens    |
| Medium      | Feature implementation, docs          | 8K–20K tokens  |
| High        | Complex refactors, full file rewrites | 20K–32K tokens |
| Over-budget | Multi-file architectural changes      | > 32K tokens   |

Note: these are approximate estimates. Actual token counts depend on model,
context management, and billing plan. Verify current rates at github.com/features/copilot
and anthropic.com/pricing before planning large agent workloads.

## Context Footprint Sources (in descending size order)

1. AGENTS.md (always-on) — target: ≤ 88 lines ≈ ~2K tokens
2. Loaded skill files — each ≈ 500–800 tokens
3. Files read from context index — varies by file size
4. Conversation history — grows each turn
5. PR diff being reviewed — varies

## Audit Protocol

Before a long session, estimate context size:

```bash
# Count lines in always-on context
wc -l AGENTS.md .agents/README.md

# Estimate token count (rough: 1 line ≈ 20–25 tokens)
echo "Estimated always-on tokens: $(($(wc -l < AGENTS.md) * 25))"

# Check which skills are loaded in this session
# (manual tracking — list them here)
```

## Cost Control Strategies

**Strategy 1 — Keep AGENTS.md lean**
Every line added to AGENTS.md costs tokens on every agent turn.
The 88-line target is a billing control, not just an aesthetic preference.
Offload project-specific details to skill files loaded on demand.

**Strategy 2 — Scope context files**
Do not read entire files when only a section is needed.
Instruct agents: "Read only the `services/` section of AGENTS.md §3"
rather than loading the full context index.

**Strategy 3 — One skill at a time**
Load only the skill file needed for the current task.
Do not pre-load all skills at session start.

**Strategy 4 — Checkpoint long sessions**
For sessions likely to exceed 20K tokens, create a checkpoint issue:
"Continue from: [state summary]" and start a fresh session.
Gemma 4 E4B at num_ctx 32768 will drift on chains > 4–5 steps.

**Strategy 5 — Use the right model**

- Routing, preflight, quick checks → local model (Gemma 4 E4B)
- Complex code generation → GitHub Copilot Business (Sonnet)
- Orchestration and planning → Claude Code via Anthropic API
- Never use Copilot Business for simple lookups — it costs per token.

## Weekly Token Audit

Run `npm run token-audit` (scripts/token-audit.sh) to see:

- Sessions in the last 7 days
- Estimated token cost per session
- Sessions that exceeded budget threshold
- Most expensive files by inclusion frequency

Report is written to `docs/METRICS.md` under the token-usage section.
