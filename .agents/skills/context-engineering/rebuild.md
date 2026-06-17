---
name: context-engineering/rebuild
description: "Force rebuild of the graphify context corpus for a repo. Use when corpus is stale (>24hrs), after significant doc updates, after adding new files to the minimum corpus set, or before a high-stakes agent session."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
  parent: context-engineering
---

# Sub-Skill: Context Engineering — Rebuild

> **Load trigger:** `"load context-engineering/rebuild skill"`
> **DORA:** AI Capability 3 (AI-accessible internal data)
> **Token cost:** Low
> **When to use:** Corpus stale, major doc updates, before high-stakes sessions.

## Purpose

Ensure the graphify knowledge graph reflects the current state of the repo before
an agent session begins. A stale corpus is worse than no corpus — it gives the
agent confident-but-wrong context.

## When to Force a Rebuild

| Trigger                                  | Rebuild required? |
| ---------------------------------------- | ----------------- |
| Corpus > 24hrs old                       | ✅ Yes            |
| Any `*.md` file updated since last build | ✅ Yes            |
| New skill or agent file added            | ✅ Yes            |
| AGENTS.md updated                        | ✅ Yes            |
| Architecture changed                     | ✅ Yes            |
| Before any migration session             | ✅ Yes            |
| Routine feature work, corpus < 6hrs old  | ❌ No             |

## Pre-Rebuild Checks

Before rebuilding, verify the corpus won't be built from incomplete source material:

```bash
# 1. Run placeholder check — don't index placeholder content
PLACEHOLDERS=$(grep -rn "\[Add contribution\|CONFIRM_VARIANT\|TODO:" \
  --include="*.md" . 2>/dev/null | grep -v ".git" | wc -l)
[ "$PLACEHOLDERS" -gt 0 ] && echo "⚠ WARNING: ${PLACEHOLDERS} placeholders will be indexed"

# 2. Verify minimum corpus files present
for f in README.md AGENTS.md ARCHITECTURE.md CONTRIBUTING.md AI_STANCE.md; do
  [ -f "$f" ] || [ -f "docs/$(basename $f)" ] || echo "⚠ Missing: $f — corpus will be incomplete"
done

# 3. Check for secrets accidentally in tracked files (don't index secrets)
git secrets --scan 2>/dev/null || \
  grep -rn "password\|secret\|api_key\|token" --include="*.md" . | grep -v ".git" | grep -v "placeholder" | head -3
```

## Rebuild Command

**⚠ Graphify variant placeholder:** Replace `[graphify-cli]` with the actual command
for your installed graphify variant. Confirm with `which graphify && graphify --version`.

```bash
# Standard rebuild — indexes markdown, YAML, JSON
[graphify-cli] build \
  --repo . \
  --include "**/*.md,**/*.yaml,**/*.yml,**/*.json" \
  --exclude "node_modules,vendor,.git,**/*.lock,**/coverage/**" \
  --output .graphify/corpus \
  --timestamp

# Verify build succeeded
[graphify-cli] status --json | jq '{last_built, files_indexed, errors}'
```

## Selective Rebuild (faster — use when only docs changed)

```bash
# Only rebuild changed files since last build
[graphify-cli] build \
  --repo . \
  --changed-since "[graphify-cli] status --json | jq -r .last_built" \
  --output .graphify/corpus
```

## Post-Rebuild Verification

```bash
# Verify the corpus contains expected content
echo "Checking corpus for key documents..."

[graphify-cli] query "AGENTS.md agent responsibilities" --limit 1 | \
  grep -q "agent" && echo "✅ AGENTS.md indexed" || echo "❌ AGENTS.md not found in corpus"

[graphify-cli] query "AI_STANCE.md permitted tools" --limit 1 | \
  grep -q "opencode" && echo "✅ AI_STANCE.md indexed" || echo "❌ AI_STANCE.md not found in corpus"

[graphify-cli] query "test suite how to run" --limit 1 | \
  grep -q "test" && echo "✅ Test docs indexed" || echo "⚠ Test docs may not be indexed"
```

## .gitignore Entry

The graphify corpus output should not be committed — it's a build artifact:

```bash
# Add to .gitignore if not present
grep -q ".graphify/" .gitignore 2>/dev/null || echo ".graphify/" >> .gitignore
grep -q "corpus/" .gitignore 2>/dev/null || echo "corpus/" >> .gitignore
```

## CI Integration (optional)

For repos where freshness matters most (uFawkesAI, fawkes), build the corpus in CI
so it's always current when an opencode GitHub Action runs:

```yaml
# .github/workflows/build-corpus.yml
name: Build Context Corpus
on:
  push:
    paths: ["**/*.md", "AGENTS.md", "AI_STANCE.md"]
jobs:
  corpus:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install graphify
        run: # [confirm install command for your graphify variant]
      - name: Build corpus
        run: |
          [graphify-cli] build \
            --repo . \
            --include "**/*.md,**/*.yaml,**/*.yml" \
            --exclude "node_modules,vendor,.git" \
            --output .graphify/corpus
      - name: Upload corpus artifact
        uses: actions/upload-artifact@v4
        with:
          name: graphify-corpus
          path: .graphify/corpus/
          retention-days: 7
```

## Output Format

```json
{
  "sub-skill": "context-engineering/rebuild",
  "repo": "paruff/REPO_NAME",
  "trigger": "stale | doc-update | manual | pre-migration",
  "pre_rebuild_warnings": 0,
  "files_indexed": 47,
  "build_duration_seconds": 12,
  "last_built": "2026-06-16T10:00:00Z",
  "corpus_path": ".graphify/corpus",
  "verification_passed": true,
  "gitignore_updated": true
}
```
