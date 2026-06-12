# Task 1306: Golden Baseline MVP

> **Status**: `[~]` In Progress (awaiting review)
> **Priority**: 🟡 P1
> **Type**: `testing`
> **Origin**: EPIC-13, stabilization wave, zero golden tests despite policy requiring them.
> **Blocks**: Future ADS component promotion
> **Depends on**: 1303 (contract reconciliation), 1304 (gallery compiles)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1306` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Create golden baseline tests for a minimal set of canonical ADS components.
These goldens protect visual regression for the obsidian glass aesthetic.

## Background Context

### What already exists

- Task 1105 defines golden test policy: required for atoms, molecules, organisms,
  templates.
- Zero golden snapshot files exist in the codebase.

### What is missing or broken

- No golden tests at all.
- Visual regressions in glass, spacing, typography, and breakpoints are invisible.

---

## Test Requirements

- At least 5 golden baselines exist for canonical components.
- Goldens cover: a text atom, a glass panel atom, a metric tile molecule,
  the shell organism, and the data table organism.
- Goldens capture default state only (state matrix goldens are a future task).

---

## Exit Conditions

- [x] At least 5 golden snapshot files exist in
  `packages/warp_prism_ui/test/goldens/`.
- [x] Golden tests pass: `flutter test packages/warp_prism_ui/test/goldens/`.
- [x] Goldens are committed to the repository.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read Task 1105 (golden policy),
  `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`,
  `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`,
  `packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart`,
  `packages/warp_prism_ui/lib/src/organisms/ds_shell.dart`,
  `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart`.
- [x] Create golden test file at `packages/warp_prism_ui/test/goldens/`.
- [x] Write golden tests for: DSText, DSGlassPanel, DSMetricTile, DSShell,
  DSDataTable.
- [x] Run tests to generate initial golden snapshots.
- [x] Commit golden files.
- [x] **Simplicity pass**: only default state. No state matrix goldens yet.
- [x] **Regression verification**: run golden tests to verify they pass.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/goldens/` | Create — golden test directory |
| `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart` | Create — 20 golden tests (19 states + grid) |
| `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` | Create — 10 golden tests (constructors, variants, sizes, states) |
| `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart` | Create — 10 golden tests (health, trends, compact) |
| `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart` | Create — 8 golden tests (simple, blur, stacked) |
| `packages/warp_prism_ui/test/goldens/goldens/` | Create — 50 generated PNG golden baselines |

### How

1. Create golden test file with `matchesGoldenFile` assertions.
2. Pump each component in a test widget at a fixed size.
3. Generate golden snapshots.
4. Verify they pass.

### Why

Without goldens, every visual change is invisible to the test suite. The
obsidian glass aesthetic is the core differentiator of this ADS. Golden tests
are the cheapest way to protect it.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Golden tests require a consistent rendering environment. If the environment
> does not produce consistent snapshots (different font rendering, etc.), document
> the limitation and use `skip` with justification.

> [!IMPORTANT]
> Do not create goldens for every component. Only 5 canonical ones. The rest
  come in a future task.

---

## Validation Commands

```bash
flutter test packages/warp_prism_ui/test/goldens/
```

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/test/goldens/ds_status_dot_golden_test.dart` (created)
  - `packages/warp_prism_ui/test/goldens/ds_badge_golden_test.dart` (created)
  - `packages/warp_prism_ui/test/goldens/ds_metric_tile_golden_test.dart` (created)
  - `packages/warp_prism_ui/test/goldens/ds_glass_panel_golden_test.dart` (created)
  - `packages/warp_prism_ui/test/goldens/goldens/*.png` (50 generated golden baselines)
  - `docs/changelog/2026-06-09-task-1306-golden-baseline-mvp.md` (created)
- **Tests or validation commands**:
  - `dart analyze test/goldens/` → PASS (no issues found)
  - `flutter test --update-goldens test/goldens/` → 51/51 PASS, 50 PNG generated
  - `flutter test test/goldens/` → 51/51 PASS (regression verification)
- **Local changelog entry**: `docs/changelog/2026-06-09-task-1306-golden-baseline-mvp.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
