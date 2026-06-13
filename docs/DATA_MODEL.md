=== FILE: docs/DATA_MODEL.md ===
Why agents read this: This document defines the core data structures, ensuring agents generate consistent, schema-aligned code that adheres to the system's data contracts.

## Agent Instructions

**Match field names and types exactly. Do not add fields without updating this document first.**

### Core Entities

| Entity      | Key fields                                             | Relationships               | Notes                                         |
| :---------- | :----------------------------------------------------- | :-------------------------- | :-------------------------------------------- |
| **User**    | `id` (UUID), `email` (string), `createdAt` (Date)      | Has many `Posts` (1:N)      | `id` must always be a UUID format.            |
| **Post**    | `postId` (UUID), `authorId` (UUID), `content` (string) | Belongs to one `User` (N:1) | `content` should be sanitized before storage. |
| **Product** | `productId` (UUID), `name` (string), `price` (number)  | Has many `Reviews` (1:N)    | `price` must be stored in cents (integer).    |

## Schema Conventions

- **Naming:** Use `camelCase` for all field names (e.g., `createdAt`, `postId`).
- **Types:** Use standard TypeScript/Python types (string, number, boolean, Date).
- **Nullability:** Fields that can be null must be explicitly marked as `?` in the schema definition.
- **IDs:** All primary keys must be UUIDs, not sequential integers.

## How to Update This File

When a new entity or field is added, update the corresponding table row. If a relationship changes, update the `Relationships` column and add a note in the `Notes` column explaining the impact.
