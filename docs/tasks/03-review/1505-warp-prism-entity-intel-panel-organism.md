# Task 1505: PrismEntityIntelPanel Organism

> **Status**: `[x]` Formal independent review 2026-07-18 (gt-flutter-code-reviewer; 100/100; ACCEPTED_100 → 03-review)
> **Review State**: Accepted — moved to `docs/tasks/03-review/`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1505` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismEntityIntelPanel` as a **pluggable dossier registry** organism: given a selection type, resolve a body builder. Harvest mode contracts only — no mega-widget clone of NewsFeed/OsintPanel.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismEntityIntelPanel` |
| **Internal implementation (preferred)** | `DSEntityIntelPanel` + `typedef PrismEntityIntelPanel = DSEntityIntelPanel` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-04` |
| **ShadowBroker origin** | `NewsFeed.tsx` selection-driven multi-body (mode contract only — do not copy ~2k LOC structure) |
| **Osiris origin** | Region dossier / intel panel body switching by selection type |
| **Wave** | **C** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map selection + asset detail patterns; compose `DSDetailInspector` |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSDetailInspector` for generic inspector chrome.
- Asset detail patterns in Observatory (product, not ADS requirement).
- Story panel / markdown / code blocks for body content composition.

### What is missing or broken

- No pluggable dossier registry organism keyed by entity/selection type.
- No fixture-driven multi-body intel panel for gallery/CyberCore.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Dossier body slot
- Selection header chip
- Unknown-type empty state

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST register multiple dossier body builders by type key.
- MUST fall back to empty/unknown state when type unregistered.
- MUST update body when selection changes.
- Widget tests: type A body, type B body, unknown type, null selection.
- A11y labels on close/pin/header actions if present.
- Gallery shows ≥2 dossier types with fixture entities.

---

## Exit Conditions

- [x] `PrismEntityIntelPanel` exported.
- [x] Tests + gallery PASS.
- [x] Analyze + scoped test PASS.
- [x] Document that megafile structure was not ported.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Design registry API (`type` → `WidgetBuilder` / dossier config).
- [x] Implement panel chrome (compose or wrap `DSDetailInspector` if fit).
- [x] Fixture models for entity selection.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/ds_entity_intel_panel.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/ds_detail_inspector.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/entity_intel_panel/` | Create — tests |

### How

1. Extract dossier registry contract from harvest mode-switch descriptions.
2. Implement thin host + registry; bodies are fixtures.
3. Export/test/gallery.

### Why

Selection→dossier is a core shared pattern; without a pluggable host, each consumer invents brittle switches.

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

> [!CAUTION]
> Do **not** port NewsFeed/OsintPanel structure or domain one-off bodies. Mode contract only.

---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/entity_intel_panel/
# flutter test test/organisms/*entity_intel_panel*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

### Path-to-100 remediation (2026-07-18) — live revalidation

Remediates REJECT `85/100` (`docs/reports/review/1505-entity-intel-panel-review-2026-07-16.md`).

- **Files modified (path-to-100 wave)**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
    - Gallery `_SelectChip` → `BoxConstraints(minHeight/minWidth: kMinInteractiveDimension)` at L4866-4868 + padding
  - `packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/*` — implementation already a11y-compliant (IconButton close/pin)
- **Public API name verified**: `typedef PrismEntityIntelPanel = DSEntityIntelPanel` (`prism_aliases.dart:825` + selection/dossier/bodyBuilder/fixtures); barrel `export 'entity_intel_panel/entity_intel_panel.dart'` (`organisms.dart:42`)
- **Megafile note**: Mode/registry contract only — no NewsFeed/OsintPanel structural port; fixture bodies only
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
  #   (11 entity intel panel tests included)

  $ dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s); boundary_exit=0
  ```
- **Evidence classification**: `synthetic/factory-only` widget tests (ADS fixture gallery + organism harness) — correct for helper/library-only ADS organism task; no runtime product wiring claimed.
- **Gallery note**: `_EntityIntelPanelDemo` + `_SelectChip` 48dp present (sections ~L2479-2485, demo ~L4754+).
- **Local changelog entry**:
  - Original: `docs/changelog/2026-07-11-task-1505-entity-intel-panel-organism.md`
  - Path-to-100: `docs/changelog/2026-07-18-task-1505-entity-intel-panel-path-to-100.md`
- **Agent-wiki / docs institutionalization**: N/A (dispatch: no agent-wiki)
- **Executor**: gt-flutter-engineer (builders subagent under parent agentID=builders)
- **Completion date**: 2026-07-18
- **Lane note**: Remains in `02-doing/` with Review State `Ready For Review` per dispatch (no git / no promote / no lane move).

### Changelog Draft

```yaml
task: 1505
agent: gt-flutter-engineer
project: warp-prism
title: Path-to-100 PrismEntityIntelPanel format + gallery a11y
description: >
  Applied dart format to entity intel panel organism/tests; raised gallery
  _SelectChip demo touch target to kMinInteractiveDimension (48dp) after REJECT
  85/100 review. Organism chrome already met 48dp. Live revalidated 2026-07-18T05:19Z.
summary: Format gate + gallery SelectChip 48dp for PrismEntityIntelPanel path-to-100
verification: >
  dart format --set-exit-if-changed (owned) exit 0; dart analyze filter+entity
  exit 0; flutter test filter_workbench+entity_intel_panel 22/22; boundaries 7/7
```

### Builder Proof Matrix (Task 1505)

| Claim | Proof | Status |
| --- | --- | --- |
| Format gate clean (owned surfaces) | `dart format --output=none --set-exit-if-changed …` → 0 changed, exit 0 (2026-07-18T05:19Z) | PASS |
| Gallery `_SelectChip` ≥48dp | `ConstrainedBox(minHeight/minWidth: kMinInteractiveDimension)` at gallery L4866-4868 | PASS |
| Organism close/pin a11y | Existing IconButton ~48dp + tests for labels | PASS |
| Analyze (organism+tests) | `dart analyze …entity_intel_panel…` No issues, exit 0 | PASS |
| Widget tests | 11 entity intel tests in combined **22/22** suite | PASS |
| Boundaries | `dart run test/boundaries/boundary_test.dart` **7/7 PASS** | PASS |
| Export + Prism alias | `organisms.dart:42` + `typedef PrismEntityIntelPanel` L825 | PASS |
| Gallery ≥2 dossier types | `_EntityIntelPanelDemo` multi-type fixture selection (agent+region) | PASS |
| No megafile port | Registry/mode contract only | PASS |
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
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1505.md`
- **Lane outcome**: moved to `docs/tasks/03-review/`
- **Task reference**: Task 1505 (`warp-prism-entity-intel-panel-organism`)
- **Live prove (this review)**: format PASS; analyze PASS; pack organism tests **35/35 PASS** (11 entity); boundaries **7/7 PASS**

#### Current Open Blockers

- None.

#### Path-to-100 Summary

1. ~~Format gate~~ — builder 2026-07-18.
2. ~~Gallery `_SelectChip` 48dp~~ — builder 2026-07-18.
3. ~~Close/pin nested Semantics without excludeSemantics~~ — expert 2026-07-18; formal confirmed (`excludeSemantics: true` + aligned tooltips).

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1505.md` — **100/100** expert path-to-100 — formal confirmed
- `docs/reports/review/1505-entity-intel-panel-review-2026-07-16.md` — **85/100** REJECT — **RESOLVED**
- `docs/reports/review-wave-2026-07-11/task-1505-independent-review.md` — score `95/100`, `HELD_IN_REVIEW_PATH_TO_100`

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart` after public DS/Prism surface changes — must stay **7/7 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.
