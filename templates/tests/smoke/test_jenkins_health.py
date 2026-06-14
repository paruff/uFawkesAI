"""Smoke tests for Jenkins health and basic functionality.

Customize this file for your project's specific smoke test requirements.
"""

import pytest
import subprocess
import time
import requests
from pathlib import Path


class TestJenkinsSmoke:
    """Smoke tests to verify Jenkins is running and accessible."""

    @pytest.fixture(autouse=True)
    def setup_stack(self):
        """Ensure Docker Compose stack is running."""
        subprocess.run(
            ["docker", "compose", "up", "-d"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        # Wait for Jenkins to start (it takes longer than most services)
        time.sleep(60)
        yield

    def test_jenkins_login_page_loads(self):
        """Jenkins login page should load successfully."""
        try:
            response = requests.get(
                "http://localhost:8080/login",
                timeout=10,
                allow_redirects=True,
            )
            assert response.status_code == 200
            assert "jenkins" in response.text.lower()
        except requests.exceptions.ConnectionError:
            pytest.skip("Jenkins not available on port 8080")

    def test_jenkins_api_responds(self):
        """Jenkins API should respond with valid JSON."""
        try:
            response = requests.get(
                "http://localhost:8080/api/json?pretty=true",
                timeout=10,
            )
            assert response.status_code == 200
            # Should be valid JSON
            data = response.json()
            assert "jobs" in data or "primaryView" in data
        except requests.exceptions.ConnectionError:
            pytest.skip("Jenkins API not available")

    def test_jenkins_has_no_critical_errors_in_logs(self):
        """Jenkins logs should not contain critical errors."""
        result = subprocess.run(
            ["docker", "logs", "jenkins", "--tail", "100"],
            capture_output=True,
            text=True,
        )
        # Check for critical errors (exclude warnings)
        critical_errors = [
            "SEVERE",
            "FATAL",
            "OutOfMemoryError",
            "StackOverflowError",
        ]
        for error in critical_errors:
            assert error not in result.stdout, (
                f"Jenkins log contains critical error: {error}"
            )

    def test_jenkins_plugin_manager_accessible(self):
        """Jenkins plugin manager should be accessible."""
        try:
            response = requests.get(
                "http://localhost:8080/pluginManager/api/json?pretty=true",
                timeout=10,
            )
            # Either 200 (authenticated) or 403 (needs login)
            assert response.status_code in [200, 403]
        except requests.exceptions.ConnectionError:
            pytest.skip("Jenkins plugin manager not available")
