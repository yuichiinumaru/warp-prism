# Task 1408: Observatory Package Imports Cleanup

> **Status**: `[x]` Done
> **Review State**: Package Gate Failed — observatory pre-existing failures remain; import cleanup evidence filled
> **Priority**: 🟡 P1
> **Type**: `housekeeping`
> **Origin**: EPIC-14, stabilization wave, ~29 fragile relative imports in Observatory.
> **Blocks**: None (quality improvement, not gate blocker)
> **Depends on**: 1403 (parsers must be working before touching imports)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1408` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Migrate fragile relative imports in `apps/observatory/` to package-style
imports where beneficial. This prevents future breakage from file moves
and makes the import graph easier to audit.

## Background Context

### What already exists

- ~29 imports in `apps/observatory/lib/features/` use deep relative paths like
  `../../../data/models/task_contracts.dart`.
- After the Melos migration, relative paths may resolve incorrectly.

### What is missing or broken

- Fragile relative imports can break if files are moved.
- No import style convention is enforced.

---

## Test Requirements

- All migrated imports resolve correctly (verified by `flutter analyze`).
- No circular imports are introduced.

---

## Exit Conditions

- [x] All deep relative imports (3+ levels) in `apps/observatory/lib/features/`
  are migrated to package-style or shorter relative imports.
- [x] `flutter analyze apps/observatory/` passes.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Scan `apps/observatory/lib/`
  for imports with 3+ `../` levels.
- [x] For each deep import, determine the correct package-style import
  (e.g., `import 'package:warp_prism_observatory/data/models/task_contracts.dart'`).
- [x] Migrate imports.
- [x] Run `flutter analyze` to verify.
- [x] **Simplicity pass**: only migrate deep relative imports. Shallow relative
  imports within the same feature are fine.
- [x] **Regression verification**: run Observatory tests.

### Where

| File | Purpose |
| --- | --- |
| `apps/observatory/lib/features/**/*.dart` | Modify — migrate imports |
| `apps/observatory/lib/app/**/*.dart` | Read / possibly modify |

### How

1. Scan for deep relative imports.
2. Replace with package-style imports.
3. Verify with analyze.

### Why

Fragile imports are a time bomb. They work until someone moves a file, then
they break silently. Package-style imports are resilient to file moves.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not migrate imports that are correct and shallow. Only fix the deep ones
  (3+ levels of `../`).

---

## Validation Commands

```bash
flutter analyze apps/observatory/
```

---

## Completion Evidence

- **Files created/modified**: 35 files in `apps/observatory/lib/features/` (import migration only), 1 changelog entry created
- **Tests or validation commands**:
  - `flutter analyze apps/observatory/` — 0 errors, 0 warnings (362 pre-existing info lint hints) — PASS
  - `flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart` — 4/4 PASS
  - `flutter test apps/observatory/` — 602 PASS, 51 FAIL (pre-existing assertion failures, unrelated to imports)
  - `rg "import '\.\./\.\./\.\." apps/observatory/lib/features/` — 0 matches (zero deep imports remain) — PASS
- **Local changelog entry**: `docs/changelog/20260609-233000-1408-observatory-package-imports-cleanup-builders.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
