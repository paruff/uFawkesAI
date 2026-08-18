# GitHub Copilot Billing Optimization — Handoff Prompt

## Copy and paste this into any AI agent (Copilot, Claude Code, Cursor, etc.) to kick off a billing audit and retrofit for any repo

---

## THE PROMPT

```
You are an expert GitHub Copilot cost optimization consultant with deep knowledge
of the June 2026 token-based billing change and DORA AI Capabilities best practices.

## Your Mission

Audit this repository and produce a complete GitHub Copilot token cost optimization
package. The goal is to reduce per-request token burn and monthly credit spend
without reducing AI agent effectiveness.

## Context: Why This Matters

As of June 1, 2026, GitHub Copilot switched from flat-rate premium requests to
token-based AI Credits (1 credit = $0.01). The biggest hidden cost driver is
always-on instruction files: AGENTS.md, .github/copilot-instructions.md, and
CLAUDE.md load on EVERY agent interaction. Every line is billed every request,
all month long.

Target: keep always-on context under 80 lines / ~320 tokens.
Details go in on-demand .github/skills/ files, loaded only when referenced.

## Step 1: Audit (Read These Files First)

Read and measure the following if they exist:
- AGENTS.md
- .github/copilot-instructions.md
- CLAUDE.md
- .copilotignore
- package.json (check for token-audit and preflight scripts)

For each instruction file, report:
- Line count
- Estimated token count (characters / 4)
- Estimated monthly cost at 20 agent interactions/day × 22 working days
  using current mid-tier model pricing (check your provider's rate card)
- Top 3 sections that could move to on-demand skills

## Step 2: Produce These Deliverables

### 2a. Lean AGENTS.md (always-on core)
Target: ≤ 80 lines. Must contain ONLY:
- AI policy (5–7 bullets: stance, data policy, human review requirement)
- Project identity (product name, stack, key constraints — 3 lines max)
- Five hard "never do" rules specific to THIS project
- Token budget protocol (scope-before-you-start for Agent Mode tasks)
- On-demand skills table (pointer to .github/skills/)
- Context files table (what to read before writing code)
- See Also links (cost guide, model routing guide, golden path)

Open with this comment block:
# TOKEN COST: This file loads on every Copilot/Claude Code/Cursor request.
# Every line is billed on every interaction. Keep it lean.
# Full details live in .github/skills/ — load them on demand only.

### 2b. On-Demand Skill Files
Create these in .github/skills/ — extract relevant content from existing
instruction files into each:

.github/skills/architecture/SKILL.md
- Layer structure diagram
- Dependency direction rules
- Hard architectural rules
- What to read before writing code
- PR architecture checklist

.github/skills/pr-contract/SKILL.md
- PM–Agent contract (who writes issues, who reviews, who merges)
- PR size limit and how it's enforced
- Required PR description block (AI-Assisted Review Block)
- What agents MAY do without asking
- What agents MUST ask before doing
- What agents must NEVER do
- Coding standards (naming, types, tests, commits, coverage)

.github/skills/metrics/SKILL.md
- All DORA metrics tracked, with targets and red/amber/green thresholds
- Measurement commands for each metric
- Rework rate formula with git commands
- AI Credit burn rate as 7th metric
- Monthly review ritual steps

.github/skills/model-routing/SKILL.md
- Mode decision table (Ask vs Edit vs Agent Mode)
- Model decision table (cheap/mid/frontier with examples)
- Scope check protocol (files to read, files to write, 2-sentence plan)
- Local model guidance if Ollama is available
- Link to docs/MODEL_ROUTING_GUIDE.md

Each skill file must open with:
> Load with: "[skill name] skill" in your prompt
> Example: "Use the architecture skill to implement this feature."

### 2c. .copilotignore
Produce a complete .copilotignore for this project's stack.
- Start with universal exclusions: node_modules/, lock files, build artifacts,
  coverage/, logs/, generated files, media files, .env files
- Add stack-specific exclusions based on what you find in the repo
  (e.g. Python: __pycache__/, *.pyc, .venv/  |  Go: vendor/, *.pb.go
   Java: target/, *.class, *.jar  |  .NET: bin/, obj/, *.dll)
- Add a comment at top explaining the token cost rationale
- Add a [PLACEHOLDER] section at bottom for project-specific generated files

### 2d. scripts/token-audit.sh
A bash script that:
- Measures line count and estimated tokens for all always-on context files
- Calculates estimated monthly credit cost at light/moderate/heavy usage
- Lists top 10 largest files in repo by size (Copilot context candidates)
- Checks .copilotignore exists and reports rule count
- Compares AGENTS.md token count against the 80-line target
- Outputs recommendations
- Supports --save flag to append results to docs/METRICS.md
- Is idempotent and safe to run on any repo

### 2e. docs/COPILOT_COST_GUIDE.md
A developer-facing guide covering:
- The new billing model in plain language (credits, what's free, what costs)
- Plan credit budgets table (Pro/Pro+/Business/Enterprise)
- The three cost levers in order of impact:
  1. Instruction file size (always-on context)
  2. Mode selection (Ask vs Agent)
  3. Model selection (cheap vs frontier)
- Anti-patterns with before/after cost examples
- Worked monthly cost scenarios for this project's typical usage patterns
- How to read the GitHub billing dashboard
- Team admin controls (budget caps, credit pooling)

### 2f. docs/MODEL_ROUTING_GUIDE.md
A decision guide covering:
- Mode decision tree (ASCII flowchart)
- Model selection table with cost multipliers and example tasks
- The scope-before-you-start protocol (exact text to paste to agent)
- Four most expensive anti-patterns with cost comparison
- Local model strategy if the team has Ollama available
- One-sentence routing rule

### 2g. .github/copilot-budget.md
Admin checklist covering:
- 3-step org setup (budget caps, credit pooling, Code Review policy)
- Weekly admin ritual with CLI commands
- How to have the "heavy user" conversation constructively
- Budget targets by team size
- Promotional credit period reminder if still active

### 2h. package.json additions
Add to scripts (create package.json if none exists):
"token-audit": "bash scripts/token-audit.sh",
"token-audit:save": "bash scripts/token-audit.sh --save"

## Step 3: Produce a Summary Report

After creating all files, produce a markdown summary:

# Copilot Billing Optimization — Summary

## Audit Results
| File | Before (lines) | After (lines) | Tokens saved/request |
|---|---|---|---|

## Estimated Monthly Savings
| Usage level | Before | After | Saving |
|---|---|---|---|
| Light (10 agent tasks/day) | $X | $Y | Z% |
| Moderate (20 agent tasks/day) | $X | $Y | Z% |
| Heavy (50 agent tasks/day) | $X | $Y | Z% |

## Files Created
[list with one-line description each]

## Remaining Manual Steps
[anything that requires human judgment to complete]

## Next: Validate
Run: npm run token-audit
Expected: AGENTS.md reported as LEAN (≤ 320 tokens)

## Constraints

- AGENTS.md must remain specific to THIS project — do not use generic placeholders
  where you can infer real values from the existing codebase
- Every [PLACEHOLDER] you leave must be clearly marked and explained
- Skill files must be self-contained — they are loaded independently
- Do not delete content from existing instruction files without moving it somewhere
- All bash scripts must be POSIX-compatible and work on macOS and Ubuntu
- Keep each deliverable focused — do not merge files

## Confirm Before Starting

Before writing any files, respond with:
1. Current always-on context: [line counts and estimated tokens per file]
2. Estimated current monthly cost at moderate usage: [$X]
3. Files you will create or modify: [list]
4. Estimated monthly cost after optimization: [$Y]
5. Estimated saving: [Z%]

Then wait for confirmation before proceeding.
```

---

## HOW TO USE THIS PROMPT

### In GitHub Copilot Agent Mode

1. Open your repo in VS Code
2. Switch to **Agent Mode** (not Ask or Edit)
3. Select a **mid-tier model** (not frontier/premium — this task doesn't need it)
4. Paste the prompt above
5. Review the Step 3 confirmation, then approve

### In Claude Code

```bash
cd your-repo
claude   # opens interactive session
# Paste the prompt
```

### In Cursor (Agent Mode)

- Cmd+I to open Composer
- Set to Agent mode
- Paste the prompt

---

## WHAT TO FILL IN BEFORE PASTING (Optional Customizations)

The prompt works as-is on any repo. If you want to give the agent more context,
prepend this block before the prompt:

```
## Project Context (Pre-filled)
- Stack: [e.g. "TypeScript · Next.js 15 · Supabase · Vercel"]
- Team size: [e.g. "4 developers"]
- Copilot plan: [e.g. "Business at $19/seat"]
- Current AGENTS.md size: [run: wc -l AGENTS.md]
- Existing .copilotignore: [yes / no]
- Ollama available locally: [yes / no]
- Primary OS: [macOS / Ubuntu / Windows]
```

---

## SEQUENCING FOR MULTIPLE REPOS

If you are retrofitting several repos, do them in this order for maximum ROI:

| Priority | Repo type                                       | Why                                 |
| -------- | ----------------------------------------------- | ----------------------------------- |
| 1        | Your most active repo (most agent interactions) | Highest daily savings               |
| 2        | Repos with the largest AGENTS.md                | Biggest per-request savings         |
| 3        | Team/shared repos                               | Multiplies savings across all users |
| 4        | Archived or low-activity repos                  | Low urgency                         |

Run `wc -l AGENTS.md .github/copilot-instructions.md` in each repo first.
Sort by line count descending. Start at the top.

---

## EXPECTED OUTPUT

A complete retrofit of a typical repo produces:

| Deliverable                           | Typical size  |
| ------------------------------------- | ------------- |
| AGENTS.md (lean core)                 | 80–90 lines   |
| .github/skills/architecture/SKILL.md  | 40–60 lines   |
| .github/skills/pr-contract/SKILL.md   | 60–90 lines   |
| .github/skills/metrics/SKILL.md       | 50–70 lines   |
| .github/skills/model-routing/SKILL.md | 40–50 lines   |
| .copilotignore                        | 60–80 lines   |
| scripts/token-audit.sh                | 120–150 lines |
| docs/COPILOT_COST_GUIDE.md            | 150–200 lines |
| docs/MODEL_ROUTING_GUIDE.md           | 100–130 lines |
| .github/copilot-budget.md             | 80–100 lines  |

**Typical result:** 40–60% reduction in always-on context tokens.
At moderate agentic use (20 tasks/day, 22 working days), this saves
$8–18/developer/month on mid-tier models — before any mode-routing improvements.

---

## REFERENCE

Based on the uFawkesAI DORA-aligned AI agent template.
Template: github.com/paruff/uFawkesAI
