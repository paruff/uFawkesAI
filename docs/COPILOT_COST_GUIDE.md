# Copilot Cost Guide

> **Why this exists:** GitHub Copilot moved to token-based billing on June 1, 2026.
> Every agentic interaction now costs real money. This guide helps you get maximum
> value from your credits without bill shock.

---

## The New Billing Model in 60 Seconds

| What changed          | Detail                                                   |
| --------------------- | -------------------------------------------------------- |
| Old model             | Fixed premium requests per month                         |
| New model             | AI Credits — 1 credit = $0.01, billed by tokens consumed |
| **What's still FREE** | **Code completions (tab), Next Edit Suggestions**        |
| What costs credits    | Chat, Agent Mode, Edits, Code Review                     |

**Plan credit budgets:**

| Plan               | Price       | Included Credits | Effective budget                           |
| ------------------ | ----------- | ---------------- | ------------------------------------------ |
| Copilot Pro        | $10/mo      | $10              | ~1M cheap tokens OR ~50K expensive tokens  |
| Copilot Pro+       | $39/mo      | $39              | ~4M cheap tokens OR ~200K expensive tokens |
| Copilot Business   | $19/seat/mo | $19/seat         | Pool across team                           |
| Copilot Enterprise | $39/seat/mo | $39/seat         | Pool across org                            |

---

## The Three Cost Levers (In Order of Impact)

### 1. AGENTS.md / copilot-instructions.md Size — Biggest Lever

This file loads on **every single request**. Every line is billed every time.

```
226-line AGENTS.md × 1,000 requests/month × $0.0001/line ≈ $22.60/month wasted
80-line AGENTS.md  × 1,000 requests/month × $0.0001/line ≈ $8.00/month
```

**Target: keep AGENTS.md under 80 lines.** Details go in `.github/skills/`.

### 2. Mode Selection — 60–90% Savings Available

| Task                          | Wrong mode | Right mode | Savings   |
| ----------------------------- | ---------- | ---------- | --------- |
| "What does this function do?" | Agent Mode | Ask Mode   | ~70%      |
| "Fix this single bug"         | Agent Mode | Edit Mode  | ~40%      |
| "Implement this feature"      | Agent Mode | Agent Mode | — correct |
| "Review this file"            | Agent Mode | Ask Mode   | ~60%      |

### 3. Model Selection — Up to 10x Cost Difference

| Model tier                             | Cost  | Use for                            |
| -------------------------------------- | ----- | ---------------------------------- |
| GPT-4o mini / Haiku 4.5 / Gemini Flash | 1x    | Q&A, simple edits, docs            |
| GPT-4o / Claude Sonnet                 | 3–5x  | Feature implementation             |
| Claude Opus / GPT-5                    | 8–12x | Architecture, security review only |

---

## What Burns Credits Fast (Avoid These Patterns)

**Anti-pattern 1: Agent Mode for questions**

```
❌ "Agent: what does the auth service do?"    → ~$0.15 per question
✅ "Ask: what does the auth service do?"      → ~$0.02 per question
```

**Anti-pattern 2: Vague prompts that require clarification loops**

```
❌ "Fix the login"                            → 3–5 back-and-forth turns
✅ "Fix the null pointer in auth/login.ts:47" → 1 turn
```

**Anti-pattern 3: Unscoped Agent tasks**

```
❌ "Refactor the codebase"                    → indexes entire repo, ~$2–5
✅ "Refactor src/services/auth.ts to use the
    typed error pattern in src/utils/errors.ts" → ~$0.20
```

**Anti-pattern 4: Re-running the same agent task after a failure**

```
❌ Start new session, re-explain everything   → full context cost again
✅ Stay in session, correct the agent         → cached context, cheaper
```

---

## Worked Cost Examples

### Scenario A: Moderate Copilot Pro user ($10/month budget)

- 200 tab completions: **free**
- 10 Ask Mode questions on Sonnet: ~$0.20
- 5 single-file edits on GPT-4o mini: ~$0.15
- 2 feature implementations on GPT-4o: ~$1.50
- **Total: ~$1.85** — well within $10 budget ✅

### Scenario B: Heavy Agent Mode user (danger zone)

- 5 Agent Mode sessions on Opus, each touching 10 files: ~$3–5 each = **$15–25**
- 3 Copilot Code Reviews: ~$1.50 each (now burns Actions minutes too)
- **Total: $19–30** — blows $10 budget, likely blows $39 budget ⚠️

---

## How to Read Your Bill Before It Arrives

1. Go to **github.com → Settings → Billing → Copilot Usage**
2. Filter by model — find your top 3 cost drivers
3. Look for the heaviest Agent Mode sessions
4. Use `npm run token-audit` to see your `AGENTS.md` footprint

---

## Team Admin Controls (Business/Enterprise)

- Set **per-user budget caps** in org settings → Copilot → Policies
- Enable **credit pooling** so light users offset heavy users
- Run `npm run token-audit` weekly and share with the team
- Identify the 2–3 highest-spending developers — the conversation is "here's the cheaper pattern" not "stop using it"

---

## The Model Cost Routing Rule (One Sentence)

> Use the cheapest model that will reliably complete the task on the first attempt — a wrong answer that requires a retry is always more expensive than the premium model.

---

## Quick Reference Card

```
FREE:          Tab completion, Next Edit Suggestions
CHEAP (Ask):   Questions, explanations, small lookups
MEDIUM (Edit): Single-file changes, targeted fixes
EXPENSIVE:     Agent Mode multi-file, Code Review, Opus/GPT-5

AGENTS.md:     Keep under 80 lines — it's billed on EVERY request
Skills:        Load on demand only — free until referenced
.copilotignore: Excluded files = zero tokens, configure it
```

---

## Related Files

- `docs/MODEL_ROUTING_GUIDE.md` — decision tree for model/mode selection
- `.copilotignore` — files excluded from Copilot context (configure for your project)
- `scripts/token-audit.sh` — measure your AGENTS.md token footprint
- `docs/METRICS.md` — track AI credit burn rate as a seventh metric
