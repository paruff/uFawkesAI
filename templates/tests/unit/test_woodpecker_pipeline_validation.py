"""Validation tests for Woodpecker CI pipelines.

Woodpecker CI uses .woodpecker.yml at the repository root.
See https://woodpecker-ci.org/docs/usage/pipeline-syntax
"""

import re

import pytest
import yaml


class TestWoodpeckerPipeline:
    """Tests for Woodpecker pipeline configuration."""

    def test_woodpecker_file_exists(self, woodpecker_file):
        """Woodpecker pipeline file should exist."""
        assert woodpecker_file.exists(), ".woodpecker.yml not found"

    def test_woodpecker_file_not_empty(self, woodpecker_pipeline):
        """Woodpecker pipeline should not be empty."""
        assert woodpecker_pipeline is not None, "Pipeline is empty"

    def test_has_version(self, woodpecker_pipeline):
        """Pipeline should declare version."""
        assert "version" in woodpecker_pipeline, "Missing 'version' key"

    def test_has_pipeline_definition(self, woodpecker_pipeline):
        """Pipeline should have at least one pipeline definition."""
        assert "pipelines" in woodpecker_pipeline or "steps" in woodpecker_pipeline, (
            "Missing 'pipelines' or 'steps' key"
        )

    def test_steps_have_names(self, woodpecker_pipeline):
        """All steps should have names."""
        steps = woodpecker_pipeline.get("steps", [])
        for i, step in enumerate(steps):
            assert "name" in step, f"Step {i} missing 'name'"

    def test_steps_have_images(self, woodpecker_pipeline):
        """All steps should specify an image."""
        steps = woodpecker_pipeline.get("steps", [])
        for step in steps:
            assert "image" in step, (
                f"Step '{step.get('name', 'unknown')}' missing 'image'"
            )

    def test_no_hardcoded_secrets(self, woodpecker_pipeline):
        """Steps should not contain hardcoded credentials."""
        secret_patterns = [
            r"password\s*[=:]\s*['\"][^'\"]+['\"]",
            r"token\s*[=:]\s*['\"][^'\"]+['\"]",
            r"secret\s*[=:]\s*['\"][^'\"]+['\"]",
            r"api[_-]?key\s*[=:]\s*['\"][^'\"]+['\"]",
        ]
        pipeline_str = yaml.dump(woodpecker_pipeline)
        for pattern in secret_patterns:
            matches = re.findall(pattern, pipeline_str, re.IGNORECASE)
            assert not matches, f"Potential hardcoded secret found: {matches}"

    def test_steps_have_commands(self, woodpecker_pipeline):
        """All steps should have commands."""
        steps = woodpecker_pipeline.get("steps", [])
        for step in steps:
            assert "commands" in step, (
                f"Step '{step.get('name', 'unknown')}' missing 'commands'"
            )

    def test_timeout_or_settings(self, woodpecker_pipeline):
        """Pipeline should have timeout or settings with timeout."""
        # Woodpecker supports timeout at pipeline level or in settings
        has_timeout = "timeout" in woodpecker_pipeline
        if not has_timeout:
            settings = woodpecker_pipeline.get("settings", {})
            has_timeout = "timeout" in settings
        # Not strictly required but recommended
        if not has_timeout:
            pytest.skip("No timeout configured (recommended but not required)")

    def test_uses_environment_variables(self, woodpecker_pipeline):
        """Sensitive values should use environment variables, not hardcoded."""
        pipeline_str = yaml.dump(woodpecker_pipeline)
        # Check for common patterns that should use env vars
        suspicious = re.findall(
            r'(password|token|secret|key)\s*:\s*["\'][^"\']{8,}["\']',
            pipeline_str,
            re.IGNORECASE,
        )
        for match in suspicious:
            # Allow if it looks like an env var reference
            if not re.search(r"\$\{?[A-Z_]+}?", match):
                pytest.fail(f"Potential hardcoded secret (use env vars): {match}")


class TestTektonPipelines:
    """Tests for Tekton pipeline configurations."""

    def test_tekton_dir_exists(self, tekton_dir):
        """Tekton directory should exist if using Tekton."""
        # This test will skip if tekton/ doesn't exist
        assert tekton_dir.exists(), "tekton/ directory not found"

    def test_tekton_files_exist(self, tekton_files):
        """Should have at least one Tekton pipeline file."""
        assert len(tekton_files) > 0, "No Tekton pipeline files found"

    def test_tekton_files_valid_yaml(self, tekton_files):
        """All Tekton files should be valid YAML."""
        for f in tekton_files:
            with open(f) as fh:
                content = yaml.safe_load(fh)
                assert content is not None, f"{f.name} is empty or invalid YAML"

    def test_tekton_has_pipeline_or_task(self, tekton_files):
        """Files should define Pipeline or Task resources."""
        for f in tekton_files:
            with open(f) as fh:
                docs = list(yaml.safe_load_all(fh))
                for doc in docs:
                    if doc and doc.get("kind") in (
                        "Pipeline",
                        "Task",
                        "PipelineRun",
                        "TaskRun",
                    ):
                        return
        pytest.fail("No Pipeline, Task, PipelineRun, or TaskRun found in Tekton files")

    def test_tekton_no_hardcoded_secrets(self, tekton_files):
        """Tekton files should not contain hardcoded secrets."""
        secret_patterns = [
            r"password\s*[=:]\s*['\"][^'\"]+['\"]",
            r"token\s*[=:]\s*['\"][^'\"]+['\"]",
        ]
        for f in tekton_files:
            with open(f) as fh:
                content = fh.read()
                for pattern in secret_patterns:
                    matches = re.findall(pattern, content, re.IGNORECASE)
                    assert not matches, (
                        f"{f.name}: potential hardcoded secret: {matches}"
                    )
