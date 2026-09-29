#!/usr/bin/env bash
# Sync the versioned opencode config from this directory into the live config
# dir (~/.config/opencode, or $OPENCODE_CONFIG_DIR). Idempotent; run after any
# edit to files here. opencode loads config once at boot — restart it after.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEST="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
FILES=(opencode.jsonc fallback.json package.json package-lock.json AGENTS.md)

for f in "${FILES[@]}"; do
  if [ ! -f "$SRC/$f" ]; then
    echo "✖ missing $SRC/$f" >&2
    exit 1
  fi
done

mkdir -p "$DEST"
for f in "${FILES[@]}"; do
  cp "$SRC/$f" "$DEST/$f"
done

# Global commands (e.g. /doctor) — same SSOT treatment as the config files
for c in "$SRC"/commands/*.md; do
  [ -e "$c" ] || continue
  mkdir -p "$DEST/commands"
  cp "$c" "$DEST/commands/"
done

# tiers.json fed opencode-tui-model-router (LLM-classified model routing),
# removed for determinism — delete the stale copy so nothing reads it.
rm -f "$DEST/tiers.json"

# Retired superpowers bridge plugin — cleaned up (superpowers now loads via
# the SHA-pinned git-spec entry in opencode.jsonc)
rm -f "$DEST/plugins/superpowers-bridge.js"

# __HOME__ token -> this machine's home (same file works on host + container)
sed -i.bak "s|__HOME__|$HOME|g" "$DEST/opencode.jsonc"
rm -f "$DEST/opencode.jsonc.bak"

# Skills are registered ONLY via skills.paths (opencode.jsonc). The legacy
# skills/superpowers symlink registered every skill a second time and produced
# "duplicate skill name" warnings on boot — remove it if present.
rm -f "$DEST/skills/superpowers"

(cd "$DEST" && npm ci --no-audit --no-fund)

"$SRC/validate.sh" "$DEST"

echo "✔ opencode config synced -> $DEST"
echo "  Restart opencode: config + plugins load once at boot."
