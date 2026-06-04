#!/usr/bin/env bash
# =============================================================================
# uFawkesAI — First-Impression Verification Script
# Usage: npm run verify  OR  bash scripts/verify.sh
# Checks all 5 layers: repo health, token baseline, scripts, CI, visitor journey
# Exit code 0 = all checks passed. Non-zero = at least one failure.
# =============================================================================

set -euo pipefail

# ── Colours ──────────────────────────────────────────────────────────────────
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
RESET='\033[0m'

PASS="${GREEN}✓${RESET}"
WARN="${YELLOW}⚠${RESET}"
FAIL="${RED}✗${RESET}"
INFO="${CYAN}ℹ${RESET}"

# ── Counters ─────────────────────────────────────────────────────────────────
PASSES=0
WARNINGS=0
FAILURES=0

pass()  { echo -e "  ${PASS} $1"; ((PASSES++));   }
warn()  { echo -e "  ${WARN} $1"; ((WARNINGS++)); }
fail()  { echo -e "  ${FAIL} $1"; ((FAILURES++)); }
info()  { echo -e "  ${INFO} $1"; }
section() { echo -e "\n${BOLD}${CYAN}── $1 ${RESET}$(printf '─%.0s' $(seq 1 $((54 - ${#1}))))${RESET}"; }

# ── Header ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  uFawkesAI First-Impression Verification — $(date +%Y-%m-%d)${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${RESET}"

# =============================================================================
# LAYER 1 — REPO HEALTH
# =============================================================================
section "Layer 1: Repo Health"

# Required root files
for f in AGENTS.md README.md CONTRIBUTING.md CHANGELOG.md LICENSE SECURITY.md \
          CLAUDE.md .copilotignore package.json; do
  if [[ -f "$f" ]]; then
    pass "$f exists"
  else
    fail "$f MISSING"
  fi
done

# Symlinks resolve correctly (not double-counted as separate files)
section "  Symlinks"
for link in CLAUDE.md .github/copilot-instructions.md .cursorrules; do
  if [[ -L "$link" ]]; then
    target=$(readlink "$link")
    if [[ -e "$link" ]]; then
      pass "$link → $target (resolves)"
    else
      fail "$link → $target (BROKEN — target missing)"
    fi
  elif [[ -f "$link" ]]; then
    warn "$link exists but is a real file, not a symlink — run ./scripts/setup.sh"
  else
    fail "$link missing — run ./scripts/setup.sh"
  fi
done

# .github/skills directory
section "  On-demand Skills"
SKILLS_DIR=".github/skills"
if [[ -d "$SKILLS_DIR" ]]; then
  skill_count=$(find "$SKILLS_DIR" -name "SKILL.md" | wc -l | tr -d ' ')
  if [[ "$skill_count" -ge 1 ]]; then
    pass "$SKILLS_DIR/ present with $skill_count skill file(s)"
  else
    warn "$SKILLS_DIR/ exists but contains no SKILL.md files"
  fi
else
  fail "$SKILLS_DIR/ missing — on-demand skills not configured"
fi

# Placeholder audit
section "  Placeholder Audit"
placeholder_count=$(grep -rn "\[PLACEHOLDER" --include="*.md" . \
  2>/dev/null | grep -v node_modules | grep -v ".git" | wc -l | tr -d ' ')
if [[ "$placeholder_count" -eq 0 ]]; then
  pass "No unfilled [PLACEHOLDER] strings found"
else
  fail "$placeholder_count unfilled [PLACEHOLDER] strings remain:"
  grep -rn "\[PLACEHOLDER" --include="*.md" . \
    2>/dev/null | grep -v node_modules | grep -v ".git" \
    | head -10 | while read -r line; do info "  $line"; done
fi

# AGENTS.md line count
section "  AGENTS.md Size"
agents_lines=$(wc -l < AGENTS.md | tr -d ' ')
if [[ "$agents_lines" -le 100 ]]; then
  pass "AGENTS.md is $agents_lines lines ✓ LEAN (≤100)"
elif [[ "$agents_lines" -le 250 ]]; then
  warn "AGENTS.md is $agents_lines lines — approaching limit (target ≤100)"
else
  fail "AGENTS.md is $agents_lines lines — exceeds 250-line warning threshold"
fi

# Key docs exist
section "  Key Documentation"
for doc in docs/COPILOT_COST_GUIDE.md docs/MODEL_ROUTING_GUIDE.md \
           docs/METRICS.md docs/GOLDEN_PATH.md \
           docs/COPILOT_BILLING_HANDOFF_PROMPT_LOCAL.md \
           docs/COPILOT_BILLING_HANDOFF_PROMPT_SCRIPTS.md; do
  if [[ -f "$doc" ]]; then
    pass "$doc"
  else
    fail "$doc MISSING"
  fi
done

# =============================================================================
# LAYER 2 — TOKEN BASELINE (symlink-aware)
# =============================================================================
section "Layer 2: Token Baseline (Symlink-Aware)"

# Resolve unique files only — don't double-count symlinks
declare -A seen_inodes
always_on_tokens=0
always_on_lines=0

TOKEN_FILES=(AGENTS.md CLAUDE.md .github/copilot-instructions.md)

for f in "${TOKEN_FILES[@]}"; do
  if [[ ! -e "$f" ]]; then
    warn "$f not found — skipping token count"
    continue
  fi

  # Get inode to detect symlinks pointing to same file
  inode=$(stat -f "%i" "$f" 2>/dev/null || stat -c "%i" "$f" 2>/dev/null)

  if [[ -n "${seen_inodes[$inode]:-}" ]]; then
    info "$f → symlink to ${seen_inodes[$inode]} (not double-counted)"
    continue
  fi
  seen_inodes[$inode]="$f"

  lines=$(wc -l < "$f" | tr -d ' ')
  # Approximate: 1 token ≈ 4 chars (conservative for markdown)
  chars=$(wc -c < "$f" | tr -d ' ')
  tokens=$(( chars / 4 ))
  always_on_tokens=$(( always_on_tokens + tokens ))
  always_on_lines=$(( always_on_lines + lines ))
  pass "$f — ~${tokens} tokens, ${lines} lines (unique)"
done

echo ""
echo -e "  ${BOLD}Total always-on (deduplicated): ~${always_on_tokens} tokens${RESET}"

# Monthly cost estimates (1 token = $0.000001, 1 credit = $0.01)
# Copilot uses input + output tokens; estimate ~2x for round-trip
round_trip=$(( always_on_tokens * 2 ))
light=$(( round_trip * 10 * 22 / 10000 ))
moderate=$(( round_trip * 20 * 22 / 10000 ))
heavy=$(( round_trip * 50 * 22 / 10000 ))

echo ""
echo -e "  Monthly always-on cost estimate:"
printf "  %-40s %d credits = \$%.2f\n" "Light  (10 tasks/day × 22 days):" "$light" "$(echo "$light / 100" | bc -l)"
printf "  %-40s %d credits = \$%.2f\n" "Moderate (20 tasks/day × 22 days):" "$moderate" "$(echo "$moderate / 100" | bc -l)"
printf "  %-40s %d credits = \$%.2f\n" "Heavy  (50 tasks/day × 22 days):" "$heavy" "$(echo "$heavy / 100" | bc -l)"

if [[ "$always_on_lines" -le 100 ]]; then
  pass "Always-on line count: ${always_on_lines} ✓ within 100-line target"
else
  warn "Always-on line count: ${always_on_lines} — exceeds 100-line target by $((always_on_lines - 100)) lines"
fi

# Top 10 largest files Copilot might pull in
section "  Top 10 Largest Context Candidates"
echo -e "  ${YELLOW}(Files not in .copilotignore that Copilot may load)${RESET}"
if command -v wc &>/dev/null; then
  find . -name "*.md" -o -name "*.sh" -o -name "*.yml" -o -name "*.json" \
    2>/dev/null \
    | grep -v node_modules | grep -v ".git" | grep -v package-lock \
    | xargs wc -c 2>/dev/null \
    | sort -rn \
    | grep -v " total$" \
    | head -10 \
    | while read -r size filepath; do
        tokens=$(( size / 4 ))
        printf "  %6d tokens  %s\n" "$tokens" "$filepath"
      done
fi

# =============================================================================
# LAYER 3 — SCRIPTS EXECUTE
# =============================================================================
section "Layer 3: Scripts Health"

for script in scripts/setup.sh scripts/token-audit.sh scripts/weekly-metrics.sh; do
  if [[ ! -f "$script" ]]; then
    fail "$script MISSING"
    continue
  fi
  if [[ ! -x "$script" ]]; then
    fail "$script exists but is NOT executable — run: chmod +x $script"
    continue
  fi
  # Syntax check without executing
  if bash -n "$script" 2>/dev/null; then
    pass "$script — executable, syntax OK"
  else
    fail "$script — syntax error detected"
    bash -n "$script" 2>&1 | head -5 | while read -r line; do info "  $line"; done
  fi
done

# shellcheck if available
if command -v shellcheck &>/dev/null; then
  section "  Shellcheck"
  sc_issues=0
  for script in scripts/*.sh; do
    if shellcheck -S warning "$script" 2>/dev/null; then
      pass "shellcheck $script — clean"
    else
      warn "shellcheck $script — warnings found (run shellcheck manually)"
      ((sc_issues++))
    fi
  done
else
  warn "shellcheck not installed — skipping lint (brew install shellcheck)"
fi

# npm scripts defined
section "  npm Scripts"
for cmd in token-audit preflight metrics verify; do
  if node -e "const p=require('./package.json'); process.exit(p.scripts['$cmd']?0:1)" 2>/dev/null; then
    pass "npm run $cmd — defined"
  else
    warn "npm run $cmd — NOT defined in package.json"
  fi
done

# =============================================================================
# LAYER 4 — CI WORKFLOWS
# =============================================================================
section "Layer 4: CI Workflow Syntax"

workflow_count=0
workflow_errors=0

if [[ -d ".github/workflows" ]]; then
  for wf in .github/workflows/*.yml; do
    [[ -f "$wf" ]] || continue
    ((workflow_count++))
    # Basic YAML validity via python if available
    if command -v python3 &>/dev/null; then
      if python3 -c "import yaml; yaml.safe_load(open('$wf'))" 2>/dev/null; then
        pass "$wf — valid YAML"
      else
        fail "$wf — YAML parse error"
        ((workflow_errors++))
      fi
    else
      # Fallback: check file is non-empty and has 'on:' and 'jobs:'
      if grep -q "^on:" "$wf" && grep -q "^jobs:" "$wf"; then
        pass "$wf — structure OK (install python3 for full validation)"
      else
        fail "$wf — missing 'on:' or 'jobs:' key"
        ((workflow_errors++))
      fi
    fi
  done
  info "$workflow_count workflow(s) checked, $workflow_errors error(s)"
else
  fail ".github/workflows/ directory missing"
fi

# =============================================================================
# LAYER 5 — VISITOR JOURNEY
# =============================================================================
section "Layer 5: Visitor Journey"

# README has critical sections
section "  README Sections"
for section_text in "Use this template" "token-audit" "Quick start" \
                    "June 2026" "DORA" "Works with"; do
  if grep -q "$section_text" README.md 2>/dev/null; then
    pass "README contains: \"$section_text\""
  else
    warn "README missing: \"$section_text\""
  fi
done

# Issue templates exist
section "  Issue Templates"
template_count=$(find .github/ISSUE_TEMPLATE -name "*.yml" -o -name "*.md" \
  2>/dev/null | grep -v config.yml | wc -l | tr -d ' ')
if [[ "$template_count" -ge 3 ]]; then
  pass "$template_count issue template(s) found"
  find .github/ISSUE_TEMPLATE -name "*.yml" -o -name "*.md" \
    2>/dev/null | grep -v config.yml | while read -r t; do
      info "  $t"
    done
elif [[ "$template_count" -ge 1 ]]; then
  warn "Only $template_count issue template(s) — recommend at least 3"
else
  fail "No issue templates found in .github/ISSUE_TEMPLATE/"
fi

# CHANGELOG has v1.0.0
section "  Release Readiness"
if grep -q "1\.0\.0" CHANGELOG.md 2>/dev/null; then
  pass "CHANGELOG.md contains v1.0.0 entry"
else
  warn "CHANGELOG.md missing v1.0.0 entry"
fi

# Git tag exists
if git tag | grep -q "v1\.0\.0" 2>/dev/null; then
  pass "git tag v1.0.0 exists"
else
  warn "git tag v1.0.0 not found locally (may still exist on remote)"
fi

# No uncommitted changes to key files
section "  Git Status"
if git diff --quiet HEAD -- AGENTS.md README.md 2>/dev/null; then
  pass "AGENTS.md and README.md are clean (no uncommitted changes)"
else
  warn "Uncommitted changes in AGENTS.md or README.md — push before sharing"
fi

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${RESET}"
echo -e "${BOLD}  Verification Summary${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${RESET}"
echo ""
echo -e "  ${GREEN}${BOLD}Passed:${RESET}   $PASSES"
echo -e "  ${YELLOW}${BOLD}Warnings:${RESET} $WARNINGS"
echo -e "  ${RED}${BOLD}Failures:${RESET} $FAILURES"
echo ""

if [[ "$FAILURES" -eq 0 && "$WARNINGS" -eq 0 ]]; then
  echo -e "  ${GREEN}${BOLD}✓ All checks passed — repo is first-impression ready.${RESET}"
  echo ""
  exit 0
elif [[ "$FAILURES" -eq 0 ]]; then
  echo -e "  ${YELLOW}${BOLD}⚠ Passed with $WARNINGS warning(s) — review above before sharing.${RESET}"
  echo ""
  exit 0
else
  echo -e "  ${RED}${BOLD}✗ $FAILURES failure(s) found — fix before the post goes wider.${RESET}"
  echo ""
  exit 1
fi
