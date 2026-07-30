# Task 1706 (warp-prism-prism-breadcrumbs-organism)

**Status**: Doing
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

### Notes

**Origin**: New gap discovered in `cybernetics-core-frontend/docs/reports/05-deep-gap-audit-frontend-vs-ads.md` §2.

**Spec sources**:
- `cybernetics-core-frontend/docs/reports/01-omniroute2-sidebar-topbar-ia-analysis.md` §6 (breadcrumbs + header auto-derivation)
- `cybernetics-core-frontend/docs/reports/02-omniroute2-collapsible-menu-patterns.md` (chevron icons, separator patterns)
- Report 05 §2 (TRUE GAP)

**Blocks frontend tasks**: 0047 (breadcrumbs + page header resolver).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `Material` breadcrumb widgets. Compose with `DSText` + `DSInteractiveSurface` + `DSIcon`.
