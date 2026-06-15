---
name: runtime-simulation-validation
description: "Validate runtime behavior in a simulated environment. Use when smoke-testing build output in a local or simulated deployment environment."
license: MIT
compatibility: Claude Code, GitHub Copilot, OpenCode, Cursor, Codex, Gemini CLI
metadata:
  author: paruff
  suite: uFawkesAI
---

# Skill: Runtime Simulation Validation

> **Load trigger:** `"load runtime-simulation-validation skill"` > **DORA:** Cap 5 (Small Batches / Shift Left on Quality)
> **Token cost:** Low

## Purpose

Validate runtime behavior in a simulated environment.

## Responsibilities

- Deploy build output to local/simulated environment
- Validate readiness and liveness probes
- Validate logs and metrics
- Detect runtime errors

## Inputs

- Build output (code, manifests)
- Simulation environment (kind, minikube, Docker Compose, local server)

## Outputs

- `runtime-simulation.json`
- `runtime-errors.txt`

## Validation Rules

### Startup

- [ ] Application starts without errors
- [ ] Startup completes within timeout
- [ ] Liveness probe responds
- [ ] Readiness probe responds

### Runtime

- [ ] No crash loops or restarts
- [ ] No OOM kills
- [ ] No unhandled exceptions in logs
- [ ] Graceful shutdown works

### Logs

- [ ] No ERROR or FATAL messages in logs
- [ ] No stack traces in logs
- [ ] No sensitive data in logs
- [ ] Logging format consistent

### Health Endpoints

- [ ] `/healthz` returns 200
- [ ] `/readyz` returns 200 (or 503 when not ready)
- [ ] `/metrics` returns valid Prometheus format (if applicable)

## Simulation Environments

| Environment | Tool | Use When |
|-------------|------|----------|
| Kubernetes (local) | kind / minikube | K8s manifests to validate |
| Docker | Docker Compose | Multi-container apps |
| Standalone | Direct execution | Simple services |
| Mock server | WireMock / MockServer | External dependency simulation |

## Tools

- `kubectl` for K8s simulation
- `docker-compose` for multi-container simulation
- `curl` / HTTP client for health check validation
- Log aggregator for log analysis

## Output Format

```json
{
  "skill": "runtime-simulation-validation",
  "status": "pass | fail",
  "startup": {
    "starts_successfully": true,
    "startup_time_ms": 1200,
    "liveness_probe": "healthy",
    "readiness_probe": "ready"
  },
  "runtime": {
    "crash_loops": 0,
    "oom_kills": 0,
    "unhandled_exceptions": 0
  },
  "logs": {
    "error_count": 0,
    "fatal_count": 0,
    "sensitive_data_found": false
  },
  "health_endpoints": {
    "/healthz": 200,
    "/readyz": 200
  },
  "errors": []
}
```

## Success Criteria

- Application starts without errors
- Health probes respond correctly
- No runtime errors detected
- Logs clean and consistent
