#!/usr/bin/env bash
# scripts/test-image-lock-refresh.sh — proves scripts/image-lock-refresh.sh
# verifies a tool with no checksum file against the SHA-256 digest GitHub
# records for the release asset: a match is pinned as verified, a mismatch
# fails the refresh, and an asset without a digest falls back to TOFU. Runs in
# a throwaway repo layout with stub `gh` and `curl`; no network.
#
# Report-only. Exit 0 = every check passed.

set -euo pipefail
cd "$(dirname "$0")/.."

work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
pass=0
failures=()

repo="$work/repo"
mkdir -p "$repo/scripts" "$repo/images/devsecops" "$work/bin"
cp scripts/image-lock-refresh.sh "$repo/scripts/"
# Every stub asset's bytes are "asset", so every computed hash is this one.
good="$(printf 'asset' | sha256sum | cut -d' ' -f1)"

write_lock() { # write_lock <name> <url template>
  cat > "$repo/images/devsecops/tools.lock.json" << EOF
{"schema": 1, "tools": [
  {"name": "$1", "version": "1.0.0", "url": "$2", "checksum_url": "",
   "arch": {"amd64": "x64", "arm64": "arm64"}, "sha256": {"amd64": "", "arm64": ""}}
]}
EOF
}

cat > "$work/bin/curl" << 'EOF'
#!/usr/bin/env bash
printf 'asset'
EOF
cat > "$work/bin/gh" << EOF
#!/usr/bin/env bash
# stub: the release's asset digests, filtered by the caller's --jq
case "\$*" in
  *acme/match/releases/tags/v1.0.0*) echo "sha256:${good}" ;;
  *acme/swap/releases/tags/v1.0.0*) echo "sha256:0000000000000000000000000000000000000000000000000000000000000000" ;;
  *acme/old/releases/tags/v1.0.0*) echo "" ;;               # asset predates digests
  *acme/slash/releases/tags/tool/v1.0.0*) echo "sha256:${good}" ;; # tag with a / (kustomize)
  *) echo "unexpected gh call: \$*" >&2; exit 1 ;;
esac
EOF
chmod +x "$work/bin/curl" "$work/bin/gh"

refresh() { # refresh <name> → sets out, rc
  rc=0
  out="$(cd "$repo" && PATH="$work/bin:$PATH" bash scripts/image-lock-refresh.sh "$1" 2>&1)" || rc=$?
}
check() { # check <label> <expected rc> <fixed string in output>
  if [ "$rc" -eq "$2" ] && grep -qF -- "$3" <<< "$out"; then
    pass=$((pass + 1))
    echo "  ✅ $1"
  else
    failures+=("$1")
    echo "  ❌ $1 (exit ${rc}, want $2; missing: $3)"
    echo "       ${out//$'\n'/$'\n'       }"
  fi
}

write_lock match "https://github.com/acme/match/releases/download/v{version}/tool-{arch}.tar.gz"
refresh match
check "pins an asset whose GitHub digest matches" 0 "match 1.0.0 arm64 verified against GitHub's release asset digest"
if jq -e --arg h "$good" '.tools[0].sha256 == {amd64: $h, arm64: $h}' "$repo/images/devsecops/tools.lock.json" > /dev/null; then
  pass=$((pass + 1))
  echo "  ✅ writes the verified hash for both arches"
else
  failures+=("lock not written")
  echo "  ❌ lock not written"
fi

write_lock swap "https://github.com/acme/swap/releases/download/v{version}/tool-{arch}.tar.gz"
refresh swap
check "fails when the GitHub digest differs" 1 "does not match GitHub's release asset digest"

write_lock old "https://github.com/acme/old/releases/download/v{version}/tool-{arch}.tar.gz"
refresh old
check "falls back to TOFU when GitHub has no digest" 0 "old 1.0.0 amd64 TOFU"

write_lock slash "https://github.com/acme/slash/releases/download/tool%2Fv{version}/tool-{arch}.tar.gz"
refresh slash
check "decodes a URL-encoded tag for the API" 0 "slash 1.0.0 amd64 verified against GitHub's release asset digest"

write_lock plain "https://example.invalid/tool-{arch}.tar.gz"
refresh plain
check "a non-GitHub URL is TOFU without calling gh" 0 "plain 1.0.0 amd64 TOFU"

echo
if [ "${#failures[@]}" -gt 0 ]; then
  echo "FAILED ${#failures[@]} check(s), passed ${pass}:"
  printf '  - %s\n' "${failures[@]}"
  exit 1
fi
echo "ALL ${pass} CHECKS PASSED"
