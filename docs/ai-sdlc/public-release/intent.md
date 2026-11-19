# Intent — public release: a repo that holds up on first read

**Who:** a developer who follows a LinkedIn or dev.to post about uFawkesAI and lands on the repo, and the
maintainer who is about to publish those posts.

**Job:** decide in two minutes whether this is real and worth adopting, then adopt it. Every link, claim, badge and
file they see has to be true and used.

**Why now:** v2.3.0 is the first release the owner will announce. The repo is already public, but the 2026-11-19
audit (`/ponytail-audit`, whole repo) found seven broken links, four docs of invented content (`/users/get`,
`src/auth/`, `[PROJECT NAME]`, `JIRA-123`), unused scripts, and about 30 files of finished plans.

**Outcome:** the announcement can link to `main` without an apology. Anything overtaken by events lives in git
history only.

**Relation to v2.3.0:** this goal is the umbrella (#310). `docs/ai-sdlc/v2.3.0/` keeps the release mechanics
(#252 image publish, `templates/tests/` removal, the unit-runner fix). This plan owns everything else. Each file
is deleted by exactly one plan.

**Not in scope:** new agents or features, the Google lifecycle, the AI-DLC decision (#226), renaming the repo,
writing the posts themselves (the `release` skill does that after the tag).

**Anti-goal:** a diet that deletes something the image, CI or a user still needs. A smaller repo that breaks the
README is a failure.
