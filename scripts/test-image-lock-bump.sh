#!/usr/bin/env bash
# scripts/test-image-lock-bump.sh — proves scripts/image-lock-bump.sh
# degrades per tool instead of aborting the whole weekly bump: a failed
# upstream lookup or a non-numeric tag must produce a "could not determine"
# warning for that tool while every other tool is still bumped. Runs
# --dry-run in a throwaway repo layout with stub `gh` and `curl`; no network.
#
# Report-only. Exit 0 = every check passed.

set -euo pipefail
cd "$(dirname "$0")/.."

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
pass=0
failures=()

repo="$work/repo"
mkdir -p "$repo/scripts" "$repo/images/devsecops/python" "$work/bin"
cp scripts/image-lock-bump.sh "$repo/scripts/"
printf '# no pins\n' >"$repo/images/devsecops/python/requirements.in"
printf 'ARG APT_SNAPSHOT=20200101T000000Z\n' >"$repo/images/devsecops/Dockerfile"
cat >"$repo/images/devsecops/tools.lock.json" <<'EOF'
{"schema": 1, "tools": [
  {"name": "good", "version": "1.0.0", "source": {"github": "acme/good", "tag": "v{version}"}},
  {"name": "gone", "version": "1.0.0", "source": {"github": "acme/gone", "tag": "v{version}"}},
  {"name": "junk", "version": "1.0.0", "source": {"url": "https://example.invalid/stable.txt", "tag": "v{version}"}},
  {"name": "last", "version": "3.0.0", "source": {"github": "acme/last", "tag": "v{version}"}}
]}
EOF
cat >"$work/bin/gh" <<'EOF'
#!/usr/bin/env bash
# stub: newest-first tag lists, like the releases API
case "$*" in
  *acme/good/releases*) printf 'v2.0.0\nv1.5.0\nv1.0.0-foo\n' ;;   # last tag non-numeric
  *acme/last/releases*) printf 'v3.1.0\nv3.0.0\n' ;;
  *acme/gone/releases*) echo "HTTP 404: Not Found" >&2; exit 1 ;;  # repo moved/deleted
  *) echo "unexpected gh call: $*" >&2; exit 1 ;;
esac
EOF
cat >"$work/bin/curl" <<'EOF'
#!/usr/bin/env bash
case "$*" in
  *stable.txt*) echo "vnot-a-version" ;;
  *snapshot.debian.org*) exit 22 ;;   # snapshot "unreachable" — no network in tests
  *) echo "unexpected curl call: $*" >&2; exit 1 ;;
esac
EOF
chmod +x "$work/bin/gh" "$work/bin/curl"

if out="$(cd "$repo" && PATH="$work/bin:$PATH" BUMP_SUMMARY="$work/summary.md" \
  bash scripts/image-lock-bump.sh --dry-run 2>&1)"; then
  pass=$((pass + 1)); echo "  ✅ completes (exit 0) despite per-tool lookup failures"
else
  failures+=("aborted"); echo "  ❌ aborted (exit $?):"; echo "${out//$'\n'/$'\n'       }"
fi

expect_line() { # expect_line <label> <fixed string in summary>
  if grep -qF -- "$2" "$work/summary.md" 2>/dev/null; then
    pass=$((pass + 1)); echo "  ✅ $1"
  else
    failures+=("$1"); echo "  ❌ $1 — missing: $2"
  fi
}
expect_line "bumps a tool whose oldest tag is non-numeric" "- good: 1.0.0 → **2.0.0**"
expect_line "warns (not aborts) on a failed repo lookup" "- ⚠️ gone: could not determine the latest upstream version (kept 1.0.0)"
expect_line "warns on a non-numeric URL version" "- ⚠️ junk: could not determine the latest upstream version (kept 1.0.0)"
expect_line "still processes tools after the failures" "- last: 3.0.0 → **3.1.0**"
expect_line "reaches the apt snapshot section" "not reachable; kept 20200101T000000Z"

echo
if [ "${#failures[@]}" -gt 0 ]; then
  echo "FAILED ${#failures[@]} check(s), passed ${pass}:"; printf '  - %s\n' "${failures[@]}"
  exit 1
fi
echo "ALL ${pass} CHECKS PASSED"
