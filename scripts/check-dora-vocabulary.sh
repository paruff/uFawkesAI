#!/usr/bin/env bash
# Enforce the canonical DORA AI capability vocabulary.
#
# Single source of truth: .agents/registry/dora-capabilities.yaml
#
# Fails when:
#   1. A file labels something "AI Capability N" with a name that is not the
#      canonical name for N.
#   2. Retired vocabulary reappears (the invented 8-capability scheme, "Shift
#      Left on Quality", "Prompt Engineering as Core Skill", ...).
#   3. A non-DORA practice is numbered as if it were an AI capability.
#
# The bug this exists to prevent: TEMPLATE-DESIGN.md used to define its own
# eight-capability scheme in which Cap 6 was "Fast Feedback Loops", while
# DORA's Cap 6 is "User-centric focus" and several skills used "Cap 6" to mean
# Reliability or Operational Visibility. One number, three meanings.
set -euo pipefail

cd "$(dirname "$0")/.." || exit 1

REGISTRY=".agents/registry/dora-capabilities.yaml"
[[ -f "$REGISTRY" ]] || {
  echo "FAIL: canonical registry missing: $REGISTRY" >&2
  exit 1
}

# Canonical name per number, read from the registry so the registry really is
# the source of truth rather than a second hardcoded list.
declare -A CANON=()
while IFS= read -r line; do
  # - number: 3
  #   name: "AI-accessible internal data"
  num="${line#*number: }"
  [[ "$line" == *number:* ]] || continue
  CANON["$num"]=""
done < "$REGISTRY"

cur=""
while IFS= read -r line; do
  if [[ "$line" =~ number:\ ([0-9]+) ]]; then
    cur="${BASH_REMATCH[1]}"
  elif [[ "$line" =~ name:\ \"(.+)\" ]] && [[ -n "$cur" ]]; then
    CANON["$cur"]="${BASH_REMATCH[1]}"
    cur=""
  fi
done < "$REGISTRY"

if [[ "${#CANON[@]}" -ne 7 ]]; then
  echo "FAIL: expected 7 canonical capabilities, parsed ${#CANON[@]} from $REGISTRY" >&2
  exit 1
fi

echo "Canonical DORA AI capabilities (from $REGISTRY):"
for n in 1 2 3 4 5 6 7; do
  echo "  $n: ${CANON[$n]}"
done
echo

fail=0

# ── 1. "AI Capability N" must be followed by the canonical name ──────────────
# Matches:  AI Capability 3: <name>   |   AI Capability 3 — <name>
while IFS= read -r hit; do
  file="${hit%%:*}"
  rest="${hit#*:}"
  lineno="${rest%%:*}"
  text="${rest#*:}"
  num="$(sed -nE 's/.*AI Capabilit(y|ies) ([0-9]+).*/\2/p' <<< "$text" | head -1)"
  [[ -n "$num" ]] || continue
  # extract the name that follows the number
  name="$(sed -nE 's/.*AI Capabilit(y|ies) [0-9]+ *[:—-] *//p' <<< "$text" | head -1)"
  [[ -n "$name" ]] || continue
  name="${name%%$'\r'}"
  # Trim trailing punctuation/quotes that belong to the sentence, not the name.
  name="$(sed -E 's/[[:space:]]*[.,;)`"]*$//' <<< "$name")"
  want="${CANON[$num]}"
  # Prefix match: the label may legitimately continue with more text
  # ("+ Core: Test automation", a table pipe, a sentence). We only require
  # that the name it starts with is the canonical one for that number.
  if [[ "${name,,}" != "${want,,}"* ]]; then
    printf '  FAIL %s:%s\n       labeled: AI Capability %s: %s\n       canonical: AI Capability %s: %s\n' \
      "$file" "$lineno" "$num" "$name" "$num" "$want" >&2
    fail=1
  fi
done < <(git grep -nIE 'AI Capabilit(y|ies) [0-9]+ *[:—-]' -- '*.md' || true)

# ── 2. Retired vocabulary must not reappear ──────────────────────────────────
# Each pattern is a string that was previously used as a capability name.
while IFS= read -r hit; do
  file="${hit%%:*}"
  lineno="${hit#*:}"
  lineno="${lineno%%:*}"
  printf '  FAIL %s:%s retired DORA vocabulary: %s\n' \
    "$file" "$lineno" "$(sed -E 's/^.{0,140}$/&/' <<< "$hit" | cut -c1-120)" >&2
  fail=1
done < <(git grep -nIE 'Capability 6 — Fast Feedback|Capability 8|AI Cap [0-9]|Prompt Engineering as Core Skill|Clarify AI Policies|Shift Left on Quality|AI Cap 2 — Prompt' -- '*.md' || true)

# ── 3. Non-DORA practices must not be numbered as capabilities ───────────────
while IFS= read -r hit; do
  printf '  FAIL %s non-DORA practice numbered as an AI capability: %s\n' \
    "$(cut -d: -f1 <<< "$hit")" "$(cut -c1-110 <<< "$hit")" >&2
  fail=1
done < <(git grep -nIE 'Cap(ability)? ?[0-9]+ *[(—-] *(Observability|Reliability|Operational Resilience|Operational Visibility|CI/CD Automation|AI Policy|Context Engineering|AI-assisted development)' -- '*.md' || true)

if [[ "$fail" -ne 0 ]]; then
  echo
  echo "DORA vocabulary check FAILED." >&2
  echo "Canonical names live in $REGISTRY. Non-DORA practices use the 'Core:' axis." >&2
  exit 1
fi

echo "DORA vocabulary check PASSED — all capability labels canonical."
