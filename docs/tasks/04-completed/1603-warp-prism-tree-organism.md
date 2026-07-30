# Task 1603: PrismTree Organism

> **Status**: `[x]` Ready For Review
> **Review State**: `Ready For Review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft until registration wave)
> **Depends on**: Task 1600

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1603` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement **`PrismTree`** — hierarchical tree organism with expand/collapse, selection, optional status/meta per node, and keyboard-friendly focus. Public `Prism*` + internal `DS*` + alias; minimal gallery case; fixture-first.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismTree` |
| **Internal implementation (preferred)** | `DSTree` + `typedef PrismTree = DSTree` in `prism_aliases.dart` |
| **Harvest organism ID** | **C-02** |
| **Origin** | OmniRoute visual-ref tree (status/meta/selection) |
| **Wave** | **J** (Content chrome) |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore namespace/capability trees; agent workspace side panels |
| **ADS-first rule** | Gallery + fixtures only |

### What already exists

- Sidebar navigation lists (`ds_sidebar.dart`) — not a hierarchical tree widget.
- Status dots, badges, glass panels, interactive surface molecule.
- Virtual scroll organism (optional compose for large trees later — not required MVP).

### What is missing or broken

- No hierarchical tree organism with selection + status/meta.
- No fixture tree gallery for ADS demos.

### False-gap notes (do not re-implement)

- Do **not** reimplement `DSSidebar` as a tree; tree is a content control, sidebar is app chrome.
- Do **not** pull in third-party tree packages that break Flutter-only UI package purity without strong need (prefer pure Flutter).
- Do **not** port Recharts/MapLibre or rebrand teal.

### Composition notes

- Tree node row (indent, caret, label, status, meta).
- Optional selection left rail using existing cyan wash pattern (`accentCyan` alpha) — not OmniRoute `#00FFCC` hardcode.

---

## Test Requirements

- MUST render multi-level fixture nodes; expand/collapse toggles children visibility.
- MUST support selection callback (`onNodeSelected`) and selected visual state.
- MUST support optional status (operational state / status dot) and meta trailing text.
- Widget tests: expand, collapse, select, empty tree, deep nesting (≥3 levels).
- A11y: selected node announced; expand controls focusable.
- Minimal gallery fixture tree (e.g. providers → accounts → models).

---

## Exit Conditions

- [x] `PrismTree` exported (alias + organisms barrel).
- [x] Widget tests + minimal gallery case PASS.
- [x] No third-party heavy tree deps that violate package purity without documentation.
- [x] `dart analyze` + scoped tests PASS; boundaries **6/6** after barrel/alias touch.
- [x] Local changelog entry under `docs/changelog/`.
- [x] Completion Evidence filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session + OmniRoute visual-ref reports, Task 1600 brief if present, `packages/warp_prism_ui/lib/src/organisms/ds_sidebar.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_status_dot.dart`, `packages/warp_prism_ui/lib/src/molecules/ds_interactive_surface.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`.
- [x] Define tree node model (id, label, children, status, meta, expandable).
- [x] Implement `DSTree` + selection/expand state (controller or callback-driven expansion).
- [x] Wire exports + `PrismTree` alias.
- [x] Tests + minimal gallery case.
- [x] **Simplicity pass**: MVP hierarchy only; no drag-reorder, no virtualization unless trivial.
- [x] **Regression verification**: validation commands + boundaries.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/tree/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/tree/ds_tree.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/tree/ds_tree_node.dart` | Create — node model (if separate) |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — minimal gallery |
| `packages/warp_prism_ui/test/organisms/tree/` | Create — tests |
| `docs/changelog/` | Create — changelog note |

### How

1. Model nodes immutably; expansion may be controlled or uncontrolled with clear docs.
2. Indent by depth using `DSSpacing`; selection wash via existing cyan tokens.
3. Export/test/gallery; run boundaries.

### Why

Hierarchical navigation (namespaces, MCP tools, provider trees) is a repeated CyberCore pattern and OmniRoute GOLD harvest; missing from current ADS.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete without tests + Completion Evidence. Do not hardcode
> OmniRoute `#00FFCC` as Observatory default accent.

> [!IMPORTANT]
> Package purity: no routing/prefs/riverpod in `warp_prism_ui`. Fixture data only
> in gallery. No MapLibre/Recharts/Widgetbook.

> [!WARNING]
> ADS-first delivery. Do not rewrite product routes. Parallel with 1602 is OK.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/tree/

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/tree/ds_tree_node.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/tree/ds_tree.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/tree/tree.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (`PrismTree`, `PrismTreeNode`)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (minimal fixture)
  - Created `packages/warp_prism_ui/test/organisms/tree/ds_tree_test.dart`
  - Created `docs/changelog/2026-07-10-task-1603-tree-organism.md`
- **Public API name verified**: `PrismTree` / `PrismTreeNode` via `package:warp_prism_ui/warp_prism_ui.dart` (`typedef PrismTree = DSTree`)
- **Tests or validation commands**:
  - `dart analyze` scoped tree/alias/gallery: **No issues found**
  - `dart analyze lib test`: exit 0 (pre-existing infos only; no errors from this task)
  - `flutter test test/organisms/tree/`: **14/14 PASS** (includes Arrow Up/Down roving focus test; path-to-100 2026-07-18)
- **Boundary harness**: **7/7 PASS** (`dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .`)
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1603-tree-organism.md`
- **Agent-wiki / docs institutionalization**: N/A (organism implementation; pattern follows page_shell EPIC-16 wave)
- **Executor**: gt-flutter-engineer (builder worker under parent builders)
- **Completion date**: 2026-07-10
- **Residuals (closed 2026-07-18)**:
  - Arrow Up/Down roving focus across flattened visible rows **implemented** + widget-tested.
  - Non-virtualized `Column` retained as intentional MVP (task: "no virtualization unless trivial").

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `reviewers` (independent; parent agentID=reviewers; Batch R6)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review-wave-2026-07-18/task-1603-path100-rereview.md`
- **Lane outcome**: → `docs/tasks/04-completed/`
- **Task reference**: Task 1603
- **Live prove**: tree **14/14 PASS** (incl. roving); format clean; analyze clean; boundaries **7/7 PASS**
- **Delta**: R1 roving **RESOLVED**; F1 format **RESOLVED**; I1 Column MVP **SUPERSEDED** (out of MVP scope)

#### Current Open Blockers

- None.

#### Path-to-100 Summary

- Applied (builder batch6 + this re-review): Arrow Up/Down roving + format + CE residual refresh.

### Previous Reports

- `docs/reports/review-wave-2026-07-17/task-1603-drain-review.md` — drain 92/100 (roving residual)
- `docs/reports/review/1603-tree-independent-rereview-2026-07-16.md` — S=94
- `docs/reports/review-wave-2026-07-11/task-1603-independent-review.md` — initial S=94

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` (or `dart run melos run test-boundaries`) after public DS/Prism surface changes — must stay **7/7 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.
- Guard: Arrow Up/Down roving focus test must remain green.

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 92/100 |
| **Verdict** | PASS path-to-100 residual |
| **Lane** | was 03-review (ledger claimed 04; path-to-100 re-review promotes for real) |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1603-drain-review.md` |
| **Top finding** | No Arrow Up/Down roving focus (now RESOLVED 2026-07-18) |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |


---

## Review Ledger — 2026-07-18 Path-to-100 Re-review (Batch R6)

| Field | Value |
| --- | --- |
| **Date** | 2026-07-18 |
| **Reviewer** | independent `reviewers` (parent agentID=reviewers) |
| **Harnesses** | code-quality-harness + flutter-harness |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_100 |
| **Path-to-100 applied** | YES |
| **Lane** | → `04-completed/` |
| **Full report** | `docs/reports/review-wave-2026-07-18/task-1603-path100-rereview.md` |
| **Top finding** | none — Arrow Up/Down roving + format closed |
| **Exits** | PASS |
| **Live gates** | format 0; analyze 0; organism/gallery/goldens PASS; boundaries 7/7 |

