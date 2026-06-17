---
name: release
description: "Execute the weekly release checklist for any uFawkes* repo. Use when an increment is ready to ship. Implements the write-once-ship-four-times pattern: README → CHANGELOG → GitHub Release → dev.to → LinkedIn → ufawkes.dev."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Release

> **Load trigger:** `"load release skill"` > **DORA:** AI Capability 4 (Strong version control) + Core: Continuous Delivery
> **Token cost:** Low

## Purpose

Make "one new thing a week" a checklist execution, not a creative decision each time.
Source material is written once (README "What This Is" + "Status" sections) and
reformatted four times: CHANGELOG entry, GitHub Release notes, dev.to post, LinkedIn post.
The fifth output — ufawkes.dev stack page update — is a one-line front matter change.

## Write-Once, Ship-Four-Times Pattern

```
README "Status" + "What This Is"
    │
    ├─→ CHANGELOG entry (3-5 bullet points, past tense)
    │
    ├─→ GitHub Release notes (CHANGELOG + context sentences)
    │
    ├─→ dev.to post (Why→What→How→Proof→Next structure, 400-800 words)
    │
    └─→ LinkedIn post (hook + 3 paragraphs, max 200 words)
         └─→ ufawkes.dev stack page (one-line front matter: latest_version, coming_soon)
```

## Semver Decision Table

| Change type                                            | Bump           | Example                                  |
| ------------------------------------------------------ | -------------- | ---------------------------------------- |
| Breaking change to public API or golden path interface | MAJOR (v1.0.0) | Removing a supported config key          |
| New capability, backward compatible                    | MINOR (v0.x.0) | Adding a new Grafana dashboard           |
| Bug fix, doc update, dependency update                 | PATCH (v0.x.y) | Fixing a broken healthcheck              |
| Documentation only, no behavior change                 | PATCH          | README update, CONTRIBUTING.md filled in |

When in doubt, PATCH. Never hold a PATCH for a MINOR.

## Release Checklist

### Phase 1 — Triage (10 min)

```bash
# List open issues, check for blockers
gh issue list --repo paruff/REPO_NAME --state open \
  --json number,title,labels \
  --jq '.[] | "\(.number): \(.title) [\(.labels[].name // "unlabeled")]"'

# Label blockers — STOP if any found, resolve first
gh issue edit ISSUE_NUMBER --repo paruff/REPO_NAME --add-label "release-blocker"

# Label future work
gh issue edit ISSUE_NUMBER --repo paruff/REPO_NAME --add-label "v0.2"
gh issue edit ISSUE_NUMBER --repo paruff/REPO_NAME --add-label "later"
```

**Gate:** If any `release-blocker` issues remain open, do not proceed. Resolve or
defer them first. A release with known blockers is not a release.

### Phase 2 — Document (15 min)

```bash
# Verify no uncommitted changes
git status --short

# Add CHANGELOG entry (edit manually or via agent)
# Format:
# ## [v0.x.y] - YYYY-MM-DD
# ### Added
# - Feature description (one line per item)
# ### Changed
# - What changed and why
# ### Fixed
# - Bug description
# ### Security (include if any security fix)
# - Security fix description
# Omit empty sections.

# Update README "Status" section to reflect current state
# Check CONTRIBUTING.md is not a placeholder
grep -q "\[Add contribution" CONTRIBUTING.md && \
  echo "WARNING: CONTRIBUTING.md is still a placeholder — fill it before release"
```

### Phase 3 — Tag and publish (10 min)

```bash
export REPO="paruff/REPO_NAME"
export VERSION="v0.x.y"
export SUMMARY="one-line summary of this release"

# Commit release prep
git add CHANGELOG.md README.md CONTRIBUTING.md
git commit -m "chore(release): prepare ${VERSION}"

# Tag
git tag -a "${VERSION}" -m "Release ${VERSION}: ${SUMMARY}"

# Push
git push origin main
git push origin "${VERSION}"

# Write release notes to temp file
cat > /tmp/release-notes.md << EOF
## ${VERSION}: ${SUMMARY}

$(grep -A 20 "## \[${VERSION}\]" CHANGELOG.md | tail -n +2 | head -n 20)

**Full changelog:** https://github.com/${REPO}/blob/main/CHANGELOG.md
**Documentation:** https://ufawkes.dev/STACK_NAME/
EOF

# Create GitHub Release
gh release create "${VERSION}" \
  --repo "${REPO}" \
  --title "${VERSION}: ${SUMMARY}" \
  --notes-file /tmp/release-notes.md
```

### Phase 4 — dev.to post draft (20 min)

Structure (Why→What→How→Proof→Next):

```markdown
---
title: "[REPO_NAME] VERSION: SUMMARY"
published: false
tags: devops, platform-engineering, dora, opensource
---

## Why

[1 paragraph: what problem this solves. Use the JTBD statement from discovery-brief.md.
Who has this problem? Why does it matter now?]

## What

[1 paragraph: what shipped in this release. Not a feature list — a capability statement.
What can you do now that you couldn't do before?]

## How

[2-3 paragraphs or a short code block: the key implementation decision or the quick start.
For a tooling release: `docker compose up` and what you see.
For a skill release: the load trigger and example output.]

## Proof

[1 paragraph or screenshot description: evidence it works.
Reference the test suite, CI badge, or a DORA metric that improved.]

## What's Next

[3-5 bullet points: next release scope, open issues, how to contribute.
End with a link to the GitHub repo and ufawkes.dev stack page.]
```

### Phase 5 — LinkedIn post draft (10 min)

```
Hook sentence (grab attention — a question, a number, or a counterintuitive claim)

Paragraph 1: The problem (2-3 sentences)
Paragraph 2: What shipped (2-3 sentences, no jargon)
Paragraph 3: Why it matters + call to action (1-2 sentences + link)

Max 200 words. No bullet points in LinkedIn posts — they read as lists, not stories.
Tags: #devops #platformengineering #dora #opensource #developerexperience
```

### Phase 6 — ufawkes.dev stack page (5 min)

```bash
# In the ufawkes.dev repo
# Update the stack page front matter
# File: typically _stacks/STACK_NAME.md or pages/STACK_NAME/index.md

# Change:
#   coming_soon: true
# To:
#   coming_soon: false
#   latest_version: v0.x.y
#   release_date: YYYY-MM-DD

# Commit
git add _stacks/STACK_NAME.md  # or equivalent path
git commit -m "fix(STACK_NAME): update stack page for ${VERSION} release"
git push origin main
```

## Minimum Shippable Increment Rule

| If...                             | Then the release is...                                                                                  |
| --------------------------------- | ------------------------------------------------------------------------------------------------------- |
| Code change merged and tests pass | Feature/fix release                                                                                     |
| Docs updated but no code change   | Documentation release (still tag and publish)                                                           |
| No code or docs ready             | Decision post ("Why we chose X") — still publish to dev.to/LinkedIn                                     |
| Nothing ready at all              | Skip the week — but write one sentence in CHANGELOG: "## [Unreleased] — No release this week: [reason]" |

The weekly cadence is the publishing rhythm. Missing one week is fine.
Missing three in a row signals a planning problem — file an issue.

## Output Format

```json
{
  "skill": "release",
  "repo": "paruff/REPO_NAME",
  "version": "v0.x.y",
  "summary": "string",
  "blockers_resolved": true,
  "changelog_updated": true,
  "tag_pushed": true,
  "github_release_url": "https://github.com/paruff/REPO/releases/tag/v0.x.y",
  "devto_draft_path": "drafts/devto-YYYY-MM-DD.md",
  "linkedin_draft_path": "drafts/linkedin-YYYY-MM-DD.md",
  "ufawkes_dev_updated": true,
  "contributing_placeholder": false,
  "next_version_suggested": "v0.x+1.0"
}
```
