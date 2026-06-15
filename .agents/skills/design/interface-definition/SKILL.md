---
name: interface-definition
description: "Define interfaces between components. Use when specifying API endpoints, data models, event schemas, and integration contracts."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Interface Definition

> **Load trigger:** `"load interface-definition skill"` > **DORA:** Cap 3 (AI-Accessible Internal Data)
> **Token cost:** Low

## Purpose

Define interfaces between components.

## Responsibilities

- Define API endpoints
- Define data models
- Define event schemas
- Define integration points

## Inputs

- `component-map.json` (from component-identification skill)
- `specification.md`

## Outputs

- `interfaces.json`

## Definition Rules

### API Endpoints

- [ ] HTTP method defined (GET, POST, PUT, DELETE, PATCH)
- [ ] Path defined with versioning (e.g., `/api/v1/resource`)
- [ ] Request body schema defined
- [ ] Response body schema defined
- [ ] Error responses defined (4xx, 5xx)
- [ ] Authentication requirements specified

### Data Models

- [ ] All fields defined with types
- [ ] Required vs optional fields marked
- [ ] Default values specified
- [ ] Validation rules specified
- [ ] Relationships defined (has-many, belongs-to)

### Event Schemas

- [ ] Event type/name defined
- [ ] Event payload defined
- [ ] Producer identified
- [ ] Consumer(s) identified
- [ ] Delivery guarantees specified

### Integration Points

- [ ] External API contracts defined
- [ ] Webhook formats defined
- [ ] Message queue formats defined
- [ ] File format contracts defined

## API Design Standards

| Standard | Convention |
|----------|------------|
| Versioning | URL path (`/api/v1/`) |
| Naming | kebab-case for paths, camelCase for JSON |
| Pagination | `?page=1&limit=20` or cursor-based |
| Errors | `{ "error": { "code": "string", "message": "string" } }` |
| Timestamps | ISO 8601 format |

## Output Format

```json
{
  "apis": [
    {
      "name": "User API",
      "base_url": "/api/v1/users",
      "endpoints": [
        {
          "method": "POST",
          "path": "/",
          "request": {
            "email": "string",
            "password": "string"
          },
          "response": {
            "id": "string",
            "email": "string",
            "created_at": "string"
          },
          "errors": [400, 409, 500],
          "auth": "none"
        }
      ]
    }
  ],
  "models": [
    {
      "name": "User",
      "fields": {
        "id": "string (uuid)",
        "email": "string (email)",
        "created_at": "string (iso8601)"
      }
    }
  ],
  "events": [
    {
      "type": "user.created",
      "producer": "User API",
      "consumers": ["Email Worker"],
      "payload": {
        "user_id": "string",
        "email": "string"
      }
    }
  ]
}
```

## Success Criteria

- Interfaces are clear and unambiguous
- All contracts are machine-readable
- Error cases defined
