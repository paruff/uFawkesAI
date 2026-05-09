#!/bin/bash
# weekly-metrics.sh — [PROJECT NAME]
# DORA 2025 (METRICS-02): Single-screen metrics summary
# Run: npm run metrics
# Usage: bash scripts/weekly-metrics.sh [--dry-run] [--days=14]

DAYS=14
DRY_RUN=0
for arg in "$@"; do
  case "$arg" in
    --dry-run)
      DRY_RUN=1
      ;;
    --days=*)
      DAYS="${arg#*=}"
      if ! [[ "$DAYS" =~ ^[0-9]+$ ]]; then
        echo "Invalid argument: $arg"
        echo "Usage: bash scripts/weekly-metrics.sh [--dry-run] [--days=14]"
        exit 1
      fi
      ;;
    *)
      if [[ "$arg" =~ ^[0-9]+$ ]]; then
        DAYS="$arg"
      else
        echo "Invalid argument: $arg"
        echo "Usage: bash scripts/weekly-metrics.sh [--dry-run] [--days=14]"
        exit 1
      fi
      ;;
  esac
done
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo ""
echo "═══════════════════════════════════════════"
echo "  [PROJECT NAME] Weekly Metrics"
echo "  Period: last ${DAYS} days"
echo "═══════════════════════════════════════════"
echo ""

if [ "$DRY_RUN" -eq 1 ]; then
  echo "(dry-run mode)"
  echo ""
fi

# ─────────────────────────────────────────
# Rework Rate (DORA 2025 new metric)
# Lines reverted as % of total lines authored
# ─────────────────────────────────────────
TOTAL_LINES=$(git log --since="${DAYS} days ago" --pretty=tformat: --numstat \
  | grep -v "^-" | awk '{ add += $1; del += $2 } END { print add+del }' 2>/dev/null || echo "0")

REVERT_LINES=$(git log --since="${DAYS} days ago" --grep="revert" -i --pretty=tformat: --numstat \
  | grep -v "^-" | awk '{ add += $1; del += $2 } END { print add+del }' 2>/dev/null || echo "0")

if [ "$TOTAL_LINES" -gt 0 ]; then
  REWORK_RATE=$(echo "scale=1; $REVERT_LINES * 100 / $TOTAL_LINES" | bc 2>/dev/null || echo "?")
else
  REWORK_RATE="0"
fi

if (( $(echo "$REWORK_RATE > 20" | bc -l 2>/dev/null || echo 0) )); then
  STATUS="${RED}❌${NC}"
  NOTE="STOP features — fix instructions first"
elif (( $(echo "$REWORK_RATE > 10" | bc -l 2>/dev/null || echo 0) )); then
  STATUS="${YELLOW}⚠️ ${NC}"
  NOTE="Watch — review AGENTS.md for pattern drift"
else
  STATUS="${GREEN}✅${NC}"
  NOTE="Healthy"
fi
echo -e " ${STATUS} Rework rate:          ${REWORK_RATE}%   [target: <10%] — $NOTE"

# ─────────────────────────────────────────
# PRs merged
# ─────────────────────────────────────────
PRS_MERGED=$(git log --since="${DAYS} days ago" --merges --oneline | wc -l | tr -d ' ')
echo -e " ${GREEN}✅${NC} PRs merged:           ${PRS_MERGED}"

# ─────────────────────────────────────────
# Test coverage (reads from last coverage run)
# ─────────────────────────────────────────
if [ -f "coverage/coverage-summary.json" ]; then
  COVERAGE=$(python3 -c "
import json, sys
data = json.load(sys.stdin)
total = data.get('total', {})
lines = total.get('lines', {}).get('pct', 0)
print(f'{lines:.0f}')
" < coverage/coverage-summary.json 2>/dev/null || echo "?")
  
  if [ "$COVERAGE" != "?" ] && [ "$COVERAGE" -lt 80 ]; then
    echo -e " ${YELLOW}⚠️ ${NC} Test coverage:        ${COVERAGE}%  [target: ≥80%]"
  elif [ "$COVERAGE" != "?" ]; then
    echo -e " ${GREEN}✅${NC} Test coverage:        ${COVERAGE}%  [target: ≥80%]"
  else
    echo -e " ${YELLOW}⚠️ ${NC} Test coverage:        unknown — run npm run test:coverage"
  fi
else
  echo -e " ${YELLOW}⚠️ ${NC} Test coverage:        no data — run npm run test:coverage"
fi

echo ""
echo " Update docs/METRICS.md monthly log with these numbers."
echo " See docs/RUNBOOKS.md → Weekly Metrics Review for interpretation."
echo "═══════════════════════════════════════════"
echo ""
