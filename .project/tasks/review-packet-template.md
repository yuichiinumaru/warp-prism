# Review Packet Template

> **Purpose**: Standardized format for summarizing task completion evidence for reviewers.
> **Origin**: Task 1207 (Review Packet Generator)
> **Dependency**: `.agents/rules/promotion-state-model.md` (Task 1202)

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

> [!CAUTION]
> **Historical snapshot — 2026-06-08.** This example was converted from
> Task 1107's Completion Evidence as captured on 2026-06-08. The live Task
> 1107 header (as of 2026-07-18) is in `docs/tasks/03-review/` (drain lane;
> historical Package Gate Failed annotations are superseded by later waves).
> **Do not treat this packet body as a current promotion recommendation** —
> it remains a **historical snapshot** of 2026-06-08 evidence.

```markdown
# Review Packet: Task 1107 — Warp Prism Melos Monorepo Migration

> **Date**: 2026-06-08 (historical snapshot — not current live state)
> **Executor**: builders
> **Promotion State**: Package Gate Failed (historical snapshot shows `Builder Done` evidence; live state is `Package Gate Failed`)
> **Task Type**: Monorepo migration
> **Live lane (2026-07-18)**: `docs/tasks/03-review/` — historical body only; not this packet’s promotion claim

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

**Do Not Promote from this historical packet** (live task is in `03-review/`; packet body remains 2026-06-08 snapshot)

Monorepo structure is sound. All packages compile and analyze cleanly. However, test failures block live promotion per the failure taxonomy.
```

---

## 4. Example: Task 1201 — Test Failure Baseline

> [!CAUTION]
> **Historical snapshot — 2026-06-11.** This example was converted from
> Task 1201's Completion Evidence as captured during its 2026-06-11 review
> cycle. The live Task 1201 has since been promoted to
> `docs/tasks/04-completed/` with a final `Promoted` status (verified
> 2026-06-30). Counts below reflect the 2026-06-11 capture; the live baseline
> has drifted since then (see Task 1201 Review Ledger rounds 2-4 for
> current counts). **This packet is a historical conversion example, not a
> live promotion recommendation.**

```markdown
# Review Packet: Task 1201 — Test Failure Baseline Inventory

> **Date**: 2026-06-11 (historical snapshot — live task promoted 2026-06-19)
> **Executor**: builders
> **Promotion State**: Promoted (historical snapshot shows `Builder Done` evidence; live state is `Promoted` in `04-completed/`)
> **Task Type**: Governance
> **Live lane (2026-06-30)**: `docs/tasks/04-completed/` — `Promoted`

## 1. Summary

Created a comprehensive inventory of all test failures across the 4 Melos
packages. Classified failures by taxonomy per the promotion state model.
Established a dated 2026-06-11 baseline for measuring stabilization progress.
(This snapshot reflects 2026-06-11 counts; live baseline has since drifted.)

## 2. Files Changed

| Status | File Path | Purpose |
|--------|-----------|---------|
| Created | `docs/reports/warp-prism-failure-baseline-inventory.md` | Failure inventory |
| Created | `docs/changelog/20260611-000000-1201-warp-prism-failure-baseline-inventory-builders.md` | Changelog |

## 3. Gate Results (2026-06-11 capture)

| Gate | Command | Result | Classification |
|------|---------|--------|----------------|
| Local Proof | `flutter test packages/warp_prism_ui/` | PASS | `+854` all passed |
| Local Proof | `flutter test apps/observatory/` | EXPECTED FAIL | `+641 -12` — 12 classified pre-existing |
| Local Proof | `flutter test apps/catalog/` | PASS | `+10` all passed |
| Local Proof | `flutter test apps/cybercore/` | PASS | `+12` all passed |

## 4. Known Failures (2026-06-11 capture)

| Test/Component | Failure Class | Justification |
|----------------|---------------|---------------|
| Observatory (12 failures) | `pre-existing (unrelated)` | Classified for follow-up stabilization; see inventory report for per-failure taxonomy |

## 5. Risk Notes

- This is an inventory-only task; no tests were modified.
- The baseline captures state on 2026-06-11.
- Counts have since drifted (UI `+862 -11`, Observatory `+646 -7` as of 2026-06-19).

## 6. Recommendation

**Ready For Review** (as of 2026-06-11 snapshot)

Documentation-only task. No code changes. Baseline is accurate and actionable as a dated governance deliverable.
```
