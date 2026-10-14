#!/usr/bin/env bash
# scripts/check-review-md.sh — #158: REVIEW.md stays one page with the
# required sections, and the agent PR-review workflow actually reads it.
#
# Usage: scripts/check-review-md.sh [REVIEW.md] [workflow.yml]   (exit 1 on any miss)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
review="${1:-REVIEW.md}"
wf="${2:-.github/workflows/agent-review.yml}"
max_lines=60
fail=0
miss() {
  echo "❌ $1"
  fail=1
}

if [ ! -f "$review" ]; then
  miss "$review not found"
else
  lines="$(wc -l < "$review" | tr -d ' ')"
  [ "$lines" -le "$max_lines" ] || miss "$review is ${lines} lines (max ${max_lines})"
  for s in Flag Skip Severity Output; do
    grep -qE "^## ${s}\$" "$review" || miss "$review missing section: ## ${s}"
  done
fi

if [ ! -f "$wf" ]; then
  miss "$wf not found"
else
  grep -q 'REVIEW\.md' "$wf" || miss "$wf does not read REVIEW.md"
  grep -qE 'ANTHROPIC_API_KEY' "$wf" || miss "$wf does not check ANTHROPIC_API_KEY"
  if grep -vE '^\s*#' "$wf" | grep -qE 'gh pr (merge|review)'; then
    miss "$wf approves or merges"
  fi
fi

[ "$fail" -eq 0 ] || exit 1
echo "✅ REVIEW.md and agent-review workflow are consistent."
