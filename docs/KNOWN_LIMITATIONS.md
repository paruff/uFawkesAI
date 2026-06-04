=== FILE: docs/KNOWN_LIMITATIONS.md ===
Why agents read this: This document prevents agents from wasting cycles on known technical debt, deferred decisions, or architectural constraints.

## Agent Instructions

**Before implementing, check if your proposed solution conflicts with any known limitations listed below.**

### Active Limitations
| ID | Area | Limitation | Workaround | Linked issue |
| :--- | :--- | :--- | :--- | :--- |
| L-001 | Rate Limiting | External API calls are subject to rate limiting (100 requests/minute). | Implement exponential backoff with a minimum 5-second delay. | [JIRA-123] |
| L-002 | Billing System | Cannot process transactions older than 6 months. | Use the manual reconciliation dashboard for historical data. | [JIRA-456] |
| L-003 | Data Volume | Cannot process datasets exceeding 1TB. | Implement chunking and process data in batches of 500GB. | [JIRA-789] |

## Deferred Decisions

*   **Search Indexing:** We have not yet decided on the primary search engine (Elasticsearch vs Algolia). Use a generic search wrapper for now.
*   **Real-time Chat:** The chat feature will initially use polling (every 15s) until WebSockets are implemented.
*   **User Avatar:** Avatars will default to a generic placeholder image until the dedicated asset pipeline is ready.

## How to Add a Limitation

1.  Identify the constraint and its impact.
2.  Add a new row to the Active Limitations table, including a unique ID and a linked issue.
3.  Update the Workaround section with actionable steps.
