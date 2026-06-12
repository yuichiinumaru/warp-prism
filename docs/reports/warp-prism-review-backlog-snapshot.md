# Review Backlog Snapshot — Warp Prism Task Lane Reconciliation

> **Generated**: 2026-06-09
> **Authority**: Task 1208 (Existing Task Lane Reconciliation)
> **Scope**: All tasks in `docs/tasks/02-doing/` as of snapshot date
> **Total tasks classified**: 92

This report classifies every task in `docs/tasks/02-doing/` using the promotion
state model defined in `docs/governance/promotion-state-model.md` (Task 1202).
It replaces the previous ambiguous `[x] Done` with a formal state that tells
the project exactly where each task stands.

---

## 1. Summary Table

| Promotion State | Count | % of Total | Can Move to 03-review? |
|----------------|------:|-----------:|:----------------------:|
| **Ready For Review** | 1 | 1.1% | Yes |
| **Builder Done** | 23 | 25.0% | Not yet (needs gate verification) |
| **Package Gate Failed** | 15 | 16.3% | No (gate must pass first) |
| **Blocked** | 46 | 50.0% | No (external dependency) |
| **Open** | 6 | 6.5% | No (not started) |
| **In Progress** | 1 | 1.1% | No (actively working) |
| **Total** | **92** | **100%** | — |

### Key Finding

**50% of the backlog (46 tasks) is blocked by the missing Flutter SDK.** This
is the single largest obstacle to project progress. Until Flutter tooling is
available in the execution environment, no task that requires `flutter analyze`,
`flutter test`, or `dart format` can be verified or promoted.

---

## 2. Tasks by Classification

### 2.1. Ready For Review (1 task)

These tasks have filled completion evidence and all validation passes. They are
candidates for immediate reviewer pickup.

| Task | Title | Evidence |
|------|-------|----------|
| 1308 | Toast Async Lifecycle Stabilization | 33/33 tests pass, analyze clean, 3x reproducible |

### 2.2. Builder Done (23 tasks)

Implementation is claimed complete, but gate verification is missing or
inconsistent. These need `flutter analyze` + `flutter test` before they can
move to Ready For Review.

#### Subcategory: Status marker inconsistent with evidence (7)

These tasks have `[ ]` Open status but contain real completion evidence. The
status marker was never updated when work was completed.

| Task | Title | Notes |
|------|-------|-------|
| 1104 | Melos Monorepo Architecture Plan | 661-line deliverable created |
| 1105 | Token Theme Catalog Policy | 655-line policy doc created |
| 1108 | CyberCore Frontend Scope Route Parity | Design doc + changelog |
| 1109 | CyberCore API Data Contract Inventory | 2 docs + changelog |
| 1110 | CyberCore Fixture-Backed App Shell MVP | Full app shell implementation |
| 1111 | CyberCore Pilot Mirror Expansion Gate | 2 design docs |
| 1206 | Pre-existing Failure Classification Policy | 142-line policy doc |

#### Subcategory: Completion evidence filled; gate verification pending (2)

| Task | Title | Notes |
|------|-------|-------|
| 1204 | Melos Test Script Normalization | Melos scripts verified; pre-existing issues noted |
| 1301 | Prism Namespace Remediation | Full cybercore DS→Prism migration verified via `rg` |

#### Subcategory: Completion evidence filled; no gate verification recorded (2)

| Task | Title | Notes |
|------|-------|-------|
| 0019 | Preset Workspace Snapshot Starter | Full feature implementation; Flutter SDK blocked |
| 0020 | Enhanced Workspace Snapshot Search/Detail/Graph | Full feature implementation; Flutter SDK blocked |

#### Subcategory: Docs/governance deliverable complete (3)

| Task | Title | Notes |
|------|-------|-------|
| 1000 | Polish Baseline Audit | Audit deliverable |
| 1060 | Epic 10 Acceptance Audit | Acceptance criteria report |
| 1102 | Control Surface Inventory | Inventory deliverable |

#### Subcategory: Implementation evidence missing; needs verification (4)

| Task | Title | Notes |
|------|-------|-------|
| 0001 | Mock Workspace Contract Baseline | Status `[x]` but no completion evidence |
| 0004 | Task Lane Markdown Corpus | Status `[x]` but no completion evidence |
| 0005 | Changelog Markdown Corpus | Status `[x]` but no completion evidence |
| 0613 | Operate Review Blocker Storytelling | Status `[x]` but no completion evidence |

#### Subcategory: Already annotated by Task 1202 (4)

| Task | Title | Notes |
|------|-------|-------|
| 0011 | Bootstrap Main Router Shell | Verified by prior annotation |
| 0312 | Read-Only Mock Workspace Repository | Verified by prior annotation |
| 0510 | Map Workspace Scaffold | Verified by prior annotation |
| 1202 | Promotion State Model Definition | Completed and verified |

#### Subcategory: Completion evidence template-only (1)

| Task | Title | Notes |
|------|-------|-------|
| 1203 | Test Gate Matrix per Task Type | Status `[x] Builder Done` but evidence section is template |

### 2.3. Package Gate Failed (15 tasks)

Implementation is complete with filled evidence, but the package-level gate
(`flutter analyze`, `flutter test`) fails due to pre-existing issues in the
codebase — primarily `design_system_gallery_sections.dart` compilation errors
from incomplete cross-task integration.

| Task | Title | Gate Blocker |
|------|-------|-------------|
| 1106 | Operational Component MVP | Pre-existing gallery compile errors (DSHealthCardData, DSStatusGrid) |
| 1107 | Melos Monorepo Migration | Melos/Flutter tooling unavailable |
| 1112 | Data Table Component | Pre-existing gallery compile errors |
| 1113 | Command Palette | Pre-existing gallery compile errors (DSCommand* types) |
| 1114 | Log Viewer Component | Pre-existing gallery compile errors |
| 1115 | Loading Skeleton Error Boundary | Pre-existing gallery compile errors |
| 1116 | Notification Toast System | Pre-existing gallery compile errors |
| 1117 | Graph Visualization Refactor | Pre-existing gallery compile errors |
| 1118 | Operational State Vocabulary Expansion | Pre-existing gallery compile errors |
| 1119 | Health Dashboard Components | Pre-existing gallery compile errors |
| 1120 | Drag and Drop Task Board | Pre-existing gallery compile errors |
| 1121 | Code Block and Markdown Renderer | Pre-existing gallery compile errors |
| 1122 | Tab Bar and Split Pane | Pre-existing gallery compile errors |
| 1123 | Virtual Scroll Optimization | Pre-existing gallery compile errors |
| 1126 | README Monorepo Reality Alignment | Changelog validate pre-existing issue |

**Root cause**: `design_system_gallery_sections.dart` references types
(DSDataTable, DSLogViewer, DSErrorBoundary, DSCommandPalette, DSTabBar,
DSSplitPane, DSHealthCardData, DSStatusGrid) that were added to the gallery
before their implementations were merged. This creates a transitive compilation
failure that blocks `flutter test` for any test that imports the barrel.

**Resolution**: Task 1201 (failure baseline inventory) or a targeted gallery
fix task that removes or stubs the broken references.

### 2.4. Blocked — Flutter SDK Not Installed (46 tasks)

These tasks cannot be verified because the Flutter SDK is not available in the
execution environment. All validation commands (`flutter analyze`, `flutter test`,
`dart format`) fail with "Flutter SDK not installed."

| Wave | Tasks | Count |
|------|-------|------:|
| 00xx (Mock corpus) | 0002, 0003, 0006 | 3 |
| 00xx (Foundation/DS) | 0010, 0012, 0013, 0014, 0015, 0016, 0017, 0018 | 8 |
| 03xx (Data layer) | 0310, 0311, 0313, 0314, 0315 | 5 |
| 04xx (App shell) | 0410, 0411, 0412, 0413 | 4 |
| 05xx (Map) | 0511, 0512, 0513, 0514 | 4 |
| 06xx (Operate) | 0610, 0611, 0612 | 3 |
| 07xx (History) | 0710, 0711, 0712, 0713 | 4 |
| 08xx (Governance) | 0810, 0811, 0812, 0813 | 4 |
| 09xx (Asset detail) | 0901, 0902, 0903, 0904, 0905 | 5 |
| 10xx (Polish) | 1010, 1020, 1030, 1040, 1050, 1070 | 6 |
| **Total** | | **46** |

**Resolution path**: Install Flutter SDK in the execution environment, then
re-run validation commands per task. These tasks may transition to Builder Done
(if validation passes) or Package Gate Failed (if tests fail).

### 2.5. Open — Lane Mismatch (6 tasks)

These tasks have `[ ]` Open status and are genuinely unstarted, but they sit
in `02-doing/` instead of `01-open/`. This is a lane violation.

| Task | Title |
|------|-------|
| 1101 | Charter and Naming Convergence |
| 1201 | Test Failure Baseline Inventory |
| 1205 | Boundary Test Harness |
| 1302 | Public Barrel Audit |
| 1303 | Component Contract Reconciliation |
| 1401 | Observatory Failure Baseline Inventory |

### 2.6. In Progress (1 task)

| Task | Title | Notes |
|------|-------|-------|
| 1208 | Existing Task Lane Reconciliation | Current task being executed |

---

## 3. Wave Analysis

### Wave 1-3 (0001-0020, 0310-0315): Foundation and Data Layer

- **Status**: All claimed `[x]` Done
- **Reality**: 15 have no completion evidence; 5 have evidence but no gate verification
- **Blocker**: Flutter SDK for most; no evidence for the rest
- **Risk**: Implementation may exist but cannot be verified without SDK

### Wave 4 (0410-0413): App Shell

- **Status**: All claimed `[x]` Done
- **Reality**: All 4 blocked by Flutter SDK
- **Blocker**: No completion evidence, no gate verification
- **Risk**: High — app shell is foundational; if broken, everything downstream fails

### Wave 5-9 (0510-0905): Feature Surfaces

- **Status**: All claimed `[x]` Done
- **Reality**: 2 Builder Done (0510, 0613), rest Blocked
- **Blocker**: Flutter SDK
- **Risk**: Medium — these are feature implementations that may work but can't be verified

### Wave 10 (1000-1070): Polish and Audit

- **Status**: All claimed `[x]` Done
- **Reality**: 3 Builder Done (1000, 1060, docs), rest Blocked
- **Blocker**: Flutter SDK
- **Risk**: Low for docs tasks, Medium for code tasks

### Wave 11 (1101-1126): ADS Components and CyberCore

- **Status**: Mixed — some `[x]`, some `[ ]` Open, some `[/]`
- **Reality**: 15 Package Gate Failed, 7 Builder Done, 1 Open (1101)
- **Blocker**: Pre-existing gallery compilation errors
- **Risk**: High — this wave produced the most code but also the most gate failures
- **Note**: Tasks 1104, 1105, 1108, 1109, 1110, 1111 have real evidence but stale status markers

### Wave 12 (1201-1208): Stabilization and Governance

- **Status**: Mixed — some `[ ]` Open, some `[/]`, some `[x]`
- **Reality**: 3 Builder Done, 2 Open, 1 In Progress
- **Blocker**: Dependencies on each other (1201→1202→1203→1206→1207)
- **Risk**: Low — governance tasks with clear deliverables

### Wave 13 (1301-1308): Namespace and Contract Fixes

- **Status**: Mixed
- **Reality**: 2 Builder Done, 2 Open, 1 Ready For Review
- **Blocker**: Dependencies on earlier waves
- **Risk**: Low — remediation tasks

### Wave 14 (1401): Observatory

- **Status**: `[ ]` Open
- **Reality**: Open, lane mismatch
- **Risk**: Low — future work

---

## 4. Priority Order for Remediation

### Priority 0 — Immediate (unblock the project)

1. **Install Flutter SDK** in the execution environment. This unblocks 46 tasks
   (50% of the backlog) and enables gate verification for 23 Builder Done tasks.
2. **Fix `design_system_gallery_sections.dart`** compilation errors. This is the
   root cause of 14 Package Gate Failed tasks. Either remove broken references
   or ensure all referenced types are implemented.

### Priority 1 — Short-term (clean up governance)

3. **Fix lane mismatches**: Move 6 Open tasks from `02-doing/` to `01-open/`.
4. **Fix status markers**: Update 7 tasks (1104, 1105, 1108, 1109, 1110, 1111,
   1206) from `[ ]` Open to `[x]` since they have real completion evidence.
5. **Run gate verification** for 23 Builder Done tasks once Flutter SDK is
   available. Tasks that pass move to Ready For Review.

### Priority 2 — Medium-term (clear the Package Gate Failed backlog)

6. **Run full package gate** for the 15 Package Gate Failed tasks after fixing
   gallery compilation errors. Tasks that pass move to Ready For Review.
7. **Complete unstarted governance tasks** (1201, 1203, 1205, 1302, 1303, 1401)
   — these are the stabilization backbone.

### Priority 3 — Long-term (review pipeline)

8. **Reviewer pickup**: Task 1308 is the only Ready For Review task. Establish
   a review cadence.
9. **Target 5+ tasks in 03-review/** within one week of Flutter SDK availability.

---

## 5. Anomalies Found

### Status Marker Inconsistencies

| Task | File Status | Actual State | Issue |
|------|-------------|-------------|-------|
| 1104 | `[ ]` Open | Builder Done | Evidence exists but status not updated |
| 1105 | `[x]` Done — awaiting review | Builder Done | Different format but correct intent |
| 1108 | `[x]` Completed | Builder Done | Evidence exists |
| 1109 | `[ ]` Open | Builder Done | Evidence exists but status not updated |
| 1110 | `[ ]` Open | Builder Done | Evidence exists but status not updated |
| 1111 | `[ ]` Open | Builder Done | Evidence exists but status not updated |
| 1203 | `[x]` Builder Done | Builder Done | Evidence template-only |
| 1206 | `[ ]` Open | Builder Done | Evidence exists but status not updated |

### Missing Completion Evidence

8 tasks (0001, 0004, 0005, 0613, 1000, 1060, 1102, 1203) have `[x]` Done
status but their Completion Evidence section contains only the template
placeholders (`[list]`, `[commands and PASS/FAIL]`, `[path]`, etc.). These tasks
may have been completed but the evidence was never recorded.

### Cross-Task Gallery Compilation Failure

14 tasks from Wave 11 reference types in `design_system_gallery_sections.dart`
that were added before their implementations were merged. This is a systemic
integration failure — the gallery file is a shared surface that accumulates
references from multiple tasks, and no gate catches broken references until
all dependent tasks are merged.

---

## 6. Validation Commands

```bash
# Verify snapshot count matches 02-doing/ file count
ls docs/tasks/02-doing/*.md | wc -l
# Expected: 92

# Verify all tasks have Review State
grep -l "Review State" docs/tasks/02-doing/*.md | wc -l
# Expected: 92

# Verify no header-level duplicate Review State
for f in docs/tasks/02-doing/*.md; do
  count=$(head -15 "$f" | grep -c "Review State")
  [ "$count" -gt 1 ] && echo "DUPLICATE: $(basename $f)"
done
# Expected: no output
```

---

## 7. References

- **Promotion state model**: `docs/governance/promotion-state-model.md`
- **Task template**: `docs/tasks/000-template.md`
- **This task**: `docs/tasks/02-doing/1208-warp-prism-existing-task-lane-reconciliation.md`
