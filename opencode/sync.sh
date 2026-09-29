#!/usr/bin/env bash
# Install the versioned OpenCode config from this directory into a config dir.
#
# In the devcontainer you do not need this: the ufawkes-devsecops-ai image
# bakes the config, pinned plugins and the four uFawkesAI agents in at build
# time. This script is for a HOST machine, and it is deliberately cautious:
#
#   sync.sh            preview only — shows what would change, writes nothing
#   sync.sh --apply    backs up the target dir, then installs
#
# Target: $OPENCODE_CONFIG_DIR, else ~/.config/opencode. Only OpenCode's own
# config dir is touched — never ~/.claude. OpenCode loads config once at boot:
# restart it after --apply.
set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="${AGENTS_SRC:-$SRC/../.agents/agents}"
DEST="${OPENCODE_CONFIG_DIR:-$HOME/.config/opencode}"
FILES=(opencode.jsonc fallback.json package.json package-lock.json AGENTS.md)
# Files a previous layout left behind that must not stay in the target.
STALE=(tiers.json plugins/superpowers-bridge.js skills/superpowers)

APPLY=false
case "${1:-}" in
  --apply) APPLY=true ;;
  "") ;;
  *)
    echo "usage: sync.sh [--apply]" >&2
    exit 2
    ;;
esac

for f in "${FILES[@]}"; do
  [ -f "$SRC/$f" ] || {
    echo "✖ missing $SRC/$f" >&2
    exit 1
  }
done

# Render the __HOME__ token for this machine into a staging dir, so the preview
# compares exactly what would be installed.
stage="$(mktemp -d)"
trap 'rm -rf "$stage"' EXIT
for f in "${FILES[@]}"; do cp "$SRC/$f" "$stage/$f"; done
sed "s|__HOME__|$HOME|g" "$SRC/opencode.jsonc" > "$stage/opencode.jsonc"
mkdir -p "$stage/commands" "$stage/agents"
cp "$SRC"/commands/*.md "$stage/commands/" 2> /dev/null || true
cp "$AGENTS_SRC"/*.md "$stage/agents/" 2> /dev/null || true

changes=0
for rel in "${FILES[@]}" $(cd "$stage" && ls commands/*.md agents/*.md 2> /dev/null); do
  if [ ! -f "$DEST/$rel" ]; then
    echo "  + $rel (new)"
    changes=$((changes + 1))
  elif ! cmp -s "$stage/$rel" "$DEST/$rel"; then
    echo "  ~ $rel"
    diff -u "$DEST/$rel" "$stage/$rel" | sed -n '3,40p' | sed 's/^/      /' || true
    changes=$((changes + 1))
  fi
done
for rel in "${STALE[@]}"; do
  if [ -e "$DEST/$rel" ] || [ -L "$DEST/$rel" ]; then
    echo "  - $rel (stale, would be removed)"
    changes=$((changes + 1))
  fi
done

if [ "$changes" -eq 0 ]; then
  echo "✔ $DEST already matches $SRC — nothing to do"
  exit 0
fi

if ! $APPLY; then
  echo
  echo "Preview only: ${changes} change(s) to $DEST. Nothing was written."
  echo "Run 'bash $0 --apply' to back up $DEST and install."
  exit 0
fi

mkdir -p "$DEST"
if [ -n "$(ls -A "$DEST" 2> /dev/null)" ]; then
  backup="$HOME/opencode-config-backup-$(date +%Y%m%d-%H%M%S).tgz"
  tar -czf "$backup" -C "$(dirname "$DEST")" --exclude="$(basename "$DEST")/node_modules" "$(basename "$DEST")"
  echo "  backup: $backup"
fi

cp -R "$stage"/. "$DEST"/
for rel in "${STALE[@]}"; do rm -rf "${DEST:?}/$rel"; done

# Plugins: exact pins from package-lock.json, never an ad-hoc install.
(cd "$DEST" && npm ci --no-audit --no-fund)
"$SRC/validate.sh" "$DEST"

echo "✔ opencode config installed -> $DEST (restart OpenCode to load it)"
