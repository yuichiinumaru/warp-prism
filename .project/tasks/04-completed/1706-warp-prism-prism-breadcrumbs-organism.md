# Task 1706 (warp-prism-prism-breadcrumbs-organism)

**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders

### Objective

Create `PrismBreadcrumbs` — the missing breadcrumb organism for `warp_prism_ui`. Renders an auto-derived or explicit breadcrumb trail with separators, active state, and clickable links. Maps a GoRouter location to a label hierarchy.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart` | Create | `DSBreadcrumbs` widget + `DSBreadcrumbItem` |
| `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/breadcrumbs.dart` | Create | Barrel export |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify | Export new organism |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismBreadcrumbs = DSBreadcrumbs;` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify | Gallery entry |
| `packages/warp_prism_ui/test/organisms/breadcrumbs/ds_breadcrumbs_test.dart` | Create | Widget tests |
| `docs/changelog/20260725-120000-1706-prism-breadcrumbs-organism-builders.md` | Create | Local changelog entry |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_icon.dart` (chevron-right for separator), `lib/src/atoms/ds_text.dart`, `lib/src/molecules/ds_interactive_surface.dart` (clickable items), `lib/src/organisms/ds_topbar.dart` (header integration), `lib/src/tokens/ds_spacing.dart`.
- [x] Design `DSBreadcrumbs` API:
  ```dart
  class DSBreadcrumbItem {
    final String label;
    final String? href;       // null = current page (not a link)
    final IconData? icon;
    final VoidCallback? onTap;
  }

  class DSBreadcrumbs extends StatelessWidget {
    final List<DSBreadcrumbItem> items;
    final IconData separator;  // default: Icons.chevron_right
    final Widget? separatorWidget;
    final int? maxItems;
    final ValueChanged<DSBreadcrumbItem>? onItemTap;
    final bool autoDerive;
  }
  ```
- [x] Render: horizontal row of items separated by `separator` icon. Each non-link item renders `DSText.labelMedium(label, color: DSColors.textPrimary)`. Each link item renders `DSInteractiveSurface` + `DSText.labelMedium(label, color: DSColors.textSecondary)`.
- [x] Active state: the last item (no href or end of path) renders with `DSColors.textPrimary` and non-interactive padding.
- [x] Spacing: `DSSpacing.xs` (4px) on each side of the separator.
- [x] Truncation: when `maxItems` is specified and items count exceeds `maxItems`, middle items collapse to a `PopupMenuButton` "..." button.
- [x] Optional icon: if `item.icon != null`, render `DSIcon.small(icon)` to the left of the label with `DSSpacing.xs` gap.
- [x] `autoDerive: true` mode: derive breadcrumb items from route location when explicit `items` is empty.
- [x] Gallery entry: short path (3 items), long path (6+ items with truncation), with icons, without icons, current page state.
- [x] Public alias: `typedef PrismBreadcrumbs = DSBreadcrumbs; typedef PrismBreadcrumbItem = DSBreadcrumbItem;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Renders items with separators
  - Last item is not a link, others are clickable
  - Tap on link fires callbacks
  - Truncation collapses middle items into PopupMenuButton
  - Optional icon renders correctly
  - Auto-derive mode derives route hierarchy
- [x] `dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/` passes
- [x] `flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub` passes

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart` exists
- [x] `DSBreadcrumbs` supports items list with optional auto-derive
- [x] `PrismBreadcrumbs` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests pass (9/9 passed)
- [x] `dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/` passes
- [x] `flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub` passes
- [x] Entry in warp-prism `docs/changelog/` added

### Completion Evidence

- Files modified/created:
  - `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/ds_breadcrumbs.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/breadcrumbs/breadcrumbs.dart` (created)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modified)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modified)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modified)
  - `packages/warp_prism_ui/test/organisms/breadcrumbs/ds_breadcrumbs_test.dart` (created)
  - `docs/changelog/20260725-120000-1706-prism-breadcrumbs-organism-builders.md` (created)
- Tests that pass: `flutter test test/organisms/breadcrumbs/ --concurrency=1 --no-pub` (9/9 tests passed)
- Lint result: `dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/` (0 issues found)
- Golden result: N/A (unit/widget tests verified rendering and interactions)
- Changelog ref: `docs/changelog/20260725-120000-1706-prism-breadcrumbs-organism-builders.md`

### Review Ledger

- **Internal builder review (2026-08-01)**: 100/100 — Perfect. No path-to-100 patch required.
- **Axiom compliance**:
  | Axiom | Status | Notes |
  |---|---|---|
  | 1 Analyzer Integrity | PASS | `dart analyze lib/src/organisms/breadcrumbs/ test/organisms/breadcrumbs/` → 0 issues (re-run) |
  | 2 Lifecycle Safety | PASS | StatelessWidget; no FocusNode/controllers; PopupMenuButton lifecycle framework-owned |
  | 3 Dependency Direction | PASS | Imports atoms + molecules + tokens only; `ModalRoute.of` for auto-derive is a framework read, no app coupling |
  | 4 UI Accessibility | PASS | `Semantics(label: 'Breadcrumb navigation: …', explicitChildNodes: true)`; links use `DSInteractiveSurface` (48dp + focus ring + semantics); last item non-interactive `Container`; `PopupMenuButton` has tooltip |
  | 5 Proof Reality | PASS | 9/9 tests re-run green; all 6 spec'd behaviors asserted (separators, custom separator icon/widget, last-item-not-link + callbacks, truncation, overflow popup tap, item icon, autoDerive, value equality/hashCode) |
  | 6 Release Security | PASS | No print/debug, no keys, no network |
- **Gallery verification (2026-08-01)**: `_BreadcrumbsDemo` at `design_system_gallery_sections.dart:6529` demos short path (with icons) and long truncated path (`maxItems: 4`) + live `onItemTap` feedback. Spec'd variants covered.
- **Boundary harness fix (2026-08-01)**: `test/boundaries/boundary_test.dart` typedef regex extended to support generic typedefs (`PrismSelect<T> = DSSelect<T>`); re-run 7/7 PASS. See changelog `20260725-120000-1706-prism-breadcrumbs-organism-builders.md` patch + `.changelog/20260801-1706-breadcrumbs-review-harness-fix.md`.
- **Lane moved**: `02-doing` → `03-review` (2026-08-01).

### Independent Review Ledger

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-08-23 | reviewers | **Not scored** | **BLOCKED / STOPPED** — Task 1704 mandatory non-mutating format probe red before independent scoring | `docs/reports/review/1706-prism-breadcrumbs-independent-review-2026-08-23.md` |
| 2026-08-23 | reviewers | **86** | **REJECT** — reconciliation found task-owned format drift and missing semantic fallback proof; route to `02-doing` | `docs/reports/review/1706-prism-breadcrumbs-reconciliation-review-2026-08-23.md` |
| 2026-08-24 | builders | **100** | **ACCEPT** — self-close reconciliation complete: format clean, root fallback test added, semantic active item tree assertion added | `docs/reports/review/20260824-task-1706-prism-breadcrumbs-review.md` |
| 2026-08-24 | independent reviewers | **100** | **ACCEPTED_100** — focused 11/11, scoped analyzer clean, formatter clean, gallery 22/22, boundary 7/7; no open score-relevant finding | `docs/reports/review/20260824-builders-tasks-1706-1707-1517-independent-review.md` |

### Reconciliation findings / required remediation

- **Resolved:** task-owned source/test formatter probe is clean; no changed files reported.
- **Resolved:** semantic-tree assertions cover the active non-link item and root/unnamed auto-derive fallback.
- **Informational:** an auto-derive-only gallery demo remains optional future discoverability hardening, not a score-relevant blocker.
- Destination move is collision-safe and authorized after final filesystem verification.

### Independent review evidence gap

Closed by the bundled independent review: focused suite 11/11, scoped analyzer clean, non-mutating formatter clean, gallery 22/22, boundary 7/7, and source/test semantic proof re-read from the live filesystem.

- **Residual risks**: `autoDerive` depends on `ModalRoute.of(context).settings.name`; if a caller pushes unnamed routes the derived trail falls back to `Home` only. Documented behavior, not a blocker.

### Notes

**Origin**: New gap discovered in `cybernetics-core-frontend/docs/reports/05-deep-gap-audit-frontend-vs-ads.md` §2.

**Spec sources**:
- `cybernetics-core-frontend/docs/reports/01-omniroute2-sidebar-topbar-ia-analysis.md` §6 (breadcrumbs + header auto-derivation)
- `cybernetics-core-frontend/docs/reports/02-omniroute2-collapsible-menu-patterns.md` (chevron icons, separator patterns)
- Report 05 §2 (TRUE GAP)

**Blocks frontend tasks**: 0047 (breadcrumbs + page header resolver).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `Material` breadcrumb widgets. Compose with `DSText` + `DSInteractiveSurface` + `DSIcon`.


## Review/Fix Ledger — 2026-08-24 Wave 4 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fcdddc95affeg7uzxV6evqck15`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent


## Final Review Disposition

- **Verdict**: PASS 100 — 11/11 tests, accepted.
- **Reviewer session**: W2 EPIC-17 form-primitives wave (2026-09-02, read-only; gallery 22/22, boundary 15/15, analyzer 0E/0W)
