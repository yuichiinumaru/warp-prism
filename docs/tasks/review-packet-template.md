# Review Packet Template

> **Purpose**: Standardized format for summarizing task completion evidence for reviewers.
> **Origin**: Task 1207 (Review Packet Generator)
> **Dependency**: `docs/governance/promotion-state-model.md` (Task 1202)

This template defines the structure of a Review Packet. A review packet is a
derived summary of a task's Completion Evidence, optimized for reviewer
consumption. It allows reviewers to make a 2-minute decision without re-reading
entire task files or re-running commands.

---

## 1. Review Packet Format

Copy the following template and fill in the details for your task.

```markdown
# Review Packet: Task {ID} — {Title}

> **Date**: YYYY-MM-DD
> **Executor**: {Agent Name}
> **Promotion State**: {e.g., Ready For Review}
> **Task Type**: {e.g., ADS component, Docs-only}

## 1. Summary

{One-paragraph summary of what was done and why.}

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Modified | `path/to/file.dart` | {Brief description of change} |
| Created | `path/to/file_test.dart` | {Brief description} |

## 3. Gate Results

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `flutter test test/path/to/test.dart` | PASS | N/A |
| Package Gate | `cd packages/foo && flutter analyze` | PASS | N/A |
| Consumer Gate | `cd apps/bar && flutter test` | FAIL | `stale test` |
| Boundary Test | `flutter test test/boundary_test.dart` | PASS | N/A |

## 4. Known Failures

| Test/Component | Failure Class | Justification |
|----------------|---------------|---------------|
| `apps/bar/test/foo_test.dart` | `stale test` | Test expects old API shape. Fix tracked in Task 1208. |

## 5. Risk Notes

- {Note 1: e.g., "Changed public API of DSButton, affects downstream consumers."}
- {Note 2: e.g., "Skipped consumer gate for `apps/catalog` as it does not import this package."}

## 6. Recommendation

{Ready For Review / Needs Fix / Blocked}

{Brief justification for the recommendation.}
```

---

## 2. Example: Hypothetical ADS Component Task

Here is an example of a filled review packet for a hypothetical task that adds
a new `DSDatePicker` component.

```markdown
# Review Packet: Task 1234 — Add DSDatePicker Component

> **Date**: 2026-06-09
> **Executor**: builders
> **Promotion State**: Ready For Review
> **Task Type**: ADS component

## 1. Summary

Implemented the `DSDatePicker` molecule for the design system. This component
allows users to select a single date. It integrates with the existing
`DSTextField` for input display and uses the standard ADS color tokens.

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Created | `packages/warp_prism_ui/lib/src/molecules/ds_date_picker.dart` | New component implementation |
| Created | `packages/warp_prism_ui/test/molecules/ds_date_picker_test.dart` | Unit tests for DSDatePicker |
| Modified | `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Exported new component |

## 3. Gate Results

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `flutter test test/molecules/ds_date_picker_test.dart` | PASS | N/A |
| Package Gate | `cd packages/warp_prism_ui && flutter analyze && flutter test` | PASS | N/A |
| Consumer Gate | `cd apps/observatory && flutter test` | PASS | N/A |
| Boundary Test | `flutter test test/molecules/ds_date_picker_boundary_test.dart` | PASS | N/A |

## 4. Known Failures

None. All pre-existing failures in `apps/observatory` remain unchanged (64 failures per baseline).

## 5. Risk Notes

- The component is not yet integrated into any views; integration will happen in a future task.
- Keyboard navigation support is basic (arrow keys only); full accessibility audit is a follow-up task.

## 6. Recommendation

**Ready For Review**

All gates pass. The component is self-contained and follows ADS patterns. No regressions introduced.
```

---

## 3. Example: Task 1107 — Melos Monorepo Migration

This is a converted review packet for Task 1107, which migrated the repository
to a Melos monorepo structure.

```markdown
# Review Packet: Task 1107 — Warp Prism Melos Monorepo Migration

> **Date**: 2026-06-08
> **Executor**: builders
> **Promotion State**: Builder Done
> **Task Type**: Monorepo migration

## 1. Summary

Executed the migration from a single-root Flutter app to a Melos monorepo.
Moved the Observatory app into `apps/observatory`, extracted reusable ADS code
into `packages/warp_prism_ui`, and created `apps/catalog` and `apps/cybercore`
as consumer shells.

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Modified | `pubspec.yaml` | Converted to Melos workspace manifest |
| Created | `melos.yaml` | Melos orchestration config |
| Created | `packages/warp_prism_ui/pubspec.yaml` | Reusable ADS package |
| Created | `apps/observatory/pubspec.yaml` | Observatory app |
| Created | `apps/catalog/pubspec.yaml` | Catalog app shell |
| Created | `apps/cybercore/pubspec.yaml` | CyberCore app shell |
| Modified | `.gitignore` | Updated for Flutter/Dart/Melos |

## 3. Gate Results

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `flutter doctor -v` | PASS | N/A |
| Package Gate | `melos exec -- flutter analyze` | PASS | N/A |
| Consumer Gate | `melos exec -- flutter test` | FAIL | `pre-existing` |

## 4. Known Failures

| Test/Component | Failure Class | Justification |
|----------------|---------------|---------------|
| `warp_prism_ui` (20 tests) | `wave4-regression` | Pre-existing failures from Wave 4 component changes |
| `warp_prism_observatory` (64 tests) | `pre-existing` | Phantom completions from original task wave |

## 5. Risk Notes

- 84 total test failures across UI and Observatory packages.
- All failures are classified as pre-existing or regressions from prior tasks.
- No new regressions introduced by the monorepo migration itself.

## 6. Recommendation

**Ready For Review**

Monorepo structure is sound. All packages compile and analyze cleanly. Test failures are classified and tracked in the failure baseline.
```

---

## 4. Example: Task 1201 — Test Failure Baseline

This is a converted review packet for Task 1201, which created the test
failure inventory.

```markdown
# Review Packet: Task 1201 — Test Failure Baseline Inventory

> **Date**: 2026-06-09
> **Executor**: builders
> **Promotion State**: Builder Done
> **Task Type**: Governance

## 1. Summary

Created a comprehensive inventory of all test failures across the 4 Melos
packages. Classified failures as `wave4-regression` (24) or `pre-existing` (64).
Established a baseline for measuring stabilization progress.

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Created | `docs/reports/warp-prism-test-failure-baseline.md` | Failure inventory |

## 3. Gate Results

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `melos run test-fast` | PASS | N/A |

## 4. Known Failures

| Test/Component | Failure Class | Justification |
|----------------|---------------|---------------|
| UI package (24 tests) | `wave4-regression` | Tasks 1303/1304/1307/1309 will fix |
| Observatory (64 tests) | `pre-existing` | EPIC-14 tasks will fix |

## 5. Risk Notes

- This is an inventory-only task; no tests were modified.
- The baseline captures state after Task 1308 (toast fix).

## 6. Recommendation

**Ready For Review**

Documentation-only task. No code changes. Baseline is accurate and actionable.
```
