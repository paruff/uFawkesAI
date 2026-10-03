#!/usr/bin/env bash
# scripts/check-placeholders.sh — placeholder audit (#28, AC-AI-02).
#
# Lists every unfilled `[PLACEHOLDER…]` marker in tracked files (scripts that
# talk about the marker are skipped; a backticked mention is not a marker).
#
# Template mode: while the repo-root `.template` marker exists (the template
# repo itself), markers are reported and the check passes. scripts/setup.sh
# deletes `.template` in a repo created from the template; from then on any
# marker fails. PLACEHOLDER_ENFORCE=1 enforces regardless.
#
# Usage: scripts/check-placeholders.sh   (exit 1 when enforcing and found)

set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# shellcheck disable=SC2016 # backticks are regex literals
hits="$(git grep -nE '(^|[^`])\[PLACEHOLDER[^]`]*\]' -- ':!scripts/' || true)"

if [ -z "$hits" ]; then
  echo "✅ No unfilled [PLACEHOLDER] markers."
  exit 0
fi

echo "$hits"
count="$(wc -l <<< "$hits" | tr -d ' ')"
if [ -f .template ] && [ "${PLACEHOLDER_ENFORCE:-0}" != "1" ]; then
  echo "⚠️  ${count} [PLACEHOLDER] marker(s) — template mode (.template present), not enforced."
  exit 0
fi
echo "❌ ${count} unfilled [PLACEHOLDER] marker(s). Fill them in, or run scripts/setup.sh first if this is still the template."
exit 1
