# Warp Prism Test Failure Baseline

> **Date**: 2026-06-09
> **Source**: `flutter test` across all 4 Melos packages
> **Status**: Inventory only — no tests were modified
> **Toast fix applied**: Task 1308 fixed 7 toast failures (31→24 in UI package)

---

## 1. Package Summary

| Package | Pass | Fail | Total | Pass Rate |
|---------|------|------|-------|-----------|
| warp_prism_ui | 764 | 24 | 788 | 97.0% |
| observatory | 589 | 64 | 653 | 90.2% |
| cybercore | 12 | 0 | 12 | 100% |
| catalog | 1 | 0 | 1 | 100% |
| **TOTAL** | **1366** | **88** | **1454** | **94.0%** |

---

## 2. Failure Classification

| Classification | Count | Description |
|----------------|-------|-------------|
| `wave4-regression` | 24 | UI package failures caused by Wave 4 component changes (tasks 1106-1122) |
| `pre-existing` | 64 | Observatory failures that existed before the stabilization wave |
| **Total** | **88** | |

---

## 3. UI Package Failures (24) — wave4-regression

### 3.1 molecules_contract_test.dart (8 failures)

**Root cause**: Contract drift — Task 1106 (operational component MVP) changed DSStatusDot, DSMetricTile, DSStateSurface constructors and semantics. Tests expect old API surface.

| Test | Error |
|------|-------|
| DSStatusDot contract animated dot renders with animation | Expected: AnimatedBuilder found; Actual: found 2 widgets (duplicate) |
| DSStatusDot contract has semantic label | Expected: Semantics with label; Actual: 0 found |
| DSMetricTile contract shows health indicator | Expected: health badge; Actual: not rendered |
| DSStateSurface contract disabled state | Expected: disabled constructor; Actual: wrong widget tree |
| (4 more) | Similar contract drift patterns |

### 3.2 design_system_gallery_test.dart (7 failures)

**Root cause**: Gallery compile — `design_system_gallery_sections.dart` references types that were added/renamed during Wave 4. Gallery sections were added incrementally by different subagents without full re-validation.

| Test | Error |
|------|-------|
| DesignSystemGalleryPage renders without errors | Multiple undefined types in gallery sections |
| (6 more) | Cascade from gallery compile errors |

### 3.3 templates_contract_test.dart (3 failures)

**Root cause**: Template contract drift — MasterDetailTemplate and related templates changed with shell/responsive updates.

### 3.4 design_system_accessibility_test.dart (3 failures)

**Root cause**: Semantics changes from Task 1118 (state vocabulary expansion). DSChip, DSFilterChipGroup, DSSidebar semantics labels changed.

| Test | Error |
|------|-------|
| DSChip — Focus & Semantics has Semantics with label | Expected: 1 Semantics with label "Test Chip"; Actual: 0 found |
| DSFilterChipGroup — individual filter chips have button semantics | Expected: 1 with label "Alpha"; Actual: 0 found |
| DSSidebar — sidebar items have button and selected semantics | Expected: 1 with label "Map"; Actual: 0 found |

### 3.5 state_surface_test.dart (1 failure)

**Root cause**: DSStateSurface expanded from 3→7 states (Task 1118). Test expects old state count.

### 3.6 operational_components_test.dart (1 failure)

**Root cause**: Task 1106 operational component changes not reflected in test expectations.

### 3.7 atoms_contract_test.dart (1 failure)

**Root cause**: DSStatusDot animation contract changed (duplicate AnimatedBuilder).

---

## 4. Observatory Failures (64) — pre-existing

All 64 failures existed before the stabilization wave. They are phantom completions from the original 57-task wave where tasks were marked `[x]` Done but tests were never fixed.

### 4.1 By feature area

| Feature Area | Failures | Primary Files |
|--------------|----------|---------------|
| Asset Detail | 24 | extended_detail_variants (11), skill_task_detail (6), responsive_detail (5), descriptor (2) |
| Data/Parsers | 11 | workspace_task_projection_parser (8), workspace_graph_builder (2), diagnostics (1) |
| Governance | 6 | boundaries_overview (3), analytics_panels (3) |
| History | 7 | story_modes (5), page (2) |
| Map | 6 | workspace_page (3), surface_states (2), selection (1) |
| Operate | 4 | task_detail_inspector (4) |
| App/Shell | 3 | app_shell_smoke (2), deep_link_fallback (1) |
| Overview | 1 | overview_provider (1) |
| Models | 1 | workspace_graph_models (1) |

### 4.2 Root cause categories

| Category | Count | Description |
|----------|-------|-------------|
| Parser contract drift | 11 | Task projection parser produces wrong shapes |
| View-model mismatch | 18 | Asset detail variants, responsive detail, skill/task detail |
| Missing fixture data | 6 | Governance panels expect data not in mock corpus |
| History narrative contract | 7 | Story modes expect different narrative structure |
| Map state/selection | 6 | Workspace page and surface state tests expect different state shape |
| Shell/router | 3 | App shell smoke test, deep link fallback |
| Operate inspector | 4 | Task detail inspector expects different inspection model |
| Other | 9 | Overview provider, graph models, diagnostics, catalog |

---

## 5. Priority Matrix

### Blocks package gate (must fix before promoting to 03-review)

| Area | Failures | Tasks that should fix |
|------|----------|----------------------|
| Gallery compile | 7 | Task 1304 (Gallery Compile Boundary Cleanup) |
| Molecules contract | 8 | Task 1303 (Component Contract Reconciliation) |
| Templates contract | 3 | Task 1303 |
| Accessibility/Semantics | 3 | Task 1307 (Accessibility & Semantics Reconciliation) |
| State vocabulary | 1 | Task 1309 (State Vocabulary Surface Reconciliation) |
| Op components | 1 | Task 1303 |
| Atoms contract | 1 | Task 1303 |

### Informational (pre-existing, blocks promotion but not gate)

| Area | Failures | Tasks that should fix |
|------|----------|----------------------|
| All Observatory | 64 | EPIC-14 tasks (1401-1408) |

---

## 6. Toast Fix (Task 1308) — Applied

7 toast test failures were fixed by Task 1308:
- 6 overlay tests: `RenderBox was not laid out` → fixed height constraint
- 1 semantics test: composite label mismatch → `ExcludeSemantics` wrapper

**Before toast fix**: 31 UI failures → **After**: 24 UI failures.

---

## 7. Test Commands Reference

```bash
# Full monorepo
melos run validate

# Per package
melos run test-ui
melos run test-observatory
melos run test-cybercore
melos run test-catalog
melos run test-fast  # UI + CyberCore only

# Single file
cd packages/warp_prism_ui && flutter test test/molecules/ds_toast_test.dart
```
