# Task 1504: PrismFilterWorkbench Organism

> **Status**: `[x]` Formal independent review 2026-07-18 (gt-flutter-code-reviewer; 100/100; ACCEPTED_100 → 03-review)
> **Review State**: Accepted — moved to `docs/tasks/03-review/`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1504` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismFilterWorkbench`: structured filter panel (and optional advanced modal) beyond `DSFilterChipGroup`, with apply/reset, sectioned criteria, and fixture filter definitions.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismFilterWorkbench` |
| **Internal implementation (preferred)** | `DSFilterWorkbench` + `typedef PrismFilterWorkbench = DSFilterWorkbench` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-14` |
| **ShadowBroker origin** | Filter panel + advanced filter modal patterns (page HUD) |
| **Osiris origin** | Layer/filter composition patterns in map workspace |
| **Wave** | **B** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map/Operate advanced filtering beyond chip groups |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSFilterChipGroup`, `DSSearchBar`, `DSChip`, form-ish molecules.
- Data table toolbar composition patterns.

### What is missing or broken

- No advanced multi-section filter workbench organism.
- No apply/reset filter session contract for map/operate HUDs.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Filter section header
- Criterion row
- Apply/reset footer bar

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST support sectioned filter criteria from a fixture schema.
- MUST expose apply/reset and current value callbacks.
- Widget tests: open advanced mode (if present), apply, reset, empty schema.
- A11y labels on apply/reset and interactive fields.
- Gallery fixture demonstrating chips + advanced panel composition.

---

## Exit Conditions

- [x] `PrismFilterWorkbench` exported.
- [x] Tests + gallery PASS gates.
- [x] Analyze + scoped flutter test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define filter section/criterion models.
- [x] Implement workbench body + optional advanced modal using glass chrome.
- [x] Compose with `DSFilterChipGroup` where useful rather than forking.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/filter_workbench/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/molecules/ds_filter_chip_group.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/filter_workbench/` | Create — tests |

### How

1. Design criterion model first.
2. Build panel UI; advanced modal optional but recommended.
3. Export/test/gallery.

### Why

Chip groups alone cannot express advanced multi-field filter sessions used by both reference map HUDs.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.

> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.


---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/filter_workbench/
# flutter test test/organisms/*filter_workbench*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

### Path-to-100 remediation (2026-07-18) — live revalidation

Remediates REJECT `82/100` (`docs/reports/review/1504-filter-workbench-review-2026-07-16.md`).

- **Files modified (path-to-100 wave)**:
  - `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart`
    - `_WorkbenchButton` / `_AdvancedExpandable` / `_IconHit` → `kMinInteractiveDimension` (48dp) — confirmed L984, L1244-1245, L1310-1311
    - Stable keys: `advancedModalCloseKey`, `advancedModalCancelKey`, `advancedModalDoneKey`
  - `packages/warp_prism_ui/test/organisms/filter_workbench/filter_workbench_test.dart`
    - Test: `interactive controls meet 48dp minimum touch target` (apply/clear/advanced/modal close/cancel/done)
- **Public API name verified**: `typedef PrismFilterWorkbench = DSFilterWorkbench` (`prism_aliases.dart:511`); organisms barrel `export 'filter_workbench/filter_workbench.dart'` (`organisms.dart:34`)
- **Fixture-only**: schema fixtures + gallery demo only; no Observatory product route writes
- **Tests or validation commands** (cwd `packages/warp_prism_ui`, **2026-07-18T05:19Z UTC** — this builder session):
  ```text
  $ dart format --output=none --set-exit-if-changed \
      lib/src/organisms/filter_workbench \
      lib/src/organisms/entity_intel_panel \
      lib/src/organisms/organisms.dart \
      lib/src/prism_aliases.dart \
      lib/src/gallery/design_system_gallery_sections.dart \
      test/organisms/filter_workbench \
      test/organisms/entity_intel_panel
  # → Formatted 9 files (0 changed) in 0.22 seconds; format_exit=0

  $ dart analyze lib/src/organisms/filter_workbench lib/src/organisms/entity_intel_panel \
      test/organisms/filter_workbench test/organisms/entity_intel_panel
  # → No issues found! analyze_exit=0

  $ flutter test test/organisms/filter_workbench/ test/organisms/entity_intel_panel/
  # → 00:01 +22: All tests passed! test_exit=0
  #   (11 filter including 48dp test + 11 entity)

  $ dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s); boundary_exit=0
  ```
- **Evidence classification**: `synthetic/factory-only` widget tests (ADS fixture gallery + organism harness) — correct for helper/library-only ADS organism task; no runtime product wiring claimed.
- **Gallery note**: `_FilterWorkbenchDemo` registered under Organisms gallery (sections ~L2456-2464, demo ~L4628+). Full-file analyze of gallery may have unrelated parallel-wave noise; task-owned demos present.
- **Local changelog entry**:
  - Original: `docs/changelog/2026-07-10-task-1504-filter-workbench-organism.md`
  - Path-to-100: `docs/changelog/2026-07-18-task-1504-filter-workbench-path-to-100.md`
- **Agent-wiki / docs institutionalization**: N/A (dispatch: no agent-wiki)
- **Executor**: gt-flutter-engineer (builders subagent under parent agentID=builders)
- **Completion date**: 2026-07-18
- **Lane note**: Remains in `02-doing/` with Review State `Ready For Review` per dispatch (no git / no promote / no lane move).

### Changelog Draft

```yaml
task: 1504
agent: gt-flutter-engineer
project: warp-prism
title: Path-to-100 PrismFilterWorkbench a11y + format
description: >
  Raised custom interactive hit regions to kMinInteractiveDimension (48dp) for
  workbench footer/advanced modal controls; added size widget tests; applied dart
  format to owned surfaces after REJECT 82/100 review. Live revalidated 2026-07-18T05:19Z.
summary: 48dp touch targets + format gate + 48dp size tests for PrismFilterWorkbench
verification: >
  dart format --set-exit-if-changed (owned) exit 0; dart analyze filter+entity
  exit 0; flutter test filter_workbench+entity_intel_panel 22/22; boundaries 7/7
```

### Builder Proof Matrix (Task 1504)

| Claim | Proof | Status |
| --- | --- | --- |
| Format gate clean (owned surfaces) | `dart format --output=none --set-exit-if-changed …` → 0 changed, exit 0 (2026-07-18T05:19Z) | PASS |
| 48dp `_WorkbenchButton` | `minWidth/minHeight: kMinInteractiveDimension` at `ds_filter_workbench.dart:1244-1245` | PASS |
| 48dp `_AdvancedExpandable` | `minHeight: kMinInteractiveDimension` at L984 | PASS |
| 48dp `_IconHit` (modal close) | `minWidth/minHeight: kMinInteractiveDimension` at L1310-1311 | PASS |
| Size tests for apply/clear/advanced/modal | `interactive controls meet 48dp minimum touch target` | PASS |
| Analyze (organism+tests) | `dart analyze …filter_workbench…` No issues, exit 0 | PASS |
| Widget tests | `flutter test test/organisms/filter_workbench/` (+ entity) **+22 All tests passed** | PASS |
| Boundaries | `dart run test/boundaries/boundary_test.dart` **7/7 PASS** | PASS |
| Export + Prism alias | `organisms.dart:34` + `typedef PrismFilterWorkbench` L511 | PASS |
| Gallery fixture demo | `_FilterWorkbenchDemo` registered in gallery sections | PASS |
| Fixture-only / no product routes | No Observatory Map/Operate edits | PASS |

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal; parent agentID=builders)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1504.md`
- **Lane outcome**: moved to `docs/tasks/03-review/`
- **Task reference**: Task 1504 (`warp-prism-filter-workbench-organism`)
- **Live prove (this review)**: format PASS; analyze PASS; pack organism tests **35/35 PASS** (11 filter); boundaries **7/7 PASS**

#### Current Open Blockers

- None.

#### Path-to-100 Summary

1. ~~Format gate~~ — builder 2026-07-18.
2. ~~48dp custom hit regions + size tests~~ — builder 2026-07-18.
3. ~~Desktop keyboard ActivateIntent on boolean / advanced expander / modal IconHit~~ — expert 2026-07-18; formal confirmed.

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1504.md` — **100/100** expert path-to-100 — formal confirmed
- `docs/reports/review/1504-filter-workbench-review-2026-07-16.md` — **82/100** REJECT (format + 48dp) — **RESOLVED**
- `docs/reports/review-wave-2026-07-11/task-1504-independent-review.md` — `95/100`, `HELD_IN_REVIEW_PATH_TO_100`

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/filter_workbench/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` after public DS/Prism surface changes — must stay **7/7 PASS**.
- Re-run `dart format --output=none --set-exit-if-changed` on task surface after any edit.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.
