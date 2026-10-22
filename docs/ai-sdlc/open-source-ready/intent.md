# Intent — open-source ready

**Who:** a stranger who finds the repo, and an engineer using `fawkes-space` or the template.

**Job:** understand in two minutes what this is, run it, and trust that what the
README says is true.

**Why now:** the repo is already public, but the README describes an older product
(14 agents, a 135-line `AGENTS.md`, Copilot token billing); skills and docs depend on
sibling repos a stranger cannot see; and about half the files exist for the
maintainer's own process, not for users.

**Outcome:** a leaner repo where every file is used by the image, the template, or CI,
and every claim in the README is checked by `scripts/check-readme-claims.sh`.

**Not in scope:** removing the four agents, `REVIEW.md`, the image pipeline, or the v2 contract.
