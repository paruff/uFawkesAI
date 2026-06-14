# Copilot Billing Handoff — Scripts Prompt (Copilot / Claude Code via API)

#

# USE THIS WHEN: running GitHub Copilot Agent Mode or Claude Code with API

# RUN AFTER: COPILOT_BILLING_HANDOFF_PROMPT_LOCAL.md (the docs are already done)

# COST: Medium — use Sonnet/GPT-4o, NOT Opus (over-powered for this task)

#

# SCOPE CHECK (paste to agent before starting)

# Files I will read: scripts/, package.json, .github/workflows/

# Files I will write: scripts/token-audit.sh, scripts/setup.sh (update)

# .github/workflows/placeholder-audit.yml, package.json (scripts section)

# Plan: create two bash scripts and one workflow file, update package.json

# Complexity: medium

# Confirm I should proceed?

---

## CONTEXT FOR THE AGENT

The markdown documentation files for this billing optimization have already been
created locally (AGENTS.md, skill files, .copilotignore, cost guide, routing guide).

Your job is the bash scripts and CI workflow only.
Do not regenerate the markdown files — they are done.

Read these files before starting:

- scripts/setup.sh (existing — you will update it, not replace it)
- package.json (add scripts entries)
- AGENTS.md (understand the project context)

---

## TASK 1: scripts/token-audit.sh (create new file)

Create `scripts/token-audit.sh` — a bash script that measures the Copilot token
footprint of always-on context files and projects monthly cost.

Requirements:

- shebang: `#!/usr/bin/env bash`
- `set -euo pipefail` at top
- Support `--save` flag that appends results to docs/METRICS.md
- Coloured output: RED for high token counts, YELLOW for medium, GREEN for lean
  Use ANSI codes with a NO_COLOR fallback check
- Token estimation function: `estimate_tokens(file)` returns `$(wc -c < file) / 4`
  Add a comment: "4 chars ≈ 1 token (±15% of actual tokenizer)"
- Monthly cost function: `estimate_monthly_cost(tokens, requests_per_day)`
  Formula: `tokens × requests_per_day × 22_working_days × 0.000003`
  (represents Sonnet-class at $0.003/1K input tokens)
- Sections to output (each separated by a header line):
  1. "Always-On Context" — measure AGENTS.md, .github/copilot-instructions.md, CLAUDE.md
     For each: filename, tokens, lines, GREEN/YELLOW/RED status
     Thresholds: GREEN ≤ 320 tokens, YELLOW ≤ 800, RED > 800
     Show total always-on tokens
  2. "Monthly Credit Cost of Always-On Context"
     Show cost at light (10/day), moderate (20/day), heavy (50/day) usage
     Format: "Light use (10 tasks/day × 22 days): X credits = $Y"
  3. "Target Comparison"
     Target: 320 tokens (80 lines × 4 tokens/line)
     Show GREEN if within target, YELLOW with excess token count if over
  4. "Top 10 Largest Files"
     Use find to list top 10 files by size excluding .git/, node_modules/, media
     Show estimated tokens for each
  5. ".copilotignore Status"
     GREEN if exists with rule count, RED if missing
  6. "Recommendations"
     Conditional: if AGENTS.md > 800 tokens, show RED recommendation
     If .copilotignore missing, show YELLOW recommendation
     Always show blue pointers to COPILOT_COST_GUIDE.md and MODEL_ROUTING_GUIDE.md
- If --save flag: append a markdown table to docs/METRICS.md with date, token counts
- End with a styled footer line

Must work on: macOS (BSD tools) and Ubuntu (GNU tools)
Must be idempotent — safe to run multiple times
Must not fail if optional files (CLAUDE.md, .github/copilot-instructions.md) are absent

After writing, run: `bash -n scripts/token-audit.sh` to syntax check.

---

## TASK 2: scripts/setup.sh (review and update existing)

Read the existing `scripts/setup.sh`. Then update it to add any missing functionality.

Required functionality (add if missing, preserve if present):

- Coloured output with GREEN ✓, YELLOW ⚠, RED ✗ status indicators
- Create symlink: CLAUDE.md → AGENTS.md (if CLAUDE.md doesn't exist)
- Create symlink: .github/copilot-instructions.md → ../../AGENTS.md
  (create .github/ directory first if needed)
- Create .github/skills/ directory structure:
  mkdir -p .github/skills/{architecture,pr-contract,metrics,model-routing}
- Install git hooks from .github/hooks/ if that directory exists
- Check for required tools and warn if missing:
  node (warn if absent), git (error if absent), shellcheck (warn if absent)
- Validate .copilotignore exists (warn if missing, do not create)
- Validate no [PLACEHOLDER] strings remain in AGENTS.md (warn with count if any)
- Support --dry-run flag: show what would be done without doing it
- Support --codespace flag: skip interactive prompts, use non-interactive defaults
- Idempotent: if a symlink already exists and points to the right target, show ✓ and skip
- Print a final summary:
  "Setup complete. Run: npm run token-audit"
  List any warnings that need attention

Do NOT:

- Remove existing functionality from setup.sh
- Change the shebang or set flags at the top
- Add dependencies not already present in the repo

After updating, run: `bash -n scripts/setup.sh` to syntax check.
Then test: `bash scripts/setup.sh --dry-run`

---

## TASK 3: .github/workflows/placeholder-audit.yml (create new file)

Create a GitHub Actions workflow that scans for unfilled [PLACEHOLDER] strings.

Workflow requirements:

- name: "Placeholder Audit"
- triggers: push to main, pull_request targeting main
- single job: placeholder-check
- runs-on: ubuntu-latest
- steps:
  1. Checkout (actions/checkout@v4)
  2. Check for template mode marker:
     If file `.template` exists in repo root → set output `template_mode=true`
  3. Scan for placeholders:
     `grep -rn "\[PLACEHOLDER" --include="*.md" --include="*.sh" --include="*.yml" \
--exclude-dir=".git" --exclude-dir="node_modules" . || true`
     Save output to a variable
  4. Conditional result:
     If template_mode=true AND placeholders found: warn only (exit 0)
     Print: "⚠️ Template mode: X placeholders found (expected — fill before use)"
     If template_mode=false AND placeholders found: fail (exit 1)
     Print each file:line with the placeholder
     Print: "❌ X unfilled placeholders found. Run setup and fill before committing."
     If no placeholders found:
     Print: "✅ No unfilled placeholders found"

Use bash conditionals, not third-party actions.
Add a comment at top explaining the template vs fork distinction.

---

## TASK 4: package.json scripts (update)

Read the existing package.json. Add these entries to the "scripts" section
without removing existing entries:

```json
"token-audit": "bash scripts/token-audit.sh",
"token-audit:save": "bash scripts/token-audit.sh --save",
"setup": "bash scripts/setup.sh",
"setup:dry-run": "bash scripts/setup.sh --dry-run"
```

If package.json does not exist, create a minimal one:

```json
{
  "name": "ufawkesai",
  "version": "1.0.0",
  "description": "DORA-aligned AI agent starter template",
  "scripts": {
    "token-audit": "bash scripts/token-audit.sh",
    "token-audit:save": "bash scripts/token-audit.sh --save",
    "setup": "bash scripts/setup.sh",
    "setup:dry-run": "bash scripts/setup.sh --dry-run"
  },
  "license": "MIT"
}
```

---

## VALIDATION (run these after all four tasks)

```bash
# Syntax check all scripts
bash -n scripts/token-audit.sh && echo "token-audit.sh: OK"
bash -n scripts/setup.sh && echo "setup.sh: OK"

# Dry run setup
bash scripts/setup.sh --dry-run

# Run token audit
bash scripts/token-audit.sh

# Validate workflow YAML
# (if yamllint available)
yamllint .github/workflows/placeholder-audit.yml

# Check package.json is valid JSON
node -e "require('./package.json')" && echo "package.json: valid"
```

Report the output of each validation command.
If any fail, fix them before finishing.

---

## WHAT TO REPORT WHEN DONE

Produce a summary with:

1. Files created/modified (list with line counts)
2. Output of `bash scripts/token-audit.sh` (full output)
3. Output of `bash scripts/setup.sh --dry-run` (full output)
4. Any warnings or issues found during validation
5. Next step: "Commit with: git add -A && git commit -m 'feat: add token-audit and harden setup.sh (COST-001, COST-005, AI-001, AI-007)'"
