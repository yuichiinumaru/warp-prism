---
date: 20260709-061941
timestamp: 20260709-061941
agent: builders
task: "0015"
description: "2026-07-09 — Task 0015 atoms/molecules a11y + format remediation"
is_rebuild_safe: true
---

# 2026-07-09 — Task 0015 atoms/molecules a11y + format remediation

### Fixed
- Cleared dart format drift on molecule sources/tests (`ds_drop_target`, `ds_evidence_row`, `ds_timeline_marker`, `ds_drag_drop_test`).
- Added shared `DSInteractiveSurface` molecule helper with keyboard focus, Enter/Space activation, 48×48 min target, and accurate `button`/`enabled` semantics.
- Wired interactive contract into `DSAssetCard`, `DSMetricTile`, `DSMetricTileCompact`, `DSEvidenceRow`, `DSTimelineMarker`, and `DSTaskCard`.
- Extended `molecules_contract_test.dart` with interactive accessibility contract coverage (keyboard, min-target, enabled/passive).

### Verification
- `dart format --output=none --set-exit-if-changed lib/src/atoms lib/src/molecules test/atoms test/molecules` → exit 0
- `dart analyze --format=machine lib/src/atoms lib/src/molecules test/atoms test/molecules` → exit 0
- `flutter test --concurrency=1 --no-pub test/atoms/ test/molecules/molecules_contract_test.dart` → 108/108 pass
- `flutter test --concurrency=1 --no-pub test/molecules/` → 215/215 pass

**Author**: omniroute/builder (builders)
