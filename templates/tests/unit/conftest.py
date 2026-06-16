"""Shared test fixtures for uFawkes repos.

Customize this file for your project structure.
"""

import os
import pytest
import yaml
from pathlib import Path


@pytest.fixture
def project_root():
    """Return the project root directory."""
    return Path(__file__).parent.parent.parent


@pytest.fixture
def service_host():
    """Return the service host for integration/acceptance tests.

    Override via SERVICE_HOST environment variable or conftest.py override.
    """
    return os.environ.get("SERVICE_HOST", "localhost")


@pytest.fixture
def service_port():
    """Return the service port for integration/acceptance tests.

    Override via SERVICE_PORT environment variable or conftest.py override.
    """
    return int(os.environ.get("SERVICE_PORT", "8080"))


@pytest.fixture
def service_base_url(service_host, service_port):
    """Return the full base URL for the service."""
    return f"http://{service_host}:{service_port}"


@pytest.fixture
def docker_compose_file(project_root):
    """Return the docker-compose.yml file path."""
    return project_root / "docker-compose.yml"


@pytest.fixture
def docker_compose_config(docker_compose_file):
    """Load and return the docker-compose.yml configuration."""
    if not docker_compose_file.exists():
        pytest.skip("docker-compose.yml not found")
    with open(docker_compose_file) as f:
        return yaml.safe_load(f)


@pytest.fixture
def jenkinsfile(project_root):
    """Return the Jenkinsfile path."""
    return project_root / "Jenkinsfile"


@pytest.fixture
def jenkinsfile_content(jenkinsfile):
    """Read and return the Jenkinsfile content."""
    if not jenkinsfile.exists():
        pytest.skip("Jenkinsfile not found")
    with open(jenkinsfile) as f:
        return f.read()


@pytest.fixture
def jcasc_dir(project_root):
    """Return the JCasC configuration directory."""
    path = project_root / "jenkins"
    if not path.exists():
        pytest.skip("jenkins/ directory not found")
    return path


@pytest.fixture
def k8s_dir(project_root):
    """Return the Kubernetes manifests directory."""
    path = project_root / "k8s"
    if not path.exists():
        pytest.skip("k8s/ directory not found")
    return path


@pytest.fixture
def github_dir(project_root):
    """Return the .github directory."""
    path = project_root / ".github"
    if not path.exists():
        pytest.skip(".github/ directory not found")
    return path


@pytest.fixture
def workflows_dir(github_dir):
    """Return the workflows directory."""
    path = github_dir / "workflows"
    if not path.exists():
        pytest.skip(".github/workflows/ directory not found")
    return path


@pytest.fixture
def workflow_files(workflows_dir):
    """Return all workflow files."""
    files = list(workflows_dir.glob("*.yml")) + list(workflows_dir.glob("*.yaml"))
    if not files:
        pytest.skip("No workflow files found")
    return files
