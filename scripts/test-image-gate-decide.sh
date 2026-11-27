#!/usr/bin/env bash
# scripts/test-image-gate-decide.sh — proves scripts/image-gate-decide.sh maps
# (ref kind, pinned scan rc, fresh scan rc) to the gate outcome. No Docker.
set -euo pipefail
cd "$(dirname "$0")/.."

failures=0
check() { # check <label> <want-exit> <want-text|-> <args...>
  local label="$1" want="$2" text="$3"
  shift 3
  local out rc=0
  out="$(bash scripts/image-gate-decide.sh "$@" 2>&1)" || rc=$?
  if [ "$rc" -ne "$want" ] || { [ "$text" != - ] && ! grep -qF -- "$text" <<<"$out"; }; then
    echo "  FAIL $label (exit $rc, want $want, text '$text'): $out"
    failures=$((failures + 1))
  else
    echo "  ok   $label"
  fi
}

check "pinned clean passes" 0 - branch 0 none
check "pinned clean on a tag passes" 0 - tag 0 none
check "stale lock off-tag: warns, passes" 0 "::warning::" branch 1 0
check "findings persist off-tag: fails" 1 "persist on the newest snapshot" branch 1 1
check "fresh snapshot unavailable off-tag: fails" 1 "persist on the newest snapshot" branch 1 unavailable
check "stale lock on a tag: fails with the bump instruction" 1 "Merge the image-lock-bump PR" tag 1 0
check "findings persist on a tag: fails" 1 "persist on the newest snapshot" tag 1 2
check "fresh snapshot unavailable on a tag: fails" 1 "persist on the newest snapshot" tag 1 unavailable
check "bad ref kind is a usage error" 2 usage other 1 0

if [ "$failures" -ne 0 ]; then
  echo "$failures case(s) failed"
  exit 1
fi
echo "ALL CASES BEHAVED AS EXPECTED"
