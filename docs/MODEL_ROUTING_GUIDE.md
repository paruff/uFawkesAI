# Model Routing Guide

> **Purpose:** Choose the right Copilot mode and model before starting any task.
> Wrong choices cost 5–10x more for identical output.
> This guide pays for itself on the first agent session.

---

## The Decision Tree

```
START: What do I need to do?
│
├── I have a QUESTION (explain, what is, how does, why)
│   └── → ASK MODE + cheapest model (Haiku / Flash / GPT-4o mini)
│       Savings: 60–90% vs Agent Mode
│
├── I need to EDIT ONE FILE
│   └── → EDIT MODE + mid-tier model (Sonnet / GPT-4o)
│       Savings: 30–50% vs Agent Mode
│
├── I need to implement a FEATURE (multiple files)
│   ├── Straightforward, clear spec
│   │   └── → AGENT MODE + mid-tier model (Sonnet / GPT-4o)
│   └── Complex, architectural, security-sensitive
│       └── → AGENT MODE + frontier model (Opus / GPT-5)
│           ⚠️ Confirm scope first — list files, get human approval
│
└── I need a CODE REVIEW
    ├── Quick smell-check on one file
    │   └── → ASK MODE + mid-tier (paste the file, ask for review)
    └── Full PR review
        └── → Copilot Code Review (burns Actions minutes + credits)
            Only use on PRs that are ready to merge
```

---

## Model Selection Table

| Task                | Model                   | Approx cost/task | Notes                       |
| ------------------- | ----------------------- | ---------------- | --------------------------- |
| Q&A, explanation    | GPT-4o mini / Haiku 4.5 | $0.01–0.05       | Default for questions       |
| Docs writing        | GPT-4o mini / Flash     | $0.02–0.08       | Cheap, perfectly capable    |
| Single-file edit    | GPT-4o / Sonnet         | $0.05–0.20       | Good quality/cost balance   |
| Feature (3–5 files) | GPT-4o / Sonnet         | $0.20–0.80       | Most common work            |
| Feature (10+ files) | Sonnet / Opus           | $0.50–2.00       | Confirm scope first         |
| Architecture review | Opus / GPT-5            | $1.00–5.00       | Reserve for real complexity |
| Security audit      | Opus / GPT-5            | $1.00–3.00       | Worth the cost here         |
| Rework rate > 20%   | Opus / GPT-5            | varies           | Fix AGENTS.md first         |

---

## Mode Cheat Sheet

### Ask Mode

- **Use for:** Questions, explanations, lookups, understanding code
- **Charged as:** Single inference, small context
- **Cost multiplier:** 1x (baseline)
- **When NOT to use:** Anything that requires file writes

### Edit Mode

- **Use for:** Targeted changes to 1–2 files with a clear spec
- **Charged as:** Moderate inference, focused context
- **Cost multiplier:** 2–3x Ask
- **When NOT to use:** Don't know exactly which file needs changing

### Agent Mode

- **Use for:** Multi-file features, refactors, anything requiring tool calls
- **Charged as:** Multiple inference rounds + tool calls + large context
- **Cost multiplier:** 5–20x Ask depending on scope
- **When NOT to use:** For questions. Ever.

---

## The Scope-Before-You-Start Protocol

Before every Agent Mode task, say this to the agent:

```
Before you start, tell me:
1. Which files will you read? (list them)
2. Which files will you write? (list them)
3. What is your plan in 2 sentences?

Then wait for my confirmation before proceeding.
```

This single habit reduces wasted Agent Mode runs by ~40%.

---

## Anti-Patterns and Their Cost

| What you typed         | Mode used | Actual cost            | Better approach                    |
| ---------------------- | --------- | ---------------------- | ---------------------------------- |
| "Explain auth service" | Agent     | ~$0.30                 | Ask Mode: ~$0.03                   |
| "Fix bugs" (vague)     | Agent     | ~$2.00 (3 retry loops) | Edit Mode with file:line: ~$0.15   |
| "Refactor everything"  | Agent     | ~$5+                   | Scope to one module, Agent: ~$0.50 |
| "Review my code"       | Agent     | ~$1.50                 | Ask Mode + paste code: ~$0.20      |

---

## The Local Model Strategy (Zero Credit Cost)

For low-stakes tasks, your Ollama + Gemma 4 E4B local setup is a legitimate
cost-avoidance tool:

| Task                              | Local (Gemma 4 E4B) | Copilot | Recommendation     |
| --------------------------------- | ------------------- | ------- | ------------------ |
| Drafting docs, changelogs         | ✅ Fine             | credits | Use local          |
| Explaining code snippets          | ✅ Fine             | credits | Use local          |
| Simple regex / one-liners         | ✅ Fine             | credits | Use local          |
| Multi-file feature implementation | ⚠️ Weaker           | credits | Use Copilot        |
| Architecture decisions            | ❌ Not reliable     | credits | Use Copilot + Opus |
| Security review                   | ❌ Not reliable     | credits | Use Copilot + Opus |

**Setup tip:** Point `OLLAMA_HOST` and use VS Code's Ollama extension or
OpenCode CLI for local tasks. Reserve Copilot credits for tasks requiring
frontier model quality.

---

## Dojo Connection

Learning the right habits before you code prevents expensive retries:

- **Yellow Belt Module 5** — CI fundamentals (know what you're building before you start)
- **Black Belt Module 17** — Platform as a Product (treating AI cost as a platform concern)

---

## Related Files

- `docs/COPILOT_COST_GUIDE.md` — full billing explanation
- `.github/skills/model-routing/SKILL.md` — agent-loadable version of this guide
- `docs/PROMPT_LIBRARY.md` — every prompt has a `Recommended model:` field
