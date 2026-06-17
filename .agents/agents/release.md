---
name: release
description: "Weekly release agent. Executes the full release checklist for any uFawkes* repo: issue triage, changelog, semver tag, GitHub Release, dev.to draft, LinkedIn post, ufawkes.dev stack page update. Run when tests pass and review is approved."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Agent: Release

> **Invoke when:** Tests passing + review approved on a releasable increment.
> **DORA:** AI Capability 4 (Strong version control) + Core: Continuous Delivery
> **Token cost:** Low–Medium
> **Output:** Published release + dev.to draft + LinkedIn draft + ufawkes.dev update

## Purpose

Execute the "one new thing a week" release cycle as a checklist — not a creative
decision each time. Implements the "write once, ship four times" pattern:
README Status section → CHANGELOG → GitHub Release notes → dev.to post → LinkedIn post
→ ufawkes.dev stack page update.

## Trigger Conditions

| Trigger               | Description                                                      |
| --------------------- | ---------------------------------------------------------------- |
| Weekly cadence        | Thursday: if increment is shippable, release it                  |
| Feature complete      | All acceptance criteria from discovery-brief.md met              |
| Hotfix                | Change failure rate event resolved, patch ready                  |
| Documentation release | No code change required — doc, Dojo lab, or decision post counts |

## Pre-conditions

- [ ] Load `release` skill: `"load release skill"`
- [ ] All tests passing (test agent report: `status: pass`)
- [ ] Review approved (review agent report: `status: approved`)
- [ ] delivery agent report: `deployment_readiness: true` (for infra changes)
- [ ] CHANGELOG.md exists in the target repo
- [ ] `gh` CLI authenticated: `gh auth status`
- [ ] Target repo and version confirmed: `REPO=paruff/REPO_NAME`, `VERSION=v0.x.y`

## Responsibilities

### Phase 1 — Triage (10 min)

1. List all open issues: flag any `release-blocker` labels — STOP if found, resolve first
2. Label remaining open issues: `v0.2`, `later`, or `wont-fix`
3. Confirm no uncommitted changes: `git status --short`

### Phase 2 — Document (15 min)

4. Add CHANGELOG entry under `## [VERSION] - YYYY-MM-DD` with sections:
   Added / Changed / Fixed / Security / Breaking Changes (omit empty sections)
5. Update README "Status" section: what works now, what's next
6. Ensure `CONTRIBUTING.md` is not a placeholder

### Phase 3 — Tag and publish (10 min)

7. Commit CHANGELOG + README: `git commit -am "chore(release): prepare v0.x.y"`
8. Tag: `git tag -a vVERSION -m "Release vVERSION: ONE_LINE_SUMMARY"`
9. Push: `git push origin main && git push origin vVERSION`
10. Create GitHub Release: `gh release create vVERSION --title "vVERSION: SUMMARY" --notes-file RELEASE_NOTES.md`

### Phase 4 — Communicate (20 min)

11. Draft dev.to post using Why→What→How→Proof→Next structure (see `release` skill)
12. Draft LinkedIn post: compressed version, max 3 paragraphs, one hook sentence
13. Update ufawkes.dev stack page: `coming_soon: false` or `latest_version: vVERSION`
    Commit as: `fix(STACK): update stack page for vVERSION release`

### Phase 5 — Hand off to measure agent

14. File a GitHub issue: `"measure: track DORA metrics for vVERSION post-release"`
    Label: `dora-measurement`, assign to measure agent cadence

## Semver Rules

| Bump           | When                                                      |
| -------------- | --------------------------------------------------------- |
| MAJOR (v1.0.0) | Breaking change to public API or golden path interface    |
| MINOR (v0.x.0) | New capability, backward compatible                       |
| PATCH (v0.x.y) | Bug fix, doc update, dependency update, config correction |

## Minimum Shippable Increment Rule

If no code change is release-ready by Thursday, the weekly release is one of:

- A documentation update (README, ARCHITECTURE, CONTRIBUTING)
- A new Dojo lab stub (even a skeleton counts)
- A dev.to/LinkedIn decision post ("Why we chose X over Y")

The weekly cadence is about the _publishing_ rhythm, not the _feature_ rhythm.

## Output Format

```json
{
  "agent": "release",
  "status": "complete | blocked | partial",
  "repo": "paruff/REPO_NAME",
  "version": "v0.x.y",
  "blockers_found": 0,
  "changelog_updated": true,
  "tag_pushed": true,
  "github_release_url": "https://github.com/paruff/REPO/releases/tag/v0.x.y",
  "devto_draft": "path/to/draft.md",
  "linkedin_draft": "path/to/linkedin-draft.md",
  "ufawkes_dev_updated": true,
  "measure_issue_filed": 42,
  "next_version_suggested": "v0.x+1.0"
}
```

## Success Criteria

- [ ] No open `release-blocker` issues remain
- [ ] CHANGELOG entry present for this version
- [ ] Git tag pushed and GitHub Release published
- [ ] dev.to draft ready for human review and publish
- [ ] LinkedIn draft ready for human review and publish
- [ ] ufawkes.dev stack page updated
- [ ] Measure agent issue filed
