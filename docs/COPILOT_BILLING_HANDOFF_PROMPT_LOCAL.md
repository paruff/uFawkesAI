# Copilot Billing Handoff — Local Model Prompt (Gemma 4 E4B / Ollama)
#
# USE THIS WHEN: running Claude Code with Ollama + Gemma 4 E4B locally
# DOES NOT NEED: Copilot credits, internet connection, API keys
# PAIRS WITH:   COPILOT_BILLING_HANDOFF_PROMPT_SCRIPTS.md (run that with Copilot for the bash scripts)
#
# SETUP FIRST (one time):
#   ollama run gemma4:e4b
#   /set parameter num_ctx 32768
#   /save gemma4:e4b-32k
#   /bye
#
# THEN RUN:
#   OLLAMA_MODEL=gemma4:e4b-32k claude   # Claude Code pointed at local Ollama
#   # or open Continue.dev in VS Code with gemma4:e4b-32k configured
#   # Paste the prompt below

---

## PROMPT — PART A: AUDIT (run this first, one task)

```
Read these files and report only — do not write anything yet:

1. AGENTS.md (if exists)
2. .github/copilot-instructions.md (if exists)  
3. CLAUDE.md (if exists)
4. .copilotignore (if exists)
5. package.json scripts section (if exists)

For each file found, report:
- Line count
- Token estimate (character count divided by 4)
- The three largest sections by line count
- Whether it contains any [PLACEHOLDER] strings (list them)

Then report:
- Which of these files are MISSING
- Total always-on token estimate (sum of items 1-3)
- One sentence: what is the single biggest cost issue you see?

Do not create any files. Just report.
```

---

## PROMPT — PART B: LEAN AGENTS.md (one task, run after Part A)

```
Using what you read in the audit, rewrite AGENTS.md as a lean always-on core.

Rules you must follow:
- Maximum 80 lines total including blank lines and comments
- Open with this exact comment block (3 lines):
  # TOKEN COST: This file loads on every Copilot/Claude Code/Cursor request.
  # Every line is billed on every interaction. Keep it lean.
  # Full details live in .github/skills/ — load them on demand only.
- Include these sections only, in this order:
  1. AI Policy (5-7 bullets maximum)
  2. Project Identity (3 lines: product, stack, key constraints)
  3. Five Hard Rules (numbered list, one line each)
  4. Token Budget Protocol (4 lines: the scope-check before Agent Mode)
  5. On-Demand Skills table (markdown table, 5-6 rows)
  6. Context Files table (markdown table, 3-4 rows)
  7. See Also (bullet list of doc links, 5-6 items)
- Keep all [PLACEHOLDER] markers from the original — do not invent values
- Do not include architecture rules, PR contract details, or metrics formulas
  (those go in the skills files we will create next)
- Count your lines before finishing — if over 80, trim the longest section

Write the new AGENTS.md content only. No explanation.
```

---

## PROMPT — PART C: SKILL FILES (run once per skill — four separate tasks)

### C1 — Architecture Skill
```
Create the file .github/skills/architecture/SKILL.md

This file is loaded ON DEMAND by AI agents when explicitly referenced.
It must be self-contained — the agent will not have AGENTS.md context when reading it.

Open with exactly:
> **Load with:** "Use the architecture skill" in your prompt
> **Example:** "Use the architecture skill to implement this feature."

Then include these sections:
- Layer Structure: a simple diagram or table showing the project's layers
  and dependency direction (infer from the repo structure you read, or use
  [PLACEHOLDER] if you cannot determine it)
- Hard Architectural Rules: 5 numbered rules specific to this project
  (infer from existing AGENTS.md content, or use [PLACEHOLDER] rules)
- Before Writing Code: a table of 3-4 files to read first and what each teaches
- PR Architecture Checklist: 4-5 checkboxes
- DORA Basis: one sentence citing the DORA finding that motivates this skill

Maximum 60 lines. Write the file content only. No explanation.
```

### C2 — PR Contract Skill
```
Create the file .github/skills/pr-contract/SKILL.md

Open with exactly:
> **Load with:** "Use the pr-contract skill" in your prompt
> **Example:** "Use the pr-contract skill to prepare this PR."

Include these sections:
- PM-Agent Contract: 4-step numbered workflow (PM writes issue → assigned to agent
  → agent opens draft PR → human reviews and merges)
- PR Size Limit: state the limit in lines and what CI does on violation
- Required PR Description Block: a markdown code block showing the exact template
  agents must fill in (include: what does this PR do, what could go wrong,
  what tests cover this, architecture check, what I was not sure about,
  token cost note)
- What Agents MAY Do Without Asking: bullet list of 5-6 items
- What Agents MUST Ask Before Doing: bullet list of 5-6 items  
- What Agents Must NEVER Do: bullet list of 5-6 items
- Coding Standards: 4-5 bullets (infer from existing AGENTS.md or use [PLACEHOLDER])

Maximum 90 lines. Write the file content only. No explanation.
```

### C3 — Metrics Skill
```
Create the file .github/skills/metrics/SKILL.md

Open with exactly:
> **Load with:** "Use the metrics skill" in your prompt
> **Example:** "Use the metrics skill to interpret our rework rate."

Include these sections:
- DORA Metrics Tracked: a table with columns: Metric, Target, Red threshold, Command
  Include these 7 rows: Rework Rate, PR Revision Rate, CI Cycle Time,
  Review Turnaround, Failed Deployment Recovery Time, Reliability Trend,
  AI Credit Burn Rate
- Rework Rate Formula: the formula in plain text plus the git command to approximate it
- AI Credit Burn Rate: definition, what increasing burn rate signals (4 bullet points),
  how it correlates with rework rate
- Monthly Review Ritual: numbered list of 5 steps with the exact commands to run
- If Rework Rate exceeds 10%: numbered list of 5 actions to take

Maximum 70 lines. Write the file content only. No explanation.
```

### C4 — Model Routing Skill
```
Create the file .github/skills/model-routing/SKILL.md

Open with exactly:
> **Load with:** "Use the model-routing skill" in your prompt
> **Example:** "Use the model-routing skill before starting this task."

Include these sections:
- Mode Decision Table: 4-row markdown table (Task type | Mode | Why)
  Rows: Question/explanation → Ask Mode, Single-file edit → Edit Mode,
  Multi-file feature → Agent Mode, Architecture/security → Agent Mode + frontier
- Model Decision Table: 3-row table (Complexity | Model | Examples)
  Rows: Low → Haiku/Flash/GPT-4o mini, Medium → Sonnet/GPT-4o, High → Opus/GPT-5
- Scope Check Protocol: numbered list of 4 items the agent must state before
  starting any Agent Mode task, ending with "wait for human confirmation"
- Local Model Alternative: 3-row table (Task | Local Gemma 4 E4B | Copilot | Use)
  covering: docs/changelogs, simple explanations, multi-file features
- One-sentence routing rule (make it memorable)
- Link to docs/MODEL_ROUTING_GUIDE.md

Maximum 55 lines. Write the file content only. No explanation.
```

---

## PROMPT — PART D: .copilotignore (one task)

```
Create a .copilotignore file for this project.

Rules:
- Each excluded file or pattern removes it completely from Copilot's context
- Open with a 4-line comment block explaining this saves tokens on every request
- Organise into labelled sections with inline comments:
  1. Dependencies (node_modules/, vendor/, .venv/, __pycache__/ etc.)
  2. Lock files (package-lock.json, yarn.lock, pnpm-lock.yaml, go.sum etc.)
  3. Build outputs (dist/, build/, .next/, target/, *.class, *.jar etc.)
  4. Generated files (*.generated.ts, *.min.js, *.min.css, *.pb.go etc.)
  5. Coverage and test artifacts (coverage/, .nyc_output/, test-results/ etc.)
  6. IDE and tooling (.idea/, .DS_Store, *.swp etc.)
  7. Logs (*.log, logs/, npm-debug.log* etc.)
  8. Media and assets (*.png, *.jpg, *.ico, *.svg, *.pdf etc.)
  9. Data files (*.csv, fixtures/, migrations/*.sql etc.)
  10. Secrets (.env, .env.local, *.pem, *.key etc.)
  11. Stack-specific: look at the repo structure and add patterns relevant
      to the languages and frameworks you see
  12. Project-specific additions section with a [PLACEHOLDER] comment

End with a comment: # Review quarterly and add project-specific generated files

Write the .copilotignore content only. No explanation.
```

---

## PROMPT — PART E: COPILOT_COST_GUIDE.md (one task)

```
Create docs/COPILOT_COST_GUIDE.md

This is a developer-facing guide explaining the June 2026 GitHub Copilot
token-based billing change. Write it for a working developer, not an accountant.
Plain language. No jargon. Concrete numbers.

Include these sections in order:

1. The New Billing Model in 60 Seconds
   - A table: What changed | Detail
   - A table: Plan | Price | Included Credits | Effective budget
     (rows: Pro $10, Pro+ $39, Business $19/seat, Enterprise $39/seat)

2. The Three Cost Levers (In Order of Impact)
   - Lever 1: AGENTS.md / instruction file size
     Include a worked example showing line count × requests × price
     Show before (226 lines) and after (80 lines) monthly cost estimate
   - Lever 2: Mode selection
     A 4-row table: Task | Wrong mode | Right mode | Savings %
   - Lever 3: Model selection
     A 3-row table: Model tier | Cost | Use for

3. What Burns Credits Fast (four anti-patterns)
   For each: show the bad pattern with ❌ and cost, then the fix with ✅ and cost

4. Worked Monthly Cost Examples
   - Scenario A: Moderate user staying within $10/month budget
   - Scenario B: Heavy Agent Mode user exceeding budget

5. How to Read Your Bill Before It Arrives
   Numbered list of 3 steps

6. Team Admin Controls
   Bullet list: budget caps, credit pooling, Code Review policy

7. Quick Reference Card
   A code block with the key rules as a cheat sheet

8. Related Files
   Bullet list linking to: MODEL_ROUTING_GUIDE.md, .copilotignore,
   scripts/token-audit.sh, docs/METRICS.md

Write the full file content. No explanation before or after.
```

---

## PROMPT — PART F: MODEL_ROUTING_GUIDE.md (one task)

```
Create docs/MODEL_ROUTING_GUIDE.md

A practical decision guide for choosing the right Copilot mode and model.
Lead with this sentence: "Wrong choices cost 5-10x more for identical output."

Include these sections:

1. The Decision Tree
   Use ASCII art to show a branching flowchart:
   START → Is this a question? → Ask Mode
         → Edit one file? → Edit Mode
         → Multi-file feature? → Agent Mode (mid-tier)
         → Architecture/security? → Agent Mode (frontier only)

2. Model Selection Table
   8-row table: Task | Model | Approx cost/task | Notes
   Include rows for: Q&A, docs writing, single-file edit, feature (3-5 files),
   feature (10+ files), architecture review, security audit, rework rate >20%

3. Mode Cheat Sheet
   One section per mode (Ask / Edit / Agent):
   - Use for (3 examples)
   - Cost multiplier vs Ask Mode
   - When NOT to use

4. The Scope-Before-You-Start Protocol
   The exact text to paste to the agent before every Agent Mode task
   (formatted as a code block)

5. Anti-Patterns and Their Cost
   4-row table: What you typed | Mode used | Actual cost | Better approach

6. The Local Model Strategy
   A 6-row table: Task | Local (Gemma 4 E4B) | Copilot | Recommendation

7. Dojo Connection
   2 bullet points linking Dojo belt levels to cost-saving habits

8. Related Files

Write the full file content. No explanation before or after.
```

---

## PART G: Summary Checklist (run after all parts complete)

```
Review all the files you have created or modified in this session.

Produce a markdown table with these columns:
File | Status | Line count | [PLACEHOLDER] count | Notes

Then answer:
1. What is the new estimated always-on token count? (AGENTS.md only)
2. What was it before? 
3. Estimated % reduction in per-request context cost?
4. Which [PLACEHOLDER] values does the human need to fill in before committing?
5. Which bash scripts still need to be created? (flag for the Copilot scripts prompt)

Format as a clean markdown report. Nothing else.
```

---

## USAGE NOTES

### Run order (each is a separate Claude Code / Ollama session to stay within context)
1. Part A — Audit (5 min, read-only)
2. Part B — AGENTS.md (10 min)
3. Part C1 through C4 — one skill per session (5 min each)
4. Part D — .copilotignore (5 min)
5. Part E — COPILOT_COST_GUIDE.md (10 min)
6. Part F — MODEL_ROUTING_GUIDE.md (10 min)
7. Part G — Summary (5 min)

**Total: ~60 min, zero Copilot credits**

### Why separate sessions?
Gemma 4 E4B on 16 GB degrades after ~6K tokens of generation.
Each part above stays well under that limit.
Running them separately also means a bad generation in one part
does not corrupt the others.

### After running all parts locally, use the scripts prompt:
See: docs/COPILOT_BILLING_HANDOFF_PROMPT_SCRIPTS.md
That prompt handles: scripts/token-audit.sh, scripts/setup.sh hardening,
.github/workflows/placeholder-audit.yml, npm run preflight
Those require Copilot or Claude Code via API — not local Gemma 4.

### Validating output
After each part, run:
  wc -l <filename>          # check line count target was met
  grep -c PLACEHOLDER <filename>  # count unfilled placeholders
  bash -n scripts/*.sh      # syntax check any bash files
