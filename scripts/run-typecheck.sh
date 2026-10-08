#!/usr/bin/env bash
# scripts/run-typecheck.sh — the strongest static analysis this repo can do.
#
# The repo has exactly one TypeScript file (.opencode/plugins/ai-sdlc-hooks.ts)
# and no committed node_modules, so "type checking" here means, in order:
#   1. tsc --noEmit            — real type checking, when typescript is installed
#   2. node --check            — parse check on every .js file
#   3. python3 -m py_compile   — parse check on every .py file
# Steps 2 and 3 are stdlib-only, so they always run. Step 1 is skipped loudly
# when typescript is absent rather than reported as a pass.
#
# The previous `npm run typecheck` was `echo "No TypeScript configuration yet;
# passing placeholder typecheck step."` — it exited 0 while checking nothing.
# Exit 0 from this script means something was actually checked.
set -uo pipefail

cd "$(dirname "$0")/.." || exit 1

CHECKED=0
SKIPPED=0
FAILED=0

echo "== Type check =="

# 1. TypeScript (root config — excludes .opencode which is checked by pre-commit)
if [[ -x node_modules/.bin/tsc ]]; then
  # Only run root tsc if there are .ts files outside .opencode
  root_ts_files=$(find . -name '*.ts' -not -path './.git/*' -not -path './.opencode/*' -not -path '*/node_modules/*' 2>/dev/null | head -1)
  if [[ -n "$root_ts_files" ]]; then
    if node_modules/.bin/tsc --noEmit -p tsconfig.json > /tmp/tc.$$.out 2>&1; then
      echo "  PASS  tsc --noEmit"
      CHECKED=$((CHECKED + 1))
    else
      echo "  FAIL  tsc --noEmit"
      sed 's/^/        /' /tmp/tc.$$.out | head -40
      FAILED=$((FAILED + 1))
    fi
    rm -f /tmp/tc.$$.out
  else
    echo "  SKIP  tsc --noEmit              no .ts files at root level (excludes .opencode)"
    SKIPPED=$((SKIPPED + 1))
  fi
else
  echo "  SKIP  tsc --noEmit              typescript not installed (npm install)"
  SKIPPED=$((SKIPPED + 1))
fi

# 2. JavaScript parse check
js_count=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  js_count=$((js_count + 1))
  if node --check "$f" 2> /tmp/js.$$.out; then
    :
  else
    echo "  FAIL  node --check $f"
    sed 's/^/        /' /tmp/js.$$.out | head -10
    FAILED=$((FAILED + 1))
  fi
done < <(find scripts .opencode -name '*.js' -not -path '*/node_modules/*' 2> /dev/null | sort)
if [[ "$js_count" -gt 0 ]]; then
  echo "  PASS  node --check (${js_count} file(s))"
  CHECKED=$((CHECKED + 1))
else
  echo "  SKIP  node --check              no .js files found"
  SKIPPED=$((SKIPPED + 1))
fi
rm -f /tmp/js.$$.out

# 3. Python parse check
py_count=0
while IFS= read -r f; do
  [[ -z "$f" ]] && continue
  py_count=$((py_count + 1))
  if python3 -m py_compile "$f" 2> /tmp/py.$$.out; then
    :
  else
    echo "  FAIL  py_compile $f"
    sed 's/^/        /' /tmp/py.$$.out | head -10
    FAILED=$((FAILED + 1))
  fi
done < <(find . -name '*.py' -not -path './.git/*' -not -path './opencode/*' \
  -not -path '*/node_modules/*' 2> /dev/null | sort)
if [[ "$py_count" -gt 0 ]]; then
  echo "  PASS  py_compile (${py_count} file(s))"
  CHECKED=$((CHECKED + 1))
else
  echo "  SKIP  py_compile                no .py files found"
  SKIPPED=$((SKIPPED + 1))
fi
rm -f /tmp/py.$$.out
find . -name '__pycache__' -type d -not -path './.git/*' -exec rm -rf {} + 2> /dev/null || true

echo
echo "typecheck: ${CHECKED} ran, ${SKIPPED} skipped, ${FAILED} failed"
if [[ "$FAILED" -ne 0 ]]; then
  exit 1
fi
if [[ "$CHECKED" -eq 0 ]]; then
  echo "typecheck: nothing was actually checked — this is not a pass" >&2
  exit 1
fi
