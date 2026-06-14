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
def docker_compose_file(project_root):
    """Return the docker-compose.yml file path."""
    return project_root / "docker-compose.yml"


@pytest.fixture
def docker_compose_config(docker_compose_file):
    """Load and return the docker-compose.yml configuration."""
    with open(docker_compose_file) as f:
        return yaml.safe_load(f)


@pytest.fixture
def jenkinsfile(project_root):
    """Return the Jenkinsfile path."""
    return project_root / "Jenkinsfile"


@pytest.fixture
def jenkinsfile_content(jenkinsfile):
    """Read and return the Jenkinsfile content."""
    with open(jenkinsfile) as f:
        return f.read()


@pytest.fixture
def jcasc_dir(project_root):
    """Return the JCasC configuration directory."""
    return project_root / "jenkins"


@pytest.fixture
def k8s_dir(project_root):
    """Return the Kubernetes manifests directory."""
    return project_root / "k8s"


@pytest.fixture
def github_dir(project_root):
    """Return the .github directory."""
    return project_root / ".github"


@pytest.fixture
def workflows_dir(github_dir):
    """Return the workflows directory."""
    return github_dir / "workflows"


@pytest.fixture
def workflow_files(workflows_dir):
    """Return all workflow files."""
    return list(workflows_dir.glob("*.yml")) + list(workflows_dir.glob("*.yaml"))
