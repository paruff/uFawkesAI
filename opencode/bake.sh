#!/usr/bin/env bash
# Bake the OpenCode config and the four uFawkesAI agents into the image.
# Called only by images/devsecops/Dockerfile. It never runs on a host: your own
# ~/.config/opencode is yours, and this script refuses to touch it.
set -euo pipefail

[ -n "${UFAWKES_IMAGE_BUILD:-}" ] || {
  echo "✖ bake.sh runs only during the image build (UFAWKES_IMAGE_BUILD unset)" >&2
  exit 1
}

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="${AGENTS_SRC:-$SRC/../.agents/agents}"
DEST="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"

mkdir -p "$DEST/commands" "$DEST/agents"
cp "$SRC"/{fallback.json,package.json,package-lock.json,AGENTS.md} "$DEST/"
# __HOME__ is the one machine-specific token in opencode.jsonc.
sed "s|__HOME__|$HOME|g" "$SRC/opencode.jsonc" > "$DEST/opencode.jsonc"
cp "$SRC"/commands/*.md "$DEST/commands/"
cp "$AGENTS_SRC"/*.md "$DEST/agents/"

# Plugins: exact pins from package-lock.json, never an ad-hoc install.
(cd "$DEST" && npm ci --no-audit --no-fund)
"$SRC/validate.sh" "$DEST"
echo "✔ opencode config baked -> $DEST"
