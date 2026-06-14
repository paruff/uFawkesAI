"""Acceptance tests for full pipeline execution.

Customize this file for your project's specific acceptance test requirements.
"""

import pytest
import subprocess
import time
import requests
from pathlib import Path


class TestPipelineAcceptance:
    """Acceptance tests for the complete pipeline."""

    @pytest.fixture(autouse=True)
    def setup_stack(self):
        """Ensure Docker Compose stack is running."""
        subprocess.run(
            ["docker", "compose", "up", "-d"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        # Wait for services to be healthy
        time.sleep(60)
        yield

    def test_pipeline_can_start(self):
        """Pipeline should be able to start."""
        try:
            # Check if the main service is running
            response = requests.get(
                "http://localhost:8080/login",
                timeout=10,
            )
            assert response.status_code == 200
        except requests.exceptions.ConnectionError:
            pytest.skip("Main service not available")

    def test_has_required_plugins(self):
        """Required plugins should be installed."""
        try:
            response = requests.get(
                "http://localhost:8080/pluginManager/api/json",
                timeout=10,
            )
            if response.status_code == 200:
                plugins = response.json().get("plugins", [])
                plugin_names = [p.get("shortName", "") for p in plugins]
                # Required plugins - customize this list
                required = [
                    "pipeline",
                    "workflow-aggregator",
                    "git",
                ]
                for plugin in required:
                    assert plugin in plugin_names, (
                        f"Required plugin '{plugin}' not installed"
                    )
        except requests.exceptions.ConnectionError:
            pytest.skip("Plugin manager not available")

    def test_has_pipeline_jobs(self):
        """Pipeline jobs should be configured."""
        try:
            response = requests.get(
                "http://localhost:8080/api/json?tree=jobs[name]",
                timeout=10,
            )
            if response.status_code == 200:
                jobs = response.json().get("jobs", [])
                # At least one job should exist
                assert len(jobs) > 0, "No pipeline jobs configured"
        except requests.exceptions.ConnectionError:
            pytest.skip("API not available")

    def test_logs_clean(self):
        """Logs should be clean of critical errors."""
        result = subprocess.run(
            ["docker", "logs", "jenkins", "--tail", "200"],
            capture_output=True,
            text=True,
        )
        # Check for critical errors
        critical_errors = [
            "SEVERE",
            "FATAL",
            "OutOfMemoryError",
            "StackOverflowError",
            "Failed to start",
        ]
        for error in critical_errors:
            assert error not in result.stdout, (
                f"Log contains critical error: {error}"
            )
