"""Unit tests for Kubernetes manifests validation.

Customize this file for your project's specific K8s requirements.
"""

import pytest
import yaml


class TestK8sManifestsValidation:
    """Validate Kubernetes manifests structure and best practices."""

    @pytest.fixture
    def k8s_files(self, k8s_dir):
        """Return all YAML files in k8s directory."""
        return list(k8s_dir.glob("*.yaml")) + list(k8s_dir.glob("*.yml"))

    @pytest.fixture
    def k8s_configs(self, k8s_files):
        """Load all K8s YAML files."""
        configs = []
        for f in k8s_files:
            with open(f) as fh:
                for doc in yaml.safe_load_all(fh):
                    if doc:
                        configs.append((f.name, doc))
        return configs

    def test_k8s_files_exist(self, k8s_files):
        """At least one K8s manifest must exist."""
        assert len(k8s_files) > 0, "No K8s manifests found in k8s/"

    def test_all_valid_yaml(self, k8s_files):
        """All K8s files must be valid YAML."""
        for f in k8s_files:
            with open(f) as fh:
                docs = list(yaml.safe_load_all(fh))
                assert docs is not None, f"{f.name} is empty"

    def test_all_have_api_version(self, k8s_configs):
        """All K8s resources must have apiVersion."""
        for filename, config in k8s_configs:
            assert "apiVersion" in config, f"{filename} missing 'apiVersion'"

    def test_all_have_kind(self, k8s_configs):
        """All K8s resources must have kind."""
        for filename, config in k8s_configs:
            assert "kind" in config, f"{filename} missing 'kind'"

    def test_all_have_metadata(self, k8s_configs):
        """All K8s resources must have metadata."""
        for filename, config in k8s_configs:
            assert "metadata" in config, f"{filename} missing 'metadata'"

    def test_metadata_has_name(self, k8s_configs):
        """All K8s resources must have metadata.name."""
        for filename, config in k8s_configs:
            assert "name" in config.get("metadata", {}), (
                f"{filename} missing 'metadata.name'"
            )

    def test_no_host_network(self, k8s_configs):
        """No pod should use hostNetwork (security risk)."""
        for filename, config in k8s_configs:
            if config.get("kind") in ["Deployment", "StatefulSet", "DaemonSet"]:
                spec = config.get("spec", {})
                template = spec.get("template", {}).get("spec", {})
                assert not template.get("hostNetwork", False), (
                    f"{filename} uses hostNetwork (security risk)"
                )

    def test_no_privileged_containers(self, k8s_configs):
        """No container should run in privileged mode."""
        for filename, config in k8s_configs:
            if config.get("kind") in ["Deployment", "StatefulSet", "DaemonSet"]:
                containers = (
                    config.get("spec", {})
                    .get("template", {})
                    .get("spec", {})
                    .get("containers", [])
                )
                for container in containers:
                    security = container.get("securityContext", {})
                    assert not security.get("privileged", False), (
                        f"{filename} container '{container.get('name')}' runs privileged"
                    )

    def test_has_labels(self, k8s_configs):
        """K8s resources should have labels (soft check)."""
        resources_without_labels = []
        for filename, config in k8s_configs:
            labels = config.get("metadata", {}).get("labels", {})
            if len(labels) == 0:
                resources_without_labels.append(filename)

        # Warn but don't fail - some resources may not need labels
        if resources_without_labels:
            import warnings

            warnings.warn(
                f"Resources without labels: {', '.join(resources_without_labels)}",
                UserWarning,
            )
