#!/usr/bin/env bash
# shellcheck disable=SC2016 # literal backticks: markdown code spans
# scripts/check-readme-claims.sh — AC-AI-04: the README's capability maps
# (DORA capabilities, harness anatomy, feature map, playbook stages) may only
# name things that ship. Every backticked path must exist (bare *.yml names
# resolve under .github/workflows/), and every `npm run <x>` must be a script.
#
# Usage: scripts/check-readme-claims.sh [README.md]   (exit 1 on any miss)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"
readme="${1:-README.md}"

maps="$(sed -n '/^## DORA AI Capabilities implemented/,/^## Container images/p' "$readme")"
[ -n "$maps" ] || {
  echo "❌ capability maps not found in ${readme} (headings changed?)"
  exit 1
}

missing=0
while read -r p; do
  [ -e "$p" ] || [ -e ".github/workflows/$p" ] || {
    echo "❌ claimed but missing: $p"
    missing=$((missing + 1))
  }
done < <(grep -oE '`[^` ]+`' <<< "$maps" | tr -d '`' | grep -E '/|\.(md|json|yml|yaml|sh)$' \
  | grep -vE '^(ghcr\.io|https?:)' | sort -u)

while read -r s; do
  jq -e --arg s "$s" '.scripts[$s]' package.json > /dev/null || {
    echo "❌ claimed npm script missing: npm run $s"
    missing=$((missing + 1))
  }
done < <(grep -oE 'npm run [a-z:-]+' <<< "$maps" | awk '{print $3}' | sort -u)

if [ "$missing" -gt 0 ]; then
  echo "README claims ${missing} thing(s) that don't ship."
  exit 1
fi
echo "✅ README capability maps: every claimed file and npm script exists."
