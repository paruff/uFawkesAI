---
name: documentation
description: "Enforce minimum documentation standard across uFawkes* repos. Use when auditing a repo before release, onboarding a new repo to the suite, or implementing roadmap item 0.6 (cross-repo README links). Directly supports DORA AI Capability 3 and the 2023 DORA finding that documentation quality amplifies all technical capabilities."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Documentation

> **Load trigger:** `"load documentation skill"` > **DORA:** AI Capability 3 (AI-accessible internal data) + 2023 DORA finding: documentation quality
> **Token cost:** Low

## Purpose

Apply a consistent, minimum documentation standard across all 8 uFawkes\* repos.
Ensures that documentation is good enough to be AI-accessible (capability 3),
good enough to reduce onboarding friction for Dojo learners (capability 6), and
good enough to build platform trust for users evaluating fawkes (capability 7).

DORA 2023 State of DevOps: Quality documentation amplifies the positive impact of
all technical capabilities. This is not a vanity metric — it is a force multiplier.

## Minimum README Standard

Every uFawkes\* repo README must contain these sections. Use this as a checklist.
Sections marked ✅ are required for release. Sections marked ⚠ are required within
30 days of first release.

| Section              | Required | Content                                                                    |
| -------------------- | -------- | -------------------------------------------------------------------------- |
| **What This Is**     | ✅       | 2-3 sentences. What problem does this repo solve? Who is it for?           |
| **What This Is Not** | ✅       | 1-2 sentences. Explicit scope boundary prevents misuse.                    |
| **Status**           | ✅       | Current version, what works today, what's next. Update every release.      |
| **Quick Start**      | ✅       | Commands to go from clone to running in <5 min. Must actually work.        |
| **Architecture**     | ⚠        | Link to ARCHITECTURE.md or a brief component diagram.                      |
| **Testing**          | ✅       | How to run tests. Expected output. What the tests cover.                   |
| **DORA Capability**  | ⚠        | Which DORA capability this repo addresses and how.                         |
| **Contributing**     | ✅       | Link to CONTRIBUTING.md. CONTRIBUTING.md must not be a placeholder.        |
| **Suite Context**    | ✅       | Where this fits in the uFawkes portfolio. Links to fawkes and ufawkes.dev. |
| **License**          | ✅       | License type and link.                                                     |

## Cross-Repo Links Standard (Roadmap Item 0.6)

Every uFawkes\* repo README "Suite Context" section must contain:

```markdown
## Suite Context

This repo is part of the [uFawkes platform suite](https://ufawkes.dev).

| Repo                                                 | Purpose                                                   |
| ---------------------------------------------------- | --------------------------------------------------------- |
| [fawkes](https://github.com/paruff/fawkes)           | Core IDP — orchestrates the full platform                 |
| [uFawkesObs](https://github.com/paruff/uFawkesObs)   | Observability substrate (OTel, Prometheus, Grafana, Loki) |
| [uFawkesPipe](https://github.com/paruff/uFawkesPipe) | Lightweight CI/CD (Woodpecker + Portainer)                |
| [uFawkesDevX](https://github.com/paruff/uFawkesDevX) | Developer experience (CDE, golden paths)                  |
| [uFawkesDORA](https://github.com/paruff/uFawkesDORA) | DORA metrics and dashboards                               |
| [uFawkesSec](https://github.com/paruff/uFawkesSec)   | Security posture (policy-as-code)                         |
| [uFawkesAI](https://github.com/paruff/uFawkesAI)     | AI agent and skill suite                                  |
| [uFawkes.dev](https://ufawkes.dev)                   | Documentation and learning (Dojo)                         |

**Roadmap:** [fawkes/ROADMAP.md](https://github.com/paruff/fawkes/blob/main/ROADMAP.md)
```

## Required Files Beyond README

| File                                        | Required | Passes?                                    |
| ------------------------------------------- | -------- | ------------------------------------------ |
| `CHANGELOG.md`                              | ✅       | Has at least one entry; not empty          |
| `CONTRIBUTING.md`                           | ✅       | Not a placeholder; has at least 3 sections |
| `AI_STANCE.md`                              | ✅       | Present and reviewed within 90 days        |
| `AGENTS.md`                                 | ✅       | Lists current skills and agent roles       |
| `ARCHITECTURE.md` or `docs/ARCHITECTURE.md` | ✅       | Present and not a stub                     |
| `LICENSE`                                   | ✅       | Present                                    |
| `.github/CODEOWNERS`                        | ⚠        | Present (roadmap item 0.10)                |
| `tests/README.md`                           | ✅       | Explains how to run tests                  |

## Placeholder Detection

These patterns indicate a file exists but is not complete:

```bash
# Run against any repo to detect placeholders
grep -rn "\[Add " --include="*.md" . | grep -v ".git" | grep -v "node_modules"
grep -rn "TODO:" --include="*.md" . | grep -v ".git"
grep -rn "Coming soon" --include="*.md" . | grep -v ".git"
grep -rn "Under construction" --include="*.md" . | grep -v ".git"
```

Each detected placeholder is a documentation gap. File as a GitHub issue with
label `documentation`, `tier-1` if pre-release, `tier-2` if post-release.

## Documentation Currency Check (CI Integration)

Add this to any repo's CI workflow to catch stale documentation:

```yaml
# .github/workflows/docs-lint.yml
name: Documentation Lint
on: [push, pull_request]
jobs:
  docs-lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Check required files exist
        run: |
          for f in README.md CHANGELOG.md CONTRIBUTING.md AI_STANCE.md AGENTS.md LICENSE; do
            [ -f "$f" ] || (echo "MISSING: $f" && exit 1)
          done
          [ -f "ARCHITECTURE.md" ] || [ -f "docs/ARCHITECTURE.md" ] || \
            (echo "MISSING: ARCHITECTURE.md (check docs/ too)" && exit 1)

      - name: Check for placeholders
        run: |
          if grep -rn "\[Add contribution guidelines here\]" --include="*.md" . | grep -v ".git"; then
            echo "ERROR: CONTRIBUTING.md is still a placeholder"
            exit 1
          fi

      - name: Lint markdown
        uses: DavidAnson/markdownlint-cli2-action@v16
        with:
          globs: "**/*.md"
          config: ".markdownlint.json"

      - name: Check broken links
        uses: lycheeverse/lychee-action@v1
        with:
          args: --no-progress --exclude-all-private '**/*.md'
```

## Audit Output

When running a documentation audit on a repo, produce:

```json
{
  "skill": "documentation",
  "repo": "paruff/REPO_NAME",
  "audit_date": "YYYY-MM-DD",
  "release_ready": false,
  "readme": {
    "what_this_is": true,
    "what_this_is_not": true,
    "status_section": true,
    "quick_start": true,
    "testing_section": false,
    "dora_capability": false,
    "contributing_link": true,
    "suite_context": false,
    "license": true
  },
  "required_files": {
    "CHANGELOG.md": true,
    "CONTRIBUTING.md": "placeholder",
    "AI_STANCE.md": false,
    "AGENTS.md": true,
    "ARCHITECTURE.md": true,
    "LICENSE": true,
    "tests/README.md": false
  },
  "placeholders_found": 2,
  "cross_repo_links": false,
  "ci_docs_lint": false,
  "gaps": [
    { "file": "CONTRIBUTING.md", "issue": "placeholder", "tier": 1 },
    { "file": "AI_STANCE.md", "issue": "missing", "tier": 1 },
    { "file": "tests/README.md", "issue": "missing", "tier": 1 },
    { "section": "suite_context", "issue": "missing from README", "tier": 1 }
  ],
  "issues_to_file": 4
}
```

## Sub-Skills

| Sub-skill                        | Purpose                                                   |
| -------------------------------- | --------------------------------------------------------- |
| `documentation/audit`            | Full documentation audit for one repo                     |
| `documentation/suite-audit`      | Audit all 8 uFawkes\* repos and produce a parity matrix   |
| `documentation/cross-repo-links` | Add Suite Context section to all repos (roadmap item 0.6) |
| `documentation/ci-integration`   | Add docs-lint CI workflow to a repo                       |
