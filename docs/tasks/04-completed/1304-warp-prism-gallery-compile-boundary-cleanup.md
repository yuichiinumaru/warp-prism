# Task 1304: Gallery Compile Boundary Cleanup

> **Status**: `[x]` Builder Done
> **Review State**: Held In Review — residual F6/F7 closed (2026-07-10); ready for re-score; remain `03-review/`
> **Priority**: 🔴 P0
> **Type**: `remediation`
> **Origin**: EPIC-13, stabilization wave, `design_system_gallery_sections.dart`
>   has ~200 compilation errors from components added out-of-order.
> **Blocks**: 1305, all package-level test gates
> **Depends on**: 1303 (contract reconciliation)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1304` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Fix compilation errors in `design_system_gallery_sections.dart` so the gallery
compiles, all registered sections render, and `flutter test` and `flutter analyze`
are no longer blocked by gallery errors.

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  references components from multiple waves (data table, command palette, log
  viewer, split pane, tab bar, virtual scroll, code block, markdown renderer,
  graph refactor) that were added out of order.
- The file has ~200 compilation errors blocking `flutter test` and
  `flutter analyze` at the package level.

### What is missing or broken

- Gallery sections reference types that do not exist or have changed signatures.
- The gallery is the ADS "storefront" — if it does not compile, the ADS has
  no proof surface.

---

## Test Requirements

- `design_system_gallery_sections.dart` compiles without errors.
- `design_system_gallery_test.dart` passes.
- `flutter analyze` in the package passes.

---

## Exit Conditions

- [x] `flutter analyze packages/warp_prism_ui/` passes with zero errors.
- [x] `design_system_gallery_test.dart` passes.
- [x] All gallery sections compile and render without crash.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  and all component files it references.
- [x] Identify every compilation error in the gallery file.
- [x] For each error: fix the reference (update type name, add missing import,
  fix parameter mismatch) or comment out the section with a `// TODO(Task NNNN)`
  if the component does not exist yet.
- [x] Run `flutter analyze` and verify zero errors.
- [x] Run `design_system_gallery_test.dart` and verify pass.
- [x] **Simplicity pass**: fix references, do not redesign gallery structure.
- [x] **Regression verification**: run gallery-scoped tests.
- [x] **Path-to-100 cleanup (2026-07-09)**: clear analyzer infos/warnings,
  replace deprecated `withOpacity`, remove secret-shaped demo value, mount-guard
  tab controller listeners.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — fix compilation errors + path-to-100 debt |
| `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` | Read / Modify — fix test expectations |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Read — page structure |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Read — section registry |

### How

1. Read the gallery sections file and catalog all compilation errors.
2. Fix each error by updating references to match current component APIs.
3. For components that do not exist yet, add `// TODO` stubs.
4. Run analyze and test.
5. Clear remaining gallery analyzer debt and review path-to-100 items.

### Why

The gallery is the ADS proof surface. If it does not compile, the ADS cannot
demonstrate its own components. Every package-level test gate is blocked by
this file. Fixing it unblocks the entire stabilization wave.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not delete gallery sections. If a component does not exist, comment out
> the section with a TODO and a reference to the relevant task.

> [!IMPORTANT]
> This task fixes compilation. It does NOT add new gallery sections. New sections
> are part of EPIC-13 task 1305 (Catalog Contract Expansion).

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze --format=machine lib/src/gallery/
flutter test --concurrency=1 --no-pub test/gallery/design_system_gallery_test.dart
dart format --set-exit-if-changed lib/src/gallery/
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
    - Applied `dart fix --apply` on gallery (142 fixes): const constructors,
      const literals, deprecated `withOpacity` → `withValues(alpha:)`, unused
      templates import removed.
    - Replaced secret-shaped demo value `sk-1234567890abcdef` with
      `demo-secret-value-abc1`.
    - Mount-guarded DSTabController listeners (`if (!mounted) return`) and
      removeListener on dispose for `_TabBarDemo` and `_TabBarOverflowDemo`.
    - Mount-guarded drag board `_handleReorder` / `_handleMove` setState paths.
  - `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` —
    earlier overflow/scroll fixes retained (no new test edits this pass).
- **Tests or validation commands** (2026-07-09, scoped safe):
  - `dart analyze --format=machine lib/src/gallery/` → **0 issues** (EXIT 0)
  - `flutter test --concurrency=1 --no-pub test/gallery/design_system_gallery_test.dart`
    → **13/13 passed**
  - `dart format --set-exit-if-changed lib/src/gallery/` → **0 files changed**
    after format pass
  - `rg "withOpacity|sk-[a-zA-Z0-9]{8,}" lib/src/gallery/` → clean
- **Local changelog entry**:
  - Historical: `docs/changelog/2026-06-09-task-1304-gallery-boundary-cleanup.md`
  - This pass: `docs/changelog/2026-07-09-task-1304-gallery-compile-boundary-path-to-100.md`
- **Agent-wiki / docs institutionalization**:
  - builders continuity entry for this handoff
- **Executor**: builders
- **Completion date**: 2026-07-09
- **Self-score**: 100/100 (task scope: gallery compile boundary + path-to-100
  debt cleared; scoped gates green)

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-09
- **Reviewer profile**: `reviewers`
- **Score**: `95/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-09/task-1304-gallery-compile-boundary-independent-rereview.md`
- **Lane outcome**: remains in `03-review` (S≥90; reviewer never moves to `04-completed/`)
- **Task reference**: Task 1304 (`warp-prism-gallery-compile-boundary-cleanup`)

#### Current Open Blockers

- ~~`REGRESSION` (LOW): gallery package tests still import `src/gallery/...`~~ — **CLOSED 2026-07-10**
- ~~`EVIDENCE_GAP` (LOW–MODERATE): package gallery suite does not prove all **10** registry sections~~ — **CLOSED 2026-07-10**

#### Path-to-100 Summary (closed)

1. ~~Add registry-driven all-10 section render test~~ — done (`renders all 10 registry section titles` + independent builders).
2. ~~Prefer public barrel only~~ — done (single `warp_prism_ui` import; `PrismGallerySections`).
3. ~~Re-run gallery analyze / gallery tests / format~~ — done.

### 2026-07-10 residual closure (gt-flutter-engineer)

| Field | Value |
| --- | --- |
| **Residual batch** | Gallery registry section coverage + public-only imports |
| **Lane** | remain `docs/tasks/03-review/` |
| **ready_for_reviewer** | **yes** |

#### Closed residuals

| ID | Residual | Fix |
| --- | --- | --- |
| F6 | `src/` dual imports in package gallery tests | Public barrel only; `PrismGallerySections` group |
| F7 | Not all 10 registry sections proven in package suite | Scroll all titles + per-builder independent render + ID uniqueness |

#### Live gates

| Command | Result |
| --- | --- |
| `dart analyze --format=machine lib/src/gallery/ test/gallery/` | **0** issues, EXIT **0** |
| `flutter test --concurrency=1 --no-pub test/gallery/design_system_gallery_test.dart` | **16/16 PASS** (was 13) |
| `dart format --set-exit-if-changed --output=none test/gallery/` | **0** changed |

#### Files touched

- `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart`
- `docs/changelog/2026-07-10-task-1304-gallery-registry-section-coverage.md`

### Previous Reports

- `2026-07-09` — builders path-to-100 handoff (self-score 100; not independent)
  - **Resolved since Wave 1**: analyzer 296→0; withOpacity; secret placeholder; tab mount-guards
- `2026-06-13` — `62/100` — `docs/reports/review-wave-1/1304-review.md`
  - **Carried forward then**: analyzer integrity fail; tab listeners; secret-shaped value
  - **Resolved since**: F1/F2/F3/F4 closed on live FS this re-review
  - **Regression guard**: keep gallery analyzer at 0 infos; keep tab removeListener+mounted; no `sk-` demo secrets
- `2026-06-12` — `100/100` — `docs/reports/build-gate-review/1304-review.md`
  - **Note**: prior Perfect not reproducible at Wave 1; public-only test import claim still not fully true (F6)

- **2026-06-29 (reviewers / Wave 1)**: Score 62/100 — Package Gate Failed.
  Path-to-100: const cleanup, withOpacity→withValues, non-secret demo value,
  mounted guards on tab listeners.
- **2026-07-09 (builders)**: Path-to-100 applied. Gallery analyzer 0 issues,
  gallery tests 13/13, format clean. Promoted to Ready For Review / 03-review.

(End of file)


---

### 2026-07-17 — drain independent re-review (reviewers)
- **Score**: `96/100`
- **Verdict**: `ACCEPTED_PATH_TO_100` → **Promoted** to `docs/tasks/04-completed/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1304-drain-review.md`
- **Prior**: 95/100 (draft; revalidated live)
- **Top residual / path-to-100**: Gallery analyze 0 + tests +21; package-wide INFO external residual
- **Lane outcome**: `04-completed/`

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: none code — package-wide INFO remains EXTERNAL (out of gallery scope). Live gates already green (gallery analyze 0, gallery tests expanded).
**Remaining**: optional package lint burn-down only (external).



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1304-path100-rereview.md` |
| **Top finding** | None task-scope (package-wide INFO external) |
| **Exits** | gallery analyze 0; gallery +22 PASS; public barrel; format clean |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
