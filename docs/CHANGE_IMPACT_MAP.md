=== FILE: docs/CHANGE_IMPACT_MAP.md ===
Why agents read this: This map guides agents by detailing which code changes affect which other parts of the system, preventing accidental breakage.

## High-Impact Zones

| Zone                 | Files/Paths                               | Why it matters                                                                                     | Agent rule                                                                         |
| :------------------- | :---------------------------------------- | :------------------------------------------------------------------------------------------------- | :--------------------------------------------------------------------------------- |
| **Authentication**   | `src/auth/`, `src/utils/user.ts`          | Changes here affect session management, token validation, and user identity across the entire app. | Always test against existing login/logout flows.                                   |
| **State Management** | `src/store/`, `src/hooks/useStore.ts`     | Modifying state structure or update logic can cause silent data corruption in multiple components. | Use the provided state update functions only; never mutate state directly.         |
| **Networking/API**   | `src/services/api.ts`, `src/types/api.ts` | Changes to API endpoints or data shapes will break client-server contracts.                        | Always update the corresponding type definition file alongside the service change. |

## Change Propagation Rules

- **Rule 1: Dependency First:** If you change a core data structure (e.g., in `src/types/index.ts`), you must update all consuming services and components before merging.
- **Rule 2: Backward Compatibility:** Never remove a public function or field without first implementing a deprecation warning and providing a migration path.
- **Rule 3: Test Coverage:** Any change in a high-impact zone requires adding at least one new unit test that specifically covers the modified logic.

## Review Requirements by Impact Level

- **Low Impact:** Changes confined to a single component's internal logic (e.g., UI styling, local utility function). Requires a standard review.
- **Medium Impact:** Changes affecting a single service or module boundary (e.g., adding a new API endpoint). Requires a review and a check against `docs/API_SURFACE.md`.
- **High Impact:** Changes affecting core data models, authentication, or state management. Requires a full review, a mandatory check against `docs/CHANGE_IMPACT_MAP.md`, and sign-off from a senior engineer.

## How to Update This File

When a new high-impact area is introduced, add a new row to the High-Impact Zones table. If a rule changes, update the relevant section and notify the team in the PR description.
