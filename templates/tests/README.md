# Test Suite Templates

This directory contains test suite templates for uFawkes repos. Copy these to your repo and customize as needed.

## Directory Structure

```
tests/
├── unit/
│   ├── conftest.py
│   └── test_<thing>_validation.py
├── integration/
│   └── test_<thing>_integration.py
├── smoke/
│   └── test_<thing>_health.py
└── acceptance/
    └── test_<thing>_acceptance.py
```

## Template Files

| Template | Purpose | When to Use |
|----------|---------|-------------|
| `unit/conftest.py` | Shared fixtures | All repos |
| `unit/test_workflow_validation.py` | GitHub Actions workflow validation | All repos |
| `unit/test_docker_compose_validation.py` | Docker Compose validation | Stack repos (Obs, Pipe, DevX) |
| `unit/test_jenkinsfile_validation.py` | Jenkinsfile validation | Pipe repo |
| `unit/test_k8s_validation.py` | Kubernetes manifest validation | Core repos (fawkes) |
| `integration/test_docker_compose_integration.py` | Docker Compose stack integration | Stack repos |
| `smoke/test_jenkins_health.py` | Jenkins health checks | Pipe repo |
| `acceptance/test_pipeline_acceptance.py` | Full pipeline acceptance | Stack repos |
| `Makefile` | Test commands | All repos |
| `.pipeline.yml.template` | Pipeline contract template | All repos |

## Usage

1. Copy the relevant templates to your repo
2. Customize the fixtures in `conftest.py` for your project structure
3. Update test assertions to match your specific requirements
4. Add the test commands to your `Makefile`
5. Configure the test tiers in `.pipeline.yml`

## Coverage Thresholds

| Tier | Total | Diff | Ratchet |
|------|-------|------|---------|
| Unit | 60% | 80% | Yes |
| Integration | 50% | 70% | Yes |
| Acceptance | 50% | 70% | Yes |
| Smoke | N/A | N/A | N/A |

## Running Tests

```bash
# Run all tests
make test

# Run specific tier
make test-unit
make test-integration
make test-smoke
make test-acceptance

# Run with coverage
make test-coverage
```

## Customization

### For Stack Repos (Obs, Pipe, DevX)
- Copy all template files
- Customize `conftest.py` fixtures for your Docker Compose services
- Update health check URLs and ports
- Add service-specific assertions

### For Core Repos (fawkes)
- Copy `unit/conftest.py` and `unit/test_k8s_validation.py`
- Customize K8s manifest validation
- Add resource-specific checks

### For Config Repos (DORA, Sec)
- Copy `unit/conftest.py` and `unit/test_workflow_validation.py`
- Customize workflow validation
- Add config-specific checks

### For Site Repos (uFawkes.dev)
- Copy `unit/conftest.py` and `unit/test_workflow_validation.py`
- Add Jekyll-specific validation
- Add build-specific checks
