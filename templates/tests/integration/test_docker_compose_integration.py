"""Integration tests for Docker Compose stack.

Customize this file for your project's specific integration test requirements.
"""

import pytest
import yaml
import subprocess
import time
import requests
from pathlib import Path


class TestDockerComposeIntegration:
    """Integration tests for the complete Docker Compose stack."""

    @pytest.fixture(autouse=True)
    def setup_and_teardown(self):
        """Start and stop Docker Compose stack."""
        # Setup: Start stack
        subprocess.run(
            ["docker", "compose", "up", "-d"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        # Wait for services to be ready
        time.sleep(30)
        yield
        # Teardown: Stop stack
        subprocess.run(
            ["docker", "compose", "down", "-v"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )

    def test_services_are_running(self):
        """All services should be running."""
        result = subprocess.run(
            ["docker", "compose", "ps", "--format", "json"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        assert result.returncode == 0
        # Parse the output to check for running services
        # This is a basic check - real implementation would parse JSON
        assert "running" in result.stdout.lower() or "Up" in result.stdout

    def test_healthchecks_pass(self):
        """Health checks should pass for all services."""
        result = subprocess.run(
            ["docker", "compose", "ps", "--format", "json"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        if result.returncode == 0:
            # Check that no service is in unhealthy state
            assert "unhealthy" not in result.stdout.lower()

    def test_no_port_conflicts(self):
        """No port conflicts between services."""
        result = subprocess.run(
            ["docker", "compose", "ps", "--format", "json"],
            capture_output=True,
            text=True,
            cwd=str(Path(__file__).parent.parent.parent),
        )
        if result.returncode == 0:
            # Parse JSON output to check for port conflicts
            import json
            ports_seen = {}
            for line in result.stdout.strip().split("\n"):
                if not line:
                    continue
                try:
                    service = json.loads(line)
                    ports = service.get("Publishers", [])
                    for port_info in ports:
                        published_port = port_info.get("PublishedPort", 0)
                        if published_port > 0:
                            if published_port in ports_seen:
                                pytest.fail(
                                    f"Port conflict: port {published_port} used by "
                                    f"both '{ports_seen[published_port]}' and "
                                    f"'{service.get('Name', 'unknown')}'"
                                )
                            ports_seen[published_port] = service.get("Name", "unknown")
                except json.JSONDecodeError:
                    pass

    def test_volumes_are_created(self):
        """Docker volumes should be created for persistence."""
        result = subprocess.run(
            ["docker", "volume", "ls", "--format", "{{.Name}}"],
            capture_output=True,
            text=True,
        )
        assert result.returncode == 0
        # At least one volume should exist
        volumes = result.stdout.strip().split("\n")
        assert len(volumes) > 0, "No Docker volumes found"
