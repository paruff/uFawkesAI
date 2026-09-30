---
name: ufawkes-knowledge
description: Use when searching uFawkesAI institutional knowledge via qmd — agent orchestration, AI-SDLC pipeline, skill/registry conventions, DORA measurement — or when an answer should come from this repo's docs rather than its code.
---

# uFawkesAI Knowledge (QMD)

## Overview

This repo has a project-local QMD index (`.qmd/`). **Run every `qmd` command from the repo root** so the project index is picked up. Search for leads, then retrieve full documents before answering — never answer from snippets alone.

## Collections

| Collection | Scope |
|---|---|
| `uFawkesAI-.agents` | `.agents/**/*.md` — agents, skills, rules, workflows, registry |
| `uFawkesAI-docs` | `docs/**/*.md` |

Not indexed: root docs (`AGENTS.md`, `README.md`, …). Symlinked harness mounts (`.claude/skills`, `.opencode/skills`) resolve into `.agents/` and are already covered by `uFawkesAI-.agents`.

## Query modes

| Mode | Time | Use for |
|---|---|---|
| `qmd search "..." -n 5` | <1s | **Default.** BM25 keyword search, no LLM |
| `qmd vsearch "..." -n 5` | ~15s | Semantic / paraphrased questions |
| `qmd query "..." --no-rerank -n 5` | ~80s | Hybrid last resort (CPU expansion is slow) |

**Known issue:** plain `qmd query` (rerank enabled) stalls indefinitely on this machine — always pass `--no-rerank`.

## Typical loop

```bash
qmd search "cross-validation pairwise rules" -n 5   # leads: #docid + snippet
qmd get "#abc123"                                   # full doc (line-numbered)
qmd multi-get "#abc123,#def456" --format md         # batch fetch
qmd status                                          # health + pending embeddings
```

## After editing indexed docs

```bash
qmd update && qmd embed        # re-embeds all collections; CPU full pass ≈ 8 min
# scope one collection: qmd embed -c uFawkesAI-docs
```

Deep help: `qmd skills get qmd --full`.
