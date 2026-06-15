---
name: metrics
description: "Legacy metrics skill — merged into dora-metrics. Use dora-metrics instead."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
deprecated: true
---

# Metrics Skill (Deprecated)

> **Use `dora-metrics` instead.** This skill is kept for reference.
> **Load this skill when:** running metrics, interpreting results, or discussing DORA performance.
> **Prompt example:** `"Use the metrics skill to interpret our rework rate."`

---

## DORA Metrics Tracked (DORA 2025)

| Metric                          | Target     | Red        | Command               |
| ------------------------------- | ---------- | ---------- | --------------------- |
| Rework rate                     | < 10%      | > 20%      | `npm run metrics`     |
| PR revision rate                | < 25%      | > 40%      | `npm run metrics`     |
| CI cycle time                   | < 4 min    | > 10 min   | `npm run metrics`     |
| Review turnaround               | < 24h      | > 72h      | manual                |
| Failed Deployment Recovery Time | < 1h       | > 4h       | manual                |
| AI Credit burn rate             | decreasing | increasing | `npm run token-audit` |

## Rework Rate Formula

```
rework_rate = (lines_substantially_changed_within_14_days_of_authoring / total_lines_authored) × 100
```

**What counts as rework:** lines reverted, substantially rewritten, or rolled back
within 14 days of the original commit.

**git command to approximate:**

```bash
git log --since="28 days ago" --until="14 days ago" --format="%H" | \
  xargs -I{} git diff {}^..{} --stat | grep -E "^\s+\d+ file"
```

## AI Credit Burn Rate (7th Metric)

Track: credits spent per merged PR, week over week.

**Target:** should _decrease_ over time as `AGENTS.md` improves and
developers learn model routing.

**Increasing burn rate signals:**

- AGENTS.md growing too large (run `npm run token-audit`)
- Developers using Agent Mode for questions
- Vague prompts causing retry loops
- Wrong model selection for task complexity

## Monthly Review Ritual (15 minutes)

1. `npm run metrics` → paste output into `docs/METRICS.md`
2. `npm run token-audit --save` → append token audit to `docs/METRICS.md`
3. Review `docs/TEAM_ARCHETYPE.md` — has archetype shifted?
4. If rework rate > 10%: fix `AGENTS.md` before next sprint
5. If credit burn increasing: review `docs/MODEL_ROUTING_GUIDE.md` with team

## Team Archetype

Run `docs/TEAM_ARCHETYPE.md` self-assessment before Phase 1, then quarterly.
Do NOT use "elite/high/medium/low" tier labels — use DORA 2025 archetype names.

## DORA Basis

"DORA 2025 added rework rate as a sixth metric and replaced performance tiers
with seven team archetypes. AI credit burn rate is a logical seventh metric
for AI-accelerated teams."
