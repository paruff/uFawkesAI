# Agent Telemetry

> Spec for OTEL spans emitted by agents. Covers invocation tracking, skill loading, finding quality, and decision logging.
> Phase 1 of the agent system improvement plan. Depends on Phase 0 logging infrastructure.

---

## Span Types

### `agent.invocation.started`

Emitted when an agent begins processing. Source: Phase 0 log entry creation.

| Attribute     | Type     | Required | Description                                        |
| ------------- | -------- | -------- | -------------------------------------------------- |
| `agent.name`  | string   | yes      | Agent identifier (matches filename without .md)    |
| `session_id`  | string   | yes      | Unique invocation identifier                       |
| `mode`        | string   | no       | Operational mode (e.g. "pr-audit", "deep-review")  |
| `trigger`     | string   | no       | What triggered this (human, CI, direct invocation) |
| `input_files` | string[] | no       | Context files read before starting                 |

### `agent.skill.loaded`

Emitted each time a skill is loaded. Source: `skills_loaded[]` in log entry.

| Attribute      | Type   | Required | Description                                       |
| -------------- | ------ | -------- | ------------------------------------------------- |
| `skill.name`   | string | yes      | Full skill path (e.g. `security/rbac-validation`) |
| `skill.domain` | string | yes      | Domain (e.g. `security`)                          |
| `agent.name`   | string | yes      | Agent that loaded this skill                      |
| `session_id`   | string | yes      | Links to parent invocation                        |

### `agent.finding.produced`

Emitted for each finding. Source: each item in `findings[]` in log entry.

| Attribute              | Type    | Required | Description                             |
| ---------------------- | ------- | -------- | --------------------------------------- |
| `severity`             | string  | yes      | CRITICAL, HIGH, MEDIUM, LOW, INFO       |
| `category`             | string  | yes      | Check category (e.g. "secrets", "rbac") |
| `actionable`           | boolean | yes      | Whether a specific action is required   |
| `manual_review_needed` | boolean | yes      | Whether human judgment is required      |
| `agent.name`           | string  | yes      | Agent that produced this finding        |
| `session_id`           | string  | yes      | Links to parent invocation              |

### `agent.decision.made`

Emitted for the final decision. Source: `decision` and `blockers` in log entry.

| Attribute       | Type    | Required | Description                                             |
| --------------- | ------- | -------- | ------------------------------------------------------- |
| `decision`      | string  | yes      | PASS, FAIL, BLOCKED, APPROVE, REQUEST_CHANGES, ESCALATE |
| `blocker_count` | integer | yes      | Number of CRITICAL/HIGH findings                        |
| `finding_count` | integer | yes      | Total findings                                          |
| `agent.name`    | string  | yes      | Agent that made this decision                           |
| `session_id`    | string  | yes      | Links to parent invocation                              |

### `agent.invocation.completed`

Emitted when agent finishes successfully. Same span context as `agent.invocation.started`.

| Attribute             | Type    | Required | Description                |
| --------------------- | ------- | -------- | -------------------------- |
| `duration_ms`         | integer | yes      | Wall-clock duration        |
| `total_skills_loaded` | integer | yes      | Count of skills loaded     |
| `total_findings`      | integer | yes      | Count of findings produced |
| `decision`            | string  | yes      | Final decision             |

### `agent.invocation.failed`

Emitted when agent encounters an unrecoverable error.

| Attribute    | Type   | Required | Description                                        |
| ------------ | ------ | -------- | -------------------------------------------------- |
| `error`      | string | yes      | Error summary                                      |
| `stage`      | string | yes      | Where failure occurred (validate, execute, report) |
| `agent.name` | string | yes      | Agent that failed                                  |
| `session_id` | string | yes      | Links to parent invocation                         |

---

## Data Flow

```
Agent completes task
  → writes JSON log entry to .agents/logs/YYYY-MM-DD.jsonl  (Phase 0)
  → agent-metrics.sh reads logs, produces markdown report    (Phase 0)
  → OTEL exporter reads logs, emits spans                   (Phase 1)
  → Grafana dashboards display agent telemetry              (Phase 1)
```

---

## Span Naming Convention

`agent.[action].[detail]`

- `agent.invocation.started` — agent begins
- `agent.skill.loaded` — skill loaded
- `agent.finding.produced` — finding identified
- `agent.decision.made` — decision reached
- `agent.invocation.completed` — agent finishes
- `agent.invocation.failed` — agent errors

---

## Integration Points

| Component                   | Integration                                |
| --------------------------- | ------------------------------------------ |
| Phase 0 logs                | Source data for all spans                  |
| `agent-metrics.sh`          | Reads logs, can be extended to export OTEL |
| `agent-observability` skill | Full implementation patterns               |
| `.agents/logs/`             | Log storage directory                      |

---

## Quality Gates

Spans must satisfy:

- No PII in any span attribute
- `session_id` must link parent and child spans
- `agent.name` must match an agent filename in `.agents/agents/`
- `decision` must be one of the valid enum values
- `severity` must be one of CRITICAL, HIGH, MEDIUM, LOW, INFO
