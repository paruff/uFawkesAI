=== FILE: docs/KNOWN_LIMITATIONS.md ===
Why agents read this: This document prevents agents from wasting cycles on known technical debt, deferred decisions, or architectural constraints.

## Agent Instructions

**Before implementing, check if your proposed solution conflicts with any known limitations listed below.**

### Active Limitations

| ID    | Area           | Limitation                                                             | Workaround                                                   | Linked issue |
| :---- | :------------- | :--------------------------------------------------------------------- | :----------------------------------------------------------- | :----------- |
| L-001 | Rate Limiting  | External API calls are subject to rate limiting (100 requests/minute). | Implement exponential backoff with a minimum 5-second delay. | [JIRA-123]   |
| L-002 | Billing System | Cannot process transactions older than 6 months.                       | Use the manual reconciliation dashboard for historical data. | [JIRA-456]   |
| L-003 | Data Volume    | Cannot process datasets exceeding 1TB.                                 | Implement chunking and process data in batches of 500GB.     | [JIRA-789]   |
| L-004 | Dual-Harness Hooks | Claude Code hooks (declarative JSON in `.claude/settings.json`) and OpenCode hooks (imperative TypeScript in `.opencode/plugins/ai-sdlc-hooks.ts`) cannot be generated from one source — the two hook APIs are structurally different. Only the protected-path block-list is shared (`scripts/hooks/protected-paths.json`); the formatter dispatch table and the `SessionStart` reminder message remain separately hand-written per harness and can drift. | When changing hook *logic* (not the protected-path list), update both `.claude/settings.json` and `.opencode/plugins/ai-sdlc-hooks.ts` in the same commit. | — |
| L-005 | No measured test coverage | The repo's tests are bash suites (`scripts/test-*.sh`, run by `scripts/run-unit-tests.sh` in CI via `npm test`). No coverage tool measures them, so the 80% target in the global testing rules is not enforced; CI enforces that every suite passes, not a percentage. | Add a test for every behavioural change. Adopting `kcov` for the bash suites would make coverage measurable. | — |

## Deferred Decisions

- **Search Indexing:** We have not yet decided on the primary search engine (Elasticsearch vs Algolia). Use a generic search wrapper for now.
- **Real-time Chat:** The chat feature will initially use polling (every 15s) until WebSockets are implemented.
- **User Avatar:** Avatars will default to a generic placeholder image until the dedicated asset pipeline is ready.

## How to Add a Limitation

1.  Identify the constraint and its impact.
2.  Add a new row to the Active Limitations table, including a unique ID and a linked issue.
3.  Update the Workaround section with actionable steps.
