#!/usr/bin/env bash
# scripts/image-lock-refresh.sh — (re)compute SHA-256 pins in
# images/devsecops/tools.lock.json for the version each tool is set to.
#
# For every tool and arch it streams the release asset, hashes it, and —
# when the project publishes a checksum file — requires that exact hash to
# appear in it (format-agnostic: works for sha256sum, goreleaser, and
# multi-hash files alike). Tools with no checksum file are pinned
# trust-on-first-use and reported as such.
#
# Idempotent: re-running with unchanged versions rewrites identical hashes.
# The base image digest lives in the Dockerfile's FROM line (Dependabot's
# docker updater bumps it); this script only handles tools.lock.json.
#
# Usage:
#   scripts/image-lock-refresh.sh              — all tools
#   scripts/image-lock-refresh.sh gitleaks jq  — just these tools

# jq programs reference jq variables ($n, $a, …) — single quotes are intended.
# shellcheck disable=SC2016

set -euo pipefail
cd "$(dirname "$0")/.."

LOCK="images/devsecops/tools.lock.json"
ARCHES="amd64 arm64"

fail() { echo "FAIL: $*" >&2; exit 1; }
command -v jq >/dev/null || fail "jq is required"

# render <template> <version> <arch-token> [asset-url]
render() {
  local s="$1"
  s="${s//\{version\}/$2}"
  s="${s//\{arch\}/$3}"
  s="${s//\{url\}/${4:-}}"
  printf '%s' "$s"
}

write_lock() {
  local tmp
  tmp="$(mktemp)"
  jq "$@" "$LOCK" >"$tmp"
  mv "$tmp" "$LOCK"
}

refresh_tool() {
  local name="$1" entry version url_t cs_t arch token url hash cs
  entry="$(jq -c --arg n "$name" '.tools[] | select(.name == $n)' "$LOCK")"
  [ -n "$entry" ] || fail "no tool named '${name}' in ${LOCK}"
  version="$(jq -r .version <<<"$entry")"
  url_t="$(jq -r .url <<<"$entry")"
  cs_t="$(jq -r '.checksum_url // ""' <<<"$entry")"
  for arch in $ARCHES; do
    token="$(jq -r --arg a "$arch" '.arch[$a]' <<<"$entry")"
    url="$(render "$url_t" "$version" "$token")"
    hash="$(curl -fsSL "$url" | sha256sum | cut -d' ' -f1)"
    if [ -n "$cs_t" ]; then
      cs="$(curl -fsSL "$(render "$cs_t" "$version" "$token" "$url")")"
      grep -qi "$hash" <<<"$cs" || fail "${name} ${arch}: ${hash} not in upstream checksums"
      echo "  ${name} ${version} ${arch} verified against upstream checksums"
    else
      echo "  ${name} ${version} ${arch} TOFU (no upstream checksum file) — review release page"
    fi
    write_lock --arg n "$name" --arg a "$arch" --arg h "$hash" \
      '(.tools[] | select(.name == $n) | .sha256[$a]) = $h'
  done
}

if [ "$#" -eq 0 ]; then
  mapfile -t tools < <(jq -r '.tools[].name' "$LOCK")
else
  tools=("$@")
fi

for t in "${tools[@]}"; do refresh_tool "$t"; done
echo "✅ Refreshed ${#tools[@]} tool(s) in ${LOCK}"
