#!/usr/bin/env bash
# images/devsecops/install-tools.sh — runs inside the image build.
#
# Installs every tools.lock.json entry of one variant for the build's
# architecture into <dest>/usr/local, refusing any download whose SHA-256
# differs from the lock, and appends each tool to <dest>/etc/ufawkes/tools.json.
#
# Usage: install-tools.sh <lock.json> <variant> <dest>

# jq programs reference jq variables ($v, $a, …) — single quotes are intended.
# shellcheck disable=SC2016

set -euo pipefail

LOCK="$1"
VARIANT="$2"
DEST="$3"
ARCH="$(dpkg --print-architecture)"
MANIFEST="${DEST}/etc/ufawkes/tools.json"

fail() {
  echo "FAIL: $*" >&2
  exit 1
}

render() {
  local s="$1"
  s="${s//\{version\}/$2}"
  s="${s//\{arch\}/$3}"
  printf '%s' "$s"
}

mkdir -p "${DEST}/usr/local/bin" "$(dirname "$MANIFEST")"
[ -f "$MANIFEST" ] || echo '[]' > "$MANIFEST"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT

count=0
while IFS= read -r entry; do
  name="$(jq -r .name <<< "$entry")"
  version="$(jq -r .version <<< "$entry")"
  token="$(jq -r --arg a "$ARCH" '.arch[$a] // empty' <<< "$entry")"
  sha="$(jq -r --arg a "$ARCH" '.sha256[$a] // empty' <<< "$entry")"
  { [ -n "$token" ] && [ -n "$sha" ]; } || fail "${name}: no ${ARCH} entry in lock"
  url="$(render "$(jq -r .url <<< "$entry")" "$version" "$token")"
  format="$(jq -r .format <<< "$entry")"

  file="${work}/${name}.download"
  curl -fsSL --retry 3 -o "$file" "$url"
  echo "${sha}  ${file}" | sha256sum -c --quiet - || fail "${name}: checksum mismatch for ${url}"

  install_mode="$(jq -r '.install // "bin"' <<< "$entry")"
  if [ "$install_mode" = "tree" ]; then
    # Arch-independent content (e.g. agent skills): copy one subdirectory of
    # the archive to <dest>/opt/agent-skills/<name>, plus a VERSION stamp
    # that version_cmd reads back.
    subdir="$(jq -r .subdir <<< "$entry")"
    tree="${DEST}/opt/agent-skills/${name}"
    mkdir -p "${work}/${name}" "$tree"
    tar -xzf "$file" --strip-components=1 -C "${work}/${name}"
    [ -d "${work}/${name}/${subdir}" ] || fail "${name}: archive has no ${subdir}/"
    cp -a "${work}/${name}/${subdir}/." "$tree/"
    echo "$version" > "${tree}/VERSION"
  elif [ "$install_mode" = "prefix" ]; then
    # */include: C headers only matter for compiling native add-ons, and
    # every npm install in the image runs with --ignore-scripts (-67 MB).
    tar -xf "$file" --strip-components=1 -C "${DEST}/usr/local" \
      --exclude='*/CHANGELOG.md' --exclude='*/README.md' --exclude='*/LICENSE' \
      --exclude='*/include'
  elif [ "$format" = "binary" ]; then
    install -m 0755 "$file" "${DEST}/usr/local/bin/${name}"
  else
    mkdir -p "${work}/${name}"
    if [ "$format" = "zip" ]; then
      unzip -q "$file" -d "${work}/${name}"
    else
      tar -xf "$file" -C "${work}/${name}"
    fi
    while IFS= read -r bin; do
      bin="$(render "$bin" "$version" "$token")"
      install -m 0755 "${work}/${name}/${bin}" "${DEST}/usr/local/bin/$(basename "$bin")"
    done < <(jq -r '.bins[]' <<< "$entry")
  fi

  tmp="$(mktemp)"
  jq --arg n "$name" --arg v "$version" --arg s "$sha" --arg var "$VARIANT" \
    '. + [{name: $n, version: $v, sha256: $s, variant: $var}]' "$MANIFEST" > "$tmp"
  mv "$tmp" "$MANIFEST"
  count=$((count + 1))
  echo "  installed ${name} ${version} (${ARCH})"
done < <(jq -c --arg v "$VARIANT" '.tools[] | select(.variant == $v)' "$LOCK")

[ "$count" -gt 0 ] || fail "no tools for variant '${VARIANT}' in ${LOCK}"
echo "✅ Installed ${count} ${VARIANT} tool(s) for ${ARCH}"
