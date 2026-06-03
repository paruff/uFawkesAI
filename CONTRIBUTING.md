# Contributing to uFawkesAI

Welcome to the uFawkesAI open-source project! We are thrilled to have you contribute.

This repository is an AI agent starter template. Our core philosophy is that contributions must work with real, functional agents, not just pass automated CI checks. We rely on human expertise and rigorous testing to maintain quality.

## Prerequisites

Before you begin, ensure you have the following tools installed:

*   **Git**: For version control.
*   **Node.js 20+**: The required runtime environment.
*   **bash 4.4+**: The shell environment. (Note: macOS ships with bash 3.2, so please use `brew install bash` to update.)
*   **shellcheck**: A linter for shell scripts. (`brew install shellcheck` or `apt install shellcheck`)
*   **An AI agent**: We recommend using GitHub Copilot, Claude Code, Cursor, or Codex for development assistance.

## Local Setup

Follow these steps to get your local environment running:

1.  **Fork and Clone**: Fork the repository to your GitHub account and clone it locally.
2.  **Run Setup Script**: Execute `./scripts/setup.sh`. This script is crucial as it creates necessary symlinks (e.g., `CLAUDE.md`, `.github/copilot-instructions.md`, `.cursorrules`, `.cursor/rules/AGENTS.md`) and installs git hooks from the `.github/hooks/` directory.
3.  **Run Preflight Check**: Execute `npm run preflight`. This command performs several critical checks:
    *   `shellcheck` runs on all `.sh` files to catch scripting errors.
    *   It verifies that `AGENTS.md` contains no `[PLACEHOLDER]` markers (it will warn only in template mode; set `PREFLIGHT_ENFORCE_PLACEHOLDERS=1` to enforce).
    *   It confirms that all required symlinks exist and resolve correctly.
4.  **Customize Agents**: Replace all `[PLACEHOLDER]` sections within `AGENTS.md` with your project's specific details.

**Dry Run Example:**
To see what the setup script will do without making any changes, run:
`./scripts/setup.sh --dry-run`

## Test Your Contribution With an AI Agent

We strongly encourage using an AI agent to review your own changes before submitting a Pull Request (PR).

**Example Workflow (using Claude Code):**
1.  Open `AGENTS.md` and the specific file you modified (e.g., `src/utils/auth.ts`) in your editor.
2.  Run the prompt: `"Review my changes to src/utils/auth.ts against the acceptance criteria in AGENTS.md"`
3.  **Good Output:** The agent provides specific, actionable feedback, pointing out potential race conditions or missing type guards, and suggests code improvements.
4.  **Red Flags:** The agent ignores parts of the code or gives vague, high-level advice.

**Rule:** Every PR must include a description stating which AI agent was used for testing and what specific criteria were tested.

## PR Lifecycle

The contribution process is designed to be highly automated and quality-gated.

```
  fork → branch → change → npm run preflight → commit → PR → CI gates → human review → merge
```

**CI Gate Explanations:**

*   🔗 **Agent Symlinks**: The CI system verifies that all necessary symlinks resolve correctly on a fresh clone.
*   🔢 **PR Size Gate**: PRs are limited to a maximum of 400 changed lines. If the change is genuinely atomic and cannot be split, a human maintainer must apply the `large-pr-approved` label. You cannot self-approve this.
*   🔍 **Lint**: `npm run lint` checks for stylistic and structural code consistency.
*   🔷 **TypeScript**: `npm run typecheck` ensures type safety across the entire codebase.
*   🧪 **Tests & Coverage**: `npm run test:coverage` runs all unit and integration tests. The minimum required coverage threshold is 80%.
*   🏗️ **Architecture Boundaries**: `npm run lint:architecture` enforces adherence to defined architectural layers and boundaries.

**Note:** The `ci.yml` file also validates that `AGENTS.md` does not exceed 300 lines (it issues a warning at 250 lines).

## Contribution Areas → Dojo Module Map

Use this map to guide your learning path.

| Contribution Area | Recommended Dojo Module | Belt | URL |
| :--- | :--- | :--- | :--- |
| AGENTS.md / agent instructions | Module 1: Internal Delivery Platforms | ⚪ White | https://paruff.github.io/fawkes/dojo/modules/white-belt/module-01-what-is-idp/ |
| DORA metrics / docs/METRICS.md | Module 2: DORA Metrics | ⚪ White | https://paruff.github.io/fawkes/dojo/modules/white-belt/module-02-dora-metrics/ |
| CI workflows / .github/workflows/ | Module 5: CI Fundamentals | 🟡 Yellow | https://paruff.github.io/fawkes/dojo/modules/yellow-belt/module-05-ci-fundamentals/ |
| Security scanning / SECURITY.md | Module 7: Security & Quality Gates | 🟡 Yellow | https://paruff.github.io/fawkes/dojo/modules/yellow-belt/module-07-security-quality-gates/ |
| Observability / scripts/weekly-metrics.sh | Module 13: Metrics, Logs & Traces | 🟤 Brown | https://paruff.github.io/fawkes/dojo/modules/brown-belt/module-13-metrics-logs-traces/ |
| DORA deep dive / docs/METRICS.md advanced | Module 14: DORA Deep Dive | 🟤 Brown | https://paruff.github.io/fawkes/dojo/modules/brown-belt/module-14-dora-deep-dive/ |
| Architecture / .github/skills/architecture/ | Module 17: Platform as a Product | ⚫ Black | https://paruff.github.io/fawkes/dojo/modules/black-belt/module-17-platform-as-product/ |

You don't need to complete a module before contributing — but the module will help you understand the intent behind the code you're changing.

## FAQ: Why Is My PR Blocked?

**The PR Size Gate failed.**
Your PR changed more than 400 lines. Split it into smaller PRs. If the change is genuinely atomic and cannot be split, ask a maintainer to apply the `large-pr-approved` label. You cannot apply this label yourself.

**Preflight failed on shellcheck.**
Run `shellcheck scripts/<your-script>.sh` locally. Fix all warnings before pushing. The CI gate is not lenient.

**AGENTS.md line count warning.**
`ci.yml` warns at 250 lines and blocks at 300. Move content to a skill file in `.github/skills/` and load it on demand instead.

**Symlink check failed.**
Run `./scripts/setup.sh` to recreate symlinks. This usually means you cloned without running setup.

**I didn't test with a real agent.**
PR descriptions must state which agent you used and what you tested. PRs without this will be returned for revision.

## Code of Conduct

We are committed to providing a safe and welcoming environment for all contributors. Please read and adhere to the [Contributor Covenant 2.1](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).