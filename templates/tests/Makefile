.PHONY: help test test-unit test-integration test-smoke test-acceptance validate pre-commit-setup pre-commit-run clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# ============================================================================
# Test Commands
# ============================================================================

test: test-unit ## Run all tests
	@echo "All tests passed"

test-unit: ## Run unit tests
	pytest tests/unit/ -v --tb=short

test-integration: ## Run integration tests (requires Docker)
	pytest tests/integration/ -v --tb=short

test-smoke: ## Run smoke tests (requires running stack)
	pytest tests/smoke/ -v --tb=short

test-acceptance: ## Run acceptance tests (requires running stack)
	pytest tests/acceptance/ -v --tb=short

test-coverage: ## Run tests with coverage report
	pytest tests/unit/ -v --tb=short --cov=tests/unit --cov-report=term-missing

# ============================================================================
# Validation Commands
# ============================================================================

validate: ## Run all validations
	@echo "Running validations..."
	pre-commit run --all-files

# ============================================================================
# Pre-commit Commands
# ============================================================================

pre-commit-setup: ## Install pre-commit hooks
	pip install pre-commit
	pre-commit install

pre-commit-run: ## Run pre-commit hooks on all files
	pre-commit run --all-files

# ============================================================================
# Docker Commands
# ============================================================================

up: ## Start Docker Compose stack
	docker compose up -d

down: ## Stop Docker Compose stack
	docker compose down -v

logs: ## View Docker Compose logs
	docker compose logs -f

ps: ## List running containers
	docker compose ps

# ============================================================================
# Cleanup
# ============================================================================

clean: ## Clean up test artifacts
	rm -rf .pytest_cache __pycache__ tests/__pycache__ tests/unit/__pycache__ tests/integration/__pycache__ tests/smoke/__pycache__ tests/acceptance/__pycache__
	rm -rf htmlcov .coverage coverage.xml
	docker compose down -v --remove-orphans 2>/dev/null || true
