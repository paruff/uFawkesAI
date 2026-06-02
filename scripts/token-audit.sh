#!/usr/bin/env bash
# scripts/token-audit.sh
#
# PURPOSE: Measure the token footprint of always-on Copilot context files.
#          Run this before your first bill arrives, then monthly.
#
# USAGE:   npm run token-audit
#          npm run token-audit -- --save   (appends to docs/METRICS.md)
#
# NOTE:    Uses 4 chars ≈ 1 token approximation (±15% of actual tokenizer).
#          For exact counts, paste files into platform.openai.com/tokenizer.

set -euo pipefail

SAVE_TO_METRICS=false
[[ "${1:-}" == "--save" ]] && SAVE_TO_METRICS=true

# ── Colour output ─────────────────────────────────────────────────────────────
RED='\033[0;31m'; YELLOW='\033[1;33m'; GREEN='\033[0;32m'
BLUE='\033[0;34m'; BOLD='\033[1m'; NC='\033[0m'

# ── Token estimation (4 chars ≈ 1 token) ──────────────────────────────────────
estimate_tokens() {
  local file="$1"
  if [[ -f "$file" ]]; then
    local chars
    chars=$(wc -c < "$file")
    echo $(( chars / 4 ))
  else
    echo 0
  fi
}

# ── Credit cost estimation ─────────────────────────────────────────────────────
# Assumes Sonnet-class model at ~$0.003/1K input tokens as representative baseline
estimate_monthly_cost() {
  local tokens="$1"
  local requests_per_day="${2:-20}"   # default: 20 agent interactions/day
  local working_days=22
  local total_requests=$(( requests_per_day * working_days ))
  # Cost = tokens * requests * price_per_token
  # $0.003 per 1K tokens = $0.000003 per token
  local cost_cents=$(( tokens * total_requests * 3 / 1000 ))
  echo "$cost_cents"
}

echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}  uFawkesAI Token Audit — $(date '+%Y-%m-%d')${NC}"
echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""

# ── Always-on context files ────────────────────────────────────────────────────
echo -e "${BOLD}── Always-On Context (billed on every request) ────────${NC}"
echo ""

TOTAL_ALWAYS_ON=0
declare -A ALWAYS_ON_FILES=(
  ["AGENTS.md"]="AGENTS.md"
  [".github/copilot-instructions.md"]=".github/copilot-instructions.md"
  ["CLAUDE.md"]="CLAUDE.md"
)

for label in "${!ALWAYS_ON_FILES[@]}"; do
  file="${ALWAYS_ON_FILES[$label]}"
  tokens=$(estimate_tokens "$file")
  TOTAL_ALWAYS_ON=$(( TOTAL_ALWAYS_ON + tokens ))
  lines=0
  [[ -f "$file" ]] && lines=$(wc -l < "$file")

  if [[ $tokens -gt 2000 ]]; then
    status="${RED}⚠ HIGH${NC}"
  elif [[ $tokens -gt 800 ]]; then
    status="${YELLOW}~ OK${NC}"
  else
    status="${GREEN}✓ LEAN${NC}"
  fi
  printf "  %-42s %5d tokens  %4d lines  %b\n" "$label" "$tokens" "$lines" "$status"
done

echo ""
echo -e "  ${BOLD}Total always-on tokens: ${TOTAL_ALWAYS_ON}${NC}"

# Monthly cost at different usage levels
COST_LIGHT=$(estimate_monthly_cost "$TOTAL_ALWAYS_ON" 10)
COST_MOD=$(estimate_monthly_cost "$TOTAL_ALWAYS_ON" 20)
COST_HEAVY=$(estimate_monthly_cost "$TOTAL_ALWAYS_ON" 50)

echo ""
echo -e "${BOLD}── Monthly Credit Cost of Always-On Context ───────────${NC}"
echo ""
printf "  Light use   (10 agent tasks/day × 22 days):  %d credits = \$%.2f\n" \
  "$COST_LIGHT" "$(echo "scale=2; $COST_LIGHT/100" | bc 2>/dev/null || echo '?')"
printf "  Moderate    (20 agent tasks/day × 22 days):  %d credits = \$%.2f\n" \
  "$COST_MOD" "$(echo "scale=2; $COST_MOD/100" | bc 2>/dev/null || echo '?')"
printf "  Heavy       (50 agent tasks/day × 22 days):  %d credits = \$%.2f\n" \
  "$COST_HEAVY" "$(echo "scale=2; $COST_HEAVY/100" | bc 2>/dev/null || echo '?')"

echo ""

# ── Target comparison ─────────────────────────────────────────────────────────
TARGET_TOKENS=320  # 80 lines × ~4 tokens/line
echo -e "${BOLD}── Target Comparison ───────────────────────────────────${NC}"
echo ""
if [[ $TOTAL_ALWAYS_ON -le $TARGET_TOKENS ]]; then
  echo -e "  ${GREEN}✓ AGENTS.md is within the 80-line / ~320-token target${NC}"
else
  EXCESS=$(( TOTAL_ALWAYS_ON - TARGET_TOKENS ))
  echo -e "  ${YELLOW}⚠ ${EXCESS} excess tokens vs 80-line target${NC}"
  echo -e "  ${YELLOW}  Move detailed content to .github/skills/ to reduce cost${NC}"
fi
echo ""

# ── Top 10 largest files in repo ──────────────────────────────────────────────
echo -e "${BOLD}── Top 10 Largest Files (Copilot Context Candidates) ───${NC}"
echo ""
echo "  (Files Copilot may pull into context — review .copilotignore)"
echo ""

if command -v find &>/dev/null; then
  find . \
    -not -path './.git/*' \
    -not -path './node_modules/*' \
    -not -path './.venv/*' \
    -not -name '*.png' -not -name '*.jpg' -not -name '*.ico' \
    -not -name '*.lock' -not -name 'package-lock.json' \
    -type f -printf '%s %p\n' 2>/dev/null | \
    sort -rn | head -10 | while read -r size path; do
      tokens=$(( size / 4 ))
      printf "  %7d tokens  %s\n" "$tokens" "$path"
    done
fi

echo ""

# ── .copilotignore check ──────────────────────────────────────────────────────
echo -e "${BOLD}── .copilotignore Status ───────────────────────────────${NC}"
echo ""
if [[ -f ".copilotignore" ]]; then
  rules=$(grep -c -v '^#\|^$' .copilotignore 2>/dev/null || echo 0)
  echo -e "  ${GREEN}✓ .copilotignore present with ${rules} active rules${NC}"
else
  echo -e "  ${RED}✗ .copilotignore missing — Copilot indexes everything${NC}"
  echo -e "  ${RED}  Copy the template from uFawkesAI to add exclusions${NC}"
fi

echo ""

# ── Recommendations ───────────────────────────────────────────────────────────
echo -e "${BOLD}── Recommendations ─────────────────────────────────────${NC}"
echo ""

AGENTS_TOKENS=$(estimate_tokens "AGENTS.md")
if [[ $AGENTS_TOKENS -gt 800 ]]; then
  echo -e "  ${RED}1. AGENTS.md is large (${AGENTS_TOKENS} tokens).${NC}"
  echo -e "     Move detailed sections to .github/skills/ to save credits."
  echo ""
fi

if [[ ! -f ".copilotignore" ]]; then
  echo -e "  ${YELLOW}2. Add .copilotignore — see uFawkesAI template for defaults.${NC}"
  echo ""
fi

echo -e "  ${BLUE}→ Read docs/COPILOT_COST_GUIDE.md for the full playbook${NC}"
echo -e "  ${BLUE}→ Read docs/MODEL_ROUTING_GUIDE.md before your next agent task${NC}"
echo ""

# ── Save to METRICS.md ────────────────────────────────────────────────────────
if $SAVE_TO_METRICS; then
  METRICS_FILE="docs/METRICS.md"
  mkdir -p docs
  {
    echo ""
    echo "## Token Audit — $(date '+%Y-%m-%d')"
    echo ""
    echo "| File | Tokens | Lines |"
    echo "|---|---|---|"
    for label in "${!ALWAYS_ON_FILES[@]}"; do
      file="${ALWAYS_ON_FILES[$label]}"
      tokens=$(estimate_tokens "$file")
      lines=0; [[ -f "$file" ]] && lines=$(wc -l < "$file")
      echo "| $label | $tokens | $lines |"
    done
    echo ""
    echo "**Total always-on tokens:** $TOTAL_ALWAYS_ON"
    echo "**Moderate use monthly cost:** ~\$$( echo "scale=2; $COST_MOD/100" | bc 2>/dev/null || echo '?' ) in wasted context credits"
    echo ""
  } >> "$METRICS_FILE"
  echo -e "  ${GREEN}✓ Appended to $METRICS_FILE${NC}"
  echo ""
fi

echo -e "${BOLD}═══════════════════════════════════════════════════════${NC}"
echo ""
