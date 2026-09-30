"""Unit tests for Jenkinsfile validation.

Customize this file for your project's specific Jenkinsfile requirements.
"""

import re
import warnings


class TestJenkinsfileValidation:
    """Validate Jenkinsfile structure and best practices."""

    def test_jenkinsfile_exists(self, jenkinsfile):
        """Jenkinsfile must exist in project root."""
        assert jenkinsfile.exists(), "Jenkinsfile not found"

    def test_jenkinsfile_not_empty(self, jenkinsfile_content):
        """Jenkinsfile must not be empty."""
        assert len(jenkinsfile_content.strip()) > 0, "Jenkinsfile is empty"

    def test_has_pipeline_block(self, jenkinsfile_content):
        """Jenkinsfile must have a pipeline block."""
        assert re.search(r"pipeline\s*\{", jenkinsfile_content), (
            "Jenkinsfile missing 'pipeline {' block"
        )

    def test_has_agent(self, jenkinsfile_content):
        """Jenkinsfile must specify an agent."""
        assert re.search(r"agent\s+(any|none|\{)", jenkinsfile_content), (
            "Jenkinsfile missing 'agent' declaration"
        )

    def test_has_stages(self, jenkinsfile_content):
        """Jenkinsfile must have at least one stage."""
        stages = re.findall(r"stage\s*\(\s*['\"](.+?)['\"]", jenkinsfile_content)
        assert len(stages) > 0, "Jenkinsfile has no stages"

    def test_has_post_block(self, jenkinsfile_content):
        """Jenkinsfile should have a post block for cleanup."""
        assert re.search(r"post\s*\{", jenkinsfile_content), (
            "Jenkinsfile missing 'post {' block"
        )

    def test_no_hardcoded_credentials(self, jenkinsfile_content):
        """Jenkinsfile must not contain hardcoded credentials."""
        sensitive_patterns = [
            r"password\s*[:=]\s*['\"][^'\"]+['\"]",
            r"secret\s*[:=]\s*['\"][^'\"]+['\"]",
            r"token\s*[:=]\s*['\"][^'\"]+['\"]",
            r"api_key\s*[:=]\s*['\"][^'\"]+['\"]",
        ]
        for pattern in sensitive_patterns:
            matches = re.findall(pattern, jenkinsfile_content, re.IGNORECASE)
            assert len(matches) == 0, (
                f"Jenkinsfile contains hardcoded credential: {pattern}"
            )

    def test_has_timeout(self, jenkinsfile_content):
        """Jenkinsfile should have a timeout to prevent hung builds."""
        has_timeout = (
            re.search(r"timeout\s*\(", jenkinsfile_content) is not None
            or re.search(r"buildDiscarder", jenkinsfile_content) is not None
        )
        # Soft assertion - warn but don't fail
        if not has_timeout:
            warnings.warn(
                "Jenkinsfile has no timeout configured",
                UserWarning,
            )

    def test_stages_are_named(self, jenkinsfile_content):
        """All stages should have descriptive names."""
        stages = re.findall(r"stage\s*\(\s*['\"](.+?)['\"]", jenkinsfile_content)
        for stage_name in stages:
            assert len(stage_name) > 0, "Stage has empty name"
            assert not stage_name.startswith("Stage"), (
                f"Stage name '{stage_name}' is generic"
            )
