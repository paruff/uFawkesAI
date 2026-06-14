# Architecture Skill

> **Load this skill when:** implementing any feature, before writing any code.
> **Prompt example:** `"Use the architecture skill to implement this feature."`

---

## Layer Structure

[PLACEHOLDER — replace with your actual layer structure]

```
screens/     → UI composition only. No DB calls. No business logic.
components/  → Reusable UI primitives. No navigation. No services.
hooks/       → React state. Calls services. Never calls DB directly.
services/    → All DB reads/writes. All Auth calls.
utils/       → Pure functions. Stateless. No imports from other layers.
types/       → Shared TypeScript types only. No imports.
config/      → Environment vars, feature flags. No business logic.
```

**Dependency direction:** `screens → hooks → services → (SDK)`

## Hard Rules

1. No Firebase/DB SDK calls in `screens/` or `components/` — ever.
2. No business logic in screens — belongs in `utils/`.
3. No type definitions inline — all types in `src/types/index.ts`.
4. No `any` in catch blocks — use typed error pattern from `src/utils/errors.ts`.
5. `utils/` is stateless — no React hooks, no imports from `services/`.

## Before Writing Code

Read these in order:

1. `src/types/index.ts` — all data shapes
2. `docs/ARCHITECTURE.md` — full layer doc
3. `docs/API_SURFACE.md` — public service functions
4. `docs/KNOWN_LIMITATIONS.md` — do not make these worse

## PR Architecture Check (Required)

In every PR description, confirm:

- [ ] No layer boundary violations
- [ ] Types added to `src/types/index.ts`
- [ ] No new dependencies without PM sign-off
- [ ] No `any` added

## DORA Basis

DORA 2025: "Teams working in loosely coupled architectures see AI gains.
Those in tightly coupled systems see little or no benefit."
