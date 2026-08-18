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
decision each time. This agent is a thin trigger: the write-once-ship-four-times
checklist (triage → document → tag/publish → dev.to → LinkedIn → ufawkes.dev),
semver rules, and minimum-shippable-increment rule live in the `release` skill —
this file only defines when to run, what to check first, and what to hand off
afterward (which the skill doesn't know about).

## Trigger Conditions

| Trigger               | Description                                                      |
| --------------------- | ------------------------------------------------------------------ |
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

### Run the release checklist (delegate to skill)

Follow the `release` skill's Phase 1–6 checklist in full: triage open issues and
blockers, document (CHANGELOG + README Status), tag and publish the GitHub Release,
draft the dev.to post, draft the LinkedIn post, and update the ufawkes.dev stack
page. Use that skill's semver decision table and minimum-shippable-increment rule
to resolve any judgment calls — do not re-derive them here.

### Hand off to measure agent (agent-specific — not in the skill)

After the release skill's checklist completes, file a GitHub issue:
`"measure: track DORA metrics for vVERSION post-release"`, labeled
`dora-measurement`, so the `measure` agent picks it up on its next trigger.
This cross-agent handoff is this agent's own responsibility, not the skill's.

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

- [ ] All `release` skill success criteria met (blockers resolved, CHANGELOG,
      tag/release published, dev.to + LinkedIn drafts, ufawkes.dev updated)
- [ ] Measure agent issue filed
