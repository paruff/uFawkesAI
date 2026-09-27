#!/usr/bin/env bash
# scripts/image-lock-bump.sh — moves the DevSecOps image toolchain to the
# newest upstream releases, keeping every pin verifiable:
#
#   1. tools.lock.json: for each tool, the newest non-prerelease upstream
#      version (per its `source`); bumped entries are re-pinned by
#      scripts/image-lock-refresh.sh (checksums verified against upstream,
#      or reported as trust-on-first-use for review).
#   2. Python pins in images/devsecops/python/requirements*.in → newest on
#      PyPI; the hash locks are recompiled with uv.
#   3. apt snapshot (Dockerfile ARG APT_SNAPSHOT) → today, if published.
#
# Node tools and the base image digest are Dependabot's (.github/dependabot.yml).
# Idempotent: a second run with nothing new upstream changes nothing.
# Writes a Markdown change summary to $BUMP_SUMMARY when set.
#
# Usage: scripts/image-lock-bump.sh [--dry-run]
# Needs: jq, curl, sha256sum, gh (authenticated, for GitHub release lookups).

set -euo pipefail
cd "$(dirname "$0")/.."

LOCK="images/devsecops/tools.lock.json"
PYDIR="images/devsecops/python"
DOCKERFILE="images/devsecops/Dockerfile"
DRY_RUN=false
[ "${1:-}" = "--dry-run" ] && DRY_RUN=true

summary="$(mktemp)"
work="$(mktemp -d)"
trap 'rm -rf "$work"; rm -f "$summary"' EXIT
note() { printf '%s\n' "$*" | tee -a "$summary"; }

newer() { # newer <current> <candidate>: candidate sorts strictly after current
  [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$2" ]
}

# latest_version <source-json>: newest stable upstream version, or empty.
latest_version() {
  local src="$1" repo tag prefix suffix t v url major
  if repo="$(jq -er '.github // empty' <<<"$src")"; then
    tag="$(jq -r .tag <<<"$src")"
    prefix="${tag%%\{version\}*}"
    suffix="${tag#*\{version\}}"
    gh api "repos/${repo}/releases?per_page=50" \
      --jq '.[] | select((.draft or .prerelease) | not) | .tag_name' |
      while IFS= read -r t; do
        [[ "$t" == "$prefix"* && "$t" == *"$suffix" ]] || continue
        v="${t#"$prefix"}"
        v="${v%"$suffix"}"
        [[ "$v" =~ ^[0-9]+(\.[0-9]+)+$ ]] && echo "$v"
      done | sort -V | tail -1
  elif url="$(jq -er '.url // empty' <<<"$src")"; then
    tag="$(jq -r .tag <<<"$src")"
    v="$(curl -fsSL "$url")"
    v="${v#"${tag%%\{version\}*}"}"
    [[ "$v" =~ ^[0-9]+(\.[0-9]+)+$ ]] && echo "$v"
  elif major="$(jq -er '.node_lts_major // empty' <<<"$src")"; then
    curl -fsSL https://nodejs.org/dist/index.json |
      jq -r --arg m "v${major}." \
        '[.[] | select(.lts != false and (.version | startswith($m)))][0].version // empty' |
      sed 's/^v//'
  fi
}

note "## Toolchain bump — $(date -u +%Y-%m-%d)"
note ""
note "### Binary tools (\`tools.lock.json\`)"
bumped=()
while IFS=$'\t' read -r name current src; do
  latest="$(latest_version "$src")"
  if [ -z "$latest" ]; then
    note "- ⚠️ ${name}: could not determine the latest upstream version (kept ${current})"
  elif newer "$current" "$latest"; then
    note "- ${name}: ${current} → **${latest}**"
    bumped+=("$name")
    if ! $DRY_RUN; then
      tmp="$(mktemp)"
      jq --arg n "$name" --arg v "$latest" \
        '(.tools[] | select(.name == $n)) |= (.version = $v | .sha256 = {amd64: "", arm64: ""})' \
        "$LOCK" >"$tmp"
      mv "$tmp" "$LOCK"
    fi
  fi
done < <(jq -r '.tools[] | [.name, .version, (.source | tojson)] | @tsv' "$LOCK")
if [ "${#bumped[@]}" -eq 0 ]; then note "- all up to date"; fi

if [ "${#bumped[@]}" -gt 0 ] && ! $DRY_RUN; then
  note ""
  note "Checksums re-pinned by \`scripts/image-lock-refresh.sh\`:"
  note ""
  note '```'
  scripts/image-lock-refresh.sh "${bumped[@]}" 2>&1 | tee -a "$summary"
  note '```'
  if grep -q "TOFU" "$summary"; then
    note ""
    note "> **Reviewer:** the TOFU tools above publish no checksum file. Check each"
    note "> new version's release page (and, for opencode, compare with npm) before merging."
  fi
fi

note ""
note "### Python tools (\`${PYDIR}/requirements*.in\`)"
py_changed=false
for in_file in "$PYDIR"/requirements*.in; do
  while IFS= read -r pin; do
    pkg="${pin%%==*}"
    current="${pin#*==}"
    latest="$(curl -fsSL "https://pypi.org/pypi/${pkg}/json" | jq -r .info.version)"
    if newer "$current" "$latest"; then
      note "- ${pkg}: ${current} → **${latest}** ($(basename "$in_file"))"
      py_changed=true
      $DRY_RUN || sed -i "s/^${pkg}==${current}\$/${pkg}==${latest}/" "$in_file"
    fi
  done < <(grep -E '^[A-Za-z0-9_.-]+==' "$in_file")
done
$py_changed || note "- all up to date"

if $py_changed && ! $DRY_RUN; then
  uv_bin="$(command -v uv || true)"
  if [ -z "$uv_bin" ]; then # bootstrap the lock's own pinned, checksum-verified uv
    arch="$(uname -m)"
    case "$arch" in x86_64) a=amd64 t=x86_64 ;; aarch64 | arm64) a=arm64 t=aarch64 ;; *) echo "unsupported arch $arch" >&2; exit 1 ;; esac
    entry="$(jq -c '.tools[] | select(.name == "uv")' "$LOCK")"
    url="$(jq -r .url <<<"$entry")"
    url="${url//\{version\}/$(jq -r .version <<<"$entry")}"
    url="${url//\{arch\}/$t}"
    curl -fsSL -o "$work/uv.tgz" "$url"
    echo "$(jq -r --arg a "$a" '.sha256[$a]' <<<"$entry")  $work/uv.tgz" | sha256sum -c --quiet -
    tar -xzf "$work/uv.tgz" -C "$work" --strip-components=1
    uv_bin="$work/uv"
  fi
  for in_file in "$PYDIR"/requirements*.in; do
    UV_NO_CACHE=1 "$uv_bin" pip compile -q --universal --python-version 3.13 --generate-hashes \
      "$in_file" -o "${in_file%.in}.lock"
  done
  note "- hash locks recompiled with uv"
fi

note ""
note "### apt snapshot"
current_snap="$(sed -n 's/^ARG APT_SNAPSHOT=//p' "$DOCKERFILE")"
today="$(date -u +%Y%m%d)T000000Z"
if [ "$current_snap" = "$today" ]; then
  note "- already ${today}"
elif curl -fsSIL -o /dev/null "https://snapshot.debian.org/archive/debian/${today}/dists/trixie/InRelease" &&
  curl -fsSIL -o /dev/null "https://snapshot.debian.org/archive/debian-security/${today}/dists/trixie-security/InRelease"; then
  note "- ${current_snap} → **${today}**"
  $DRY_RUN || sed -i "s/^ARG APT_SNAPSHOT=.*/ARG APT_SNAPSHOT=${today}/" "$DOCKERFILE"
else
  note "- ⚠️ snapshot ${today} not reachable; kept ${current_snap}"
fi

[ -n "${BUMP_SUMMARY:-}" ] && cp "$summary" "$BUMP_SUMMARY"
if $DRY_RUN; then
  echo "✅ Dry run complete — no files changed"
else
  echo "✅ Bump complete: ${#bumped[@]} tool(s); Python changed: ${py_changed}"
fi
