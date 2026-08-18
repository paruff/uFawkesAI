# Model Routing Guide

> **Purpose:** Choose the right agent mode and model before starting any task,
> regardless of which agent host you're using (Copilot, Claude Code, Cursor,
> Codex, Gemini CLI, Windsurf, Devin — see the mapping table below).
> Wrong choices cost 5–10x more for identical output.
> This guide pays for itself on the first agent session.

---

## The Decision Tree

The four mode categories below are tool-agnostic. Map them to your specific
agent host using the table underneath.

```
START: What do I need to do?
│
├── I have a QUESTION (explain, what is, how does, why)
│   └── → READ-ONLY/QUESTION MODE + your host's fast/cheap tier
│       Savings: 60–90% vs agentic mode
│
├── I need to EDIT ONE FILE
│   └── → SINGLE-FILE EDIT MODE + your host's mid tier
│       Savings: 30–50% vs agentic mode
│
├── I need to implement a FEATURE (multiple files)
│   ├── Straightforward, clear spec
│   │   └── → AGENTIC/MULTI-FILE MODE + your host's mid tier
│   └── Complex, architectural, security-sensitive
│       └── → AGENTIC/MULTI-FILE MODE + your host's frontier/premium tier
│           ⚠️ Confirm scope first — list files, get human approval
│
└── I need a CODE REVIEW
    ├── Quick smell-check on one file
    │   └── → READ-ONLY/QUESTION MODE + mid-tier (paste the file, ask for review)
    └── Full PR review
        └── → your host's automated PR review feature (burns CI minutes + credits)
            Only use on PRs that are ready to merge
```

### Mode mapping by agent host

| Category             | GitHub Copilot       | Claude Code                            | Cursor            |
| --------------------- | ---------------------- | ----------------------------------------- | ------------------- |
| Read-only/question    | Ask Mode              | default chat (no file writes)            | Chat              |
| Single-file edit      | Edit Mode             | default with scoped request              | Composer (1 file) |
| Agentic/multi-file    | Agent Mode            | default agentic loop / Plan Mode         | Composer (Agent)  |
| Automated PR review   | Copilot Code Review   | `code-reviewer` agent / `/code-review`   | Bugbot / PR review |

Other hosts (Codex, Gemini CLI, Windsurf, Devin) map onto the same four
categories under their own naming — check their docs for the equivalent mode.

---

## Model Tier Selection Table

Every major agent host (Copilot, Claude Code, Cursor, Codex, Gemini CLI) offers
roughly three cost/capability tiers. Named models shift often enough that
pinning this guide to specific ones goes stale within months — route by tier
and check your host's current model list for which model fills each tier.

| Task                | Tier            | Relative cost/task | Notes                       |
| ------------------- | ---------------- | ------------------- | --------------------------- |
| Q&A, explanation    | Fast/cheap       | Lowest              | Default for questions       |
| Docs writing        | Fast/cheap       | Low                 | Cheap, perfectly capable    |
| Single-file edit    | Mid              | Moderate            | Good quality/cost balance   |
| Feature (3–5 files) | Mid              | Moderate            | Most common work            |
| Feature (10+ files) | Mid → frontier   | Moderate–high       | Confirm scope first         |
| Architecture review | Frontier/premium | Highest             | Reserve for real complexity |
| Security audit      | Frontier/premium | Highest             | Worth the cost here         |
| Rework rate > 20%   | Frontier/premium | Varies              | Fix AGENTS.md first         |

---

## Mode Cheat Sheet

### Read-only/question mode

- **Use for:** Questions, explanations, lookups, understanding code
- **Charged as:** Single inference, small context
- **Cost multiplier:** 1x (baseline)
- **When NOT to use:** Anything that requires file writes

### Single-file edit mode

- **Use for:** Targeted changes to 1–2 files with a clear spec
- **Charged as:** Moderate inference, focused context
- **Cost multiplier:** 2–3x read-only
- **When NOT to use:** Don't know exactly which file needs changing

### Agentic/multi-file mode

- **Use for:** Multi-file features, refactors, anything requiring tool calls
- **Charged as:** Multiple inference rounds + tool calls + large context
- **Cost multiplier:** 5–20x read-only depending on scope
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

For low-stakes tasks, a local model via Ollama (or similar) is a legitimate
cost-avoidance tool. Small local models are fine for drafting and mechanical
work but weaken fast on multi-file reasoning — pick whichever small model
your hardware runs well and validate it against your own tasks:

| Task                              | Local small model | Hosted agent | Recommendation           |
| --------------------------------- | ------------------ | ------------- | -------------------------- |
| Drafting docs, changelogs         | ✅ Fine            | credits       | Use local                 |
| Explaining code snippets          | ✅ Fine            | credits       | Use local                 |
| Simple regex / one-liners         | ✅ Fine            | credits       | Use local                 |
| Multi-file feature implementation | ⚠️ Weaker          | credits       | Use hosted agent           |
| Architecture decisions            | ❌ Not reliable    | credits       | Use hosted agent, frontier/premium tier |
| Security review                   | ❌ Not reliable    | credits       | Use hosted agent, frontier/premium tier |

**Setup tip:** Point `OLLAMA_HOST` and use VS Code's Ollama extension or
OpenCode CLI for local tasks. Reserve hosted-agent credits for tasks requiring
frontier/premium tier quality.

---

## Dojo Connection

Learning the right habits before you code prevents expensive retries:

- **Yellow Belt Module 5** — CI fundamentals (know what you're building before you start)
- **Black Belt Module 17** — Platform as a Product (treating AI cost as a platform concern)

---

## Related Files

- `docs/COPILOT_COST_GUIDE.md` — full billing explanation (GitHub Copilot users)
- `.agents/skills/model-routing/SKILL.md` — agent-loadable version of this guide
- `docs/PROMPT_LIBRARY.md` — every prompt has a `Recommended model:` field
