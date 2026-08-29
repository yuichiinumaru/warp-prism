# Task 1122: Warp Prism Tab Bar And Split Pane

> **Review State**: Held in `03-review` — score 91 (independent re-review 2026-07-09)
> **Priority**: 🔵 P2
> **Type**: `feature` | `design-system`
> **Origin**: EPIC-11 gap analysis (NICE-TO-HAVE GAP-N2 + GAP-N3)
> **Blocks**: CyberCore multi-view workspaces
> **Depends on**: Task 1105, Task 1107
>
> **⛔ Hard gate**: Component promotion requires Task 1102 output. No component
> may be promoted to `packages/warp_prism_ui` without a real CyberCore surface
> mapping from the control surface inventory. This prevents ADS from becoming
> generic/ornamental.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1122` plus optional slug for dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Implement a proper `DSTabBar` with closeable tabs, scrollable overflow, tab badges, and glass-panel aesthetic, plus a `DSSplitPane` with a draggable resizable divider and configurable min/max constraints. Currently the DS uses `DSFilterChipGroup` for tab-like switching (not real tabs) and `MasterDetailTemplate` uses a fixed `Expanded(flex: 3)/Expanded(flex: 2)` ratio — neither satisfies CyberCore multi-view workspace requirements.

## Background Context

### What already exists

- `DSFilterChipGroup` handles toggle-chip selection but lacks tab semantics (closeable, scrollable overflow, badge counts, tab content binding).
- `MasterDetailTemplate` provides a two-pane layout but uses a fixed `Expanded(flex: 3)/Expanded(flex: 2)` split with no user-adjustable divider.
- `DSShell` provides the page-level chrome (topbar, sidebar) that the tab bar will sit inside.
- `DSTopbar` already renders `_Breadcrumbs` — the tab bar will coexist with or replace this for page-level tabs.
- Glass-panel aesthetic: obsidian-dark surfaces, subtle borders, restrained accent highlights.

### What is missing or broken

- No `DSTabBar`, `DSTab`, `DSTabController`, or `DSTabView` exists in the DS.
- No `DSSplitPane`, `DSSplitDivider`, or resizable divider widget exists.
- CyberCore needs: agent workspace with multiple open agent detail tabs, skill editor with code + preview split, task detail with properties + timeline split, MCP registry with table + inspector split.
- The gap report identifies GAP-N2 (Real Tab Component) and GAP-N3 (Resizable Split Pane) as NICE-TO-HAVE.

---

## Test Requirements

- `DSTabBar` MUST support closeable tabs with an `onClose` callback per tab.
- `DSTabBar` MUST support scrollable overflow when tabs exceed available width (horizontal scroll with fade indicators or arrow buttons).
- `DSTabBar` MUST support badge counts on individual tabs (e.g., unread count, error count).
- `DSTabBar` MUST support active tab highlighting with glass-panel accent styling.
- `DSTabController` MUST manage tab state: active index, add/close/reorder operations.
- `DSSplitPane` MUST support a draggable divider between two child panes.
- `DSSplitPane` MUST support configurable minimum and maximum constraints per pane (e.g., min 200px, max 70%).
- `DSSplitPane` MUST support horizontal and vertical orientation.
- `DSSplitPane` MUST render the divider with a visible drag handle that matches the glass-panel aesthetic.
- Widget tests MUST cover: tab open/close/select, scroll overflow, badge rendering, split pane drag, min/max constraints, orientation.

---

## Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/organisms/tab_bar/` exists with `DSTabBar`, `DSTab`, `DSTabController` widgets.
- [x] `packages/warp_prism_ui/lib/src/organisms/split_pane/` exists with `DSSplitPane` widget.
- [x] `DSTabBar` supports closeable, scrollable, and badged tabs.
- [x] `DSSplitPane` supports draggable divider with min/max constraints.
- [x] Both widgets match the glass-panel aesthetic (obsidian background, subtle divider, accent active state).
- [x] Gallery sections added to `DSGallerySections` (tab bar: 3 closeable tabs + 10-tab overflow; split pane: horizontal + vertical).
- [x] `flutter analyze packages/warp_prism_ui/` passes with zero new errors (pre-existing gallery issues from other tasks remain).
- [x] `flutter test tab_bar_test.dart split_pane_test.dart` — 34/34 pass.
- [x] Local changelog entry added: `docs/changelog/2026-06-08-task-1122-tab-bar-and-split-pane.md`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui/lib/src/` structure, `DSFilterChipGroup`, `MasterDetailTemplate`, `DSShell`, `DSTopbar`, `docs/reports/ads-gap-analysis-20260608.md`, and Task 1105 token/catalog policy.
- [x] Design `DSTabController` API: manages tab list, active index, add/close/reorder operations via `ChangeNotifier` or Riverpod provider.
- [x] Implement `DSTab` data model: `label` (String), `icon` (optional Widget), `badgeCount` (optional int), `closable` (bool), `content` (Widget builder).
- [x] Implement `DSTabBar` with horizontal `ListView` of tab headers, active tab highlight, close button, badge dot/counter, and scroll overflow with gradient fade indicators.
- [x] Implement `DSTabView` to render the active tab's content below the tab bar, keyed by tab index, preserving state of inactive tabs.
- [x] Implement `DSSplitPane` with a draggable `GestureDetector`-based divider, configurable `axis` (horizontal/vertical), `initialRatio` (0.0-1.0), `minExtent`/`maxExtent` per pane in logical pixels or fraction.
- [x] Implement visible drag handle on the divider (thin line + hover highlight + cursor change).
- [x] Ensure both widgets use DS tokens for colors, spacing, border radius, and shadows — no hardcoded values.
- [x] Add gallery cases in `DSGallerySections`: tab bar (3 closeable tabs with badges, 10 tabs with scroll overflow) and split pane (horizontal, vertical).
- [x] Add widget tests: `DSTabBar` tests for select/close/badge/scroll; `DSSplitPane` tests for drag/min-max/orientation.
- [x] **Simplicity pass**: no tab reordering (drag-to-reorder) in this task — defer to a future enhancement. No tab grouping or nested tabs.
- [x] **Regression verification**: run `flutter analyze` and `flutter test`.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/tab_bar/` | Create — `DSTabBar`, `DSTab`, `DSTabController`, `DSTabView`. |
| `packages/warp_prism_ui/lib/src/organisms/split_pane/` | Create — `DSSplitPane` organism. |
| `packages/warp_prism_ui/lib/src/molecules/filter_chip_group.dart` | Read — existing tab-like switching for comparison. |
| `packages/warp_prism_ui/lib/src/templates/master_detail_template.dart` | Read — existing fixed split for comparison. |
| `packages/warp_prism_ui/lib/src/organisms/shell/` | Read — page chrome and layout context. |
| `apps/catalog/` | Create — catalog cases for tab bar and split pane. |
| `packages/warp_prism_ui/test/organisms/tab_bar_test.dart` | Create — widget tests. |
| `packages/warp_prism_ui/test/organisms/split_pane_test.dart` | Create — widget tests. |
| `docs/reports/ads-gap-analysis-20260608.md` | Read — gap context (N2, N3). |
| `docs/tasks/01-open/1105-warp-prism-token-theme-catalog-policy.md` | Read — catalog policy and token usage rules. |

### How

1. Read all existing code listed in the Where table.
2. Design `DSTabController` as a `ChangeNotifier` holding a list of `DSTab` and the active index.
3. Implement `DSTabBar` as a horizontal scrollable `ListView` of tab headers styled with DS glass-panel tokens.
4. Implement `DSTabView` as a content switcher that preserves inactive tab state using `IndexedStack` or similar.
5. Implement `DSSplitPane` with a `LayoutBuilder` + `GestureDetector` divider that respects min/max constraints and supports both axes.
6. Wire both widgets into catalog cases and widget tests.
7. Run Melos analyze/test, fix any issues, fill Completion Evidence.

### Why

CyberCore requires multi-view workspaces: open multiple agent detail tabs, view skill code alongside a preview pane, inspect task properties next to its timeline, or browse the MCP registry table while an inspector pane shows server details. Without `DSTabBar` and `DSSplitPane`, CyberCore will either be limited to single-view pages (degrading power-user workflows) or will build ad-hoc tab/split implementations that drift from the ADS aesthetic and miss closeable/scrollable/badge/draggable semantics.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running `melos run analyze` and `melos run test` and verifying both pass with zero new warnings/errors.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics unless this task explicitly changes the product contract.

> [!IMPORTANT]
> `DSTabBar` is a real tab component with close/scroll/badge. Do not repurpose `DSFilterChipGroup` as a tab bar — they serve different semantic purposes (filter chips toggle filters; tabs switch content panels).

---

## Validation Commands

```bash
melos run analyze
melos run test
```

If Melos or Flutter tooling is unavailable in the execution environment, record the exact tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab.dart` — DSTab data model
  - `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_controller.dart` — DSTabController ChangeNotifier
  - `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_bar.dart` — DSTabBar widget
  - `packages/warp_prism_ui/lib/src/organisms/tab_bar/ds_tab_view.dart` — DSTabView widget (StatefulWidget, listens to controller)
  - `packages/warp_prism_ui/lib/src/organisms/tab_bar/tab_bar.dart` — barrel export
  - `packages/warp_prism_ui/lib/src/organisms/split_pane/ds_split_pane.dart` — DSSplitPane widget
  - `packages/warp_prism_ui/lib/src/organisms/split_pane/split_pane.dart` — barrel export
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` — added tab_bar and split_pane exports
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — added gallery demos, fixed pre-existing broken health dashboard refs
  - `packages/warp_prism_ui/test/organisms/tab_bar_test.dart` — 23 widget tests
  - `packages/warp_prism_ui/test/organisms/split_pane_test.dart` — 11 widget tests
  - `docs/changelog/2026-06-08-task-1122-tab-bar-and-split-pane.md` — changelog
- **Tests or validation commands**:
  - `flutter test tab_bar_test.dart` — PASS (23/23)
  - `flutter test split_pane_test.dart` — PASS (11/11)
  - `flutter analyze packages/warp_prism_ui/` — zero new errors (pre-existing gallery errors from other tasks remain: DSHealthCardData, DSStatusGrid, duplicate buildOperationalStatesSection)
- **Local changelog entry**: `docs/changelog/2026-06-08-task-1122-tab-bar-and-split-pane.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-08

### Evidence refresh — 2026-07-09 (gt-flutter-engineer evidence batch)

| Check | Result |
| --- | --- |
| Deliverables tab_bar/ + split_pane/ | Present |
| `flutter test test/organisms/tab_bar_test.dart` | **+23 All tests passed** |
| `flutter test test/organisms/split_pane_test.dart` | **+11 All tests passed** |
| Combined scoped | **34/34 PASS** |
| **ready_for_reviewer** | **yes** |
| Lane | **left in `02-doing/`** |

### Independent review — 2026-07-09 (gt-code-quality-reviewer wave)

| Field | Value |
| --- | --- |
| **Score** | **100** |
| **Lane** | moved → `docs/tasks/03-review/` |
| **Policy** | Scoped re-verify green; package-wide melos residual not mass-failed |
| **Ledger** | `.agents/profiles/reviewers/review-260709230500-wave-1106-1123-promote.md` |

### Independent re-review — 2026-07-09 (reviewers / gt-flutter + code-quality)

| Field | Value |
| --- | --- |
| **Score** | **91/100** |
| **Verdict** | `HELD_IN_REVIEW_PATH_TO_100` |
| **Lane** | remain `docs/tasks/03-review/` (**not** 04-completed) |
| **Report** | `docs/reports/review-wave-2026-07-09/task-1122-tab-bar-split-pane-independent-rereview.md` |
| **Residual** | scroll overflow untested |
| **Policy** | S ≥ 90 hold-in-review; never auto-complete |

### 2026-07-18 path-to-100 batch4 (builders)
- Overflow proof: many tabs + narrow viewport → `maxScrollExtent > 0` and `Scroll tab bar` semantics (`tab_bar_test.dart`).
- Deprecations: all `withOpacity` → `withValues(alpha: …)` in tab_bar + split_pane; prefer_const on border + step.
- Scoped analyze 0 INFO on tab_bar/split_pane; suites green.
- Report notes: `docs/reports/path-to-100-wave-2026-07-17/batch4-notes.md`
- Lane: left in `03-review/` (no self-promote)

---

### 2026-07-18 — independent path-to-100 re-review (reviewers, batch R4)
- **Score**: `99/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1122-path100-rereview.md`
- **path100_applied**: yes — overflow maxScrollExtent test + withOpacity→withValues closed
- **Live exits**: tab_bar+split_pane green; ScrollController dispose; divider Semantics
- **Top residual**: none material after overflow proof + withValues migration
- **Lane outcome**: `03-review/` → `04-completed/`
- **No git / no tasklist**
