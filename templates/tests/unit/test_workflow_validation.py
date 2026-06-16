"""Unit tests for GitHub Actions workflow validation.

Customize this file for your project's specific workflow requirements.
"""

import pytest
import yaml
from pathlib import Path


class TestWorkflowValidation:
    """Validate GitHub Actions workflow structure and best practices."""

    def test_workflow_files_exist(self, workflow_files):
        """At least one workflow file must exist."""
        assert len(workflow_files) > 0, "No workflow files found in .github/workflows/"

    def test_all_valid_yaml(self, workflow_files):
        """All workflow files must be valid YAML."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                assert config is not None, f"{f.name} is empty"

    def test_all_have_name(self, workflow_files):
        """All workflows must have a name."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                assert "name" in config, f"{f.name} missing 'name'"

    def test_all_have_on_trigger(self, workflow_files):
        """All workflows must have an 'on' trigger."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                assert "on" in config or True in config, f"{f.name} missing 'on' trigger"

    def test_all_have_jobs(self, workflow_files):
        """All workflows must have a 'jobs' section."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                assert "jobs" in config, f"{f.name} missing 'jobs'"

    def test_all_jobs_have_runs_on(self, workflow_files):
        """All jobs must have 'runs-on'."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                jobs = config.get("jobs", {})
                for job_name, job_config in jobs.items():
                    if isinstance(job_config, dict):
                        assert "runs-on" in job_config or "uses" in job_config, (
                            f"{f.name} job '{job_name}' missing 'runs-on' or 'uses'"
                        )

    def test_no_hardcoded_secrets(self, workflow_files):
        """Workflows must not contain hardcoded secrets."""
        sensitive_patterns = [
            "password: admin",
            "password: password",
            "password: root",
            "secret: secret",
            "token: token",
            "api_key: key",
            "PRIVATE_KEY: -----BEGIN",
        ]
        for f in workflow_files:
            with open(f) as fh:
                content = fh.read()
                for pattern in sensitive_patterns:
                    assert pattern.lower() not in content.lower(), (
                        f"{f.name} contains hardcoded secret: {pattern}"
                    )

    def test_use_official_actions(self, workflow_files):
        """Workflows should use official GitHub actions or well-known third-party actions.

        NOTE: This allowlist is a starting point. Customize it for your project's
        specific action dependencies. Add new prefixes as needed.
        """
        allowed_actions = [
            "actions/",
            "./",
            "github/",
            "gitleaks/",
            "trivy/",
            "codecov/",
            "coveralls/",
            "snyk/",
            "aquasecurity/",
            "ludeeus/",
            "golangci/",
            "aws-actions/",
            "azure/",
            "hashicorp/",
            "google-github-actions/",
        ]
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                jobs = config.get("jobs", {})
                for job_name, job_config in jobs.items():
                    if isinstance(job_config, dict):
                        steps = job_config.get("steps", [])
                        for step in steps:
                            if "uses" in step:
                                action = step["uses"]
                                # Allow official actions and well-known third-party actions
                                assert any(action.startswith(prefix) for prefix in allowed_actions), (
                                    f"{f.name} job '{job_name}' uses non-standard action: {action}"
                                )

    def test_timeout_minutes_set(self, workflow_files):
        """Jobs should have timeout-minutes set."""
        for f in workflow_files:
            with open(f) as fh:
                config = yaml.safe_load(fh)
                jobs = config.get("jobs", {})
                for job_name, job_config in jobs.items():
                    if isinstance(job_config, dict) and "uses" not in job_config:
                        # Only check direct jobs, not reusable workflow calls
                        if "timeout-minutes" not in job_config:
                            import warnings
                            warnings.warn(
                                f"{f.name} job '{job_name}' has no timeout-minutes",
                                UserWarning,
                            )
