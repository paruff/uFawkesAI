---
change: seam-superpowers-board-mirror
status: approved
author: ufawkes-bot@users.noreply.github.com
approved_by: phil.ruff@gmail.com
approved_at: 2026-11-23
approved_sha: b16800b
---
# Seam phase 4: Superpowers and the board mirror: plan

1. Parity check plus plugin pin (#357): RED by removing the pin, GREEN with it.
2. Agent files and `SETUP.md` (#357).
3. `scripts/test-board-mirror.sh` RED, then `scripts/board-mirror.sh` and the workflow (#358).
4. Wire the test into `ci-quality.yml`. #359 stays a separate human-run step.
