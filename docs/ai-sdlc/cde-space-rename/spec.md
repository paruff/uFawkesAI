# Spec — CDE Space image workflow names

**Traces to:** [`intent.md`](intent.md)

- **REQ-001** `build-devsecops-images.yml` is `build-cde-space-image.yml`, named "CDE Space image — Build, Verify & Publish".
- **REQ-002** `image-lock-bump.yml` is named "CDE Space image — Lock Bump" and dispatches the renamed workflow.
- **REQ-003** No current (non-history) file refers to `build-devsecops-images.yml`.
- **REQ-004** Behaviour is unchanged: triggers, jobs, permissions and the publish gate are identical apart from the file name and the concurrency group name.
