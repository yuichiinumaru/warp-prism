# Task 1305: Catalog Contract Expansion

> **Status**: `[x]` Builder Done
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-13, stabilization wave, catalog test is smoke-only (1 pass, near-irrelevant).
> **Blocks**: Golden baseline (1306)
> **Depends on**: 1304 (gallery compile cleanup), 1303 (contract reconciliation)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1305` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Transform the catalog from a smoke test into a real ADS proof surface that
verifies: all registered sections render, no duplicate component IDs exist,
state matrices are covered, layout responsiveness works, and high text scale
is handled.

## Background Context

### What already exists

- `apps/catalog/test/widget_test.dart` does: `pumpWidget(WarpPrismCatalogApp())`
  and verifies the app type exists. This proves almost nothing.
- `packages/warp_prism_ui/lib/src/gallery/` has gallery pages and sections.
- Task 1106 defines catalog case requirements: default, loading, empty, error,
  degraded, disabled, long text, narrow, high text scale.

### What is missing or broken

- No test verifies that all gallery sections are registered and render.
- No test checks for duplicate component IDs.
- No test covers state matrices (loading, empty, error, success).
- No test verifies responsive layout or high text scale.

---

## Test Requirements

- Catalog test proves all registered sections render without crash.
- Catalog test checks no duplicate section IDs exist.
- At least one state matrix test exists per atomic design layer.
- Responsive layout test exists for at least compact and expanded widths.

---

## Exit Conditions

- [x] `apps/catalog/test/widget_test.dart` verifies all sections render.
- [x] `apps/catalog/test/widget_test.dart` checks for duplicate IDs.
- [x] At least 4 state matrix tests exist (one per layer: atom, molecule,
  organism, template).
- [x] At least 1 responsive layout test exists.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `apps/catalog/test/widget_test.dart`,
  `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`,
  `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`,
  and Task 1106 (operational component MVP).
- [x] Update `apps/catalog/test/widget_test.dart` to pump the catalog and
  verify all registered sections render (no crash, no empty widgets).
- [x] Add a test that checks section IDs are unique.
- [x] Add state matrix tests: render each layer's components in
  loading/empty/error/disabled states.
- [x] Add a responsive layout test: pump at compact width and expanded width,
  verify layout adapts.
- [x] **Simplicity pass**: tests should be widget-level, not integration-level.
  Use `pumpWidget` with the gallery page.
- [x] **Regression verification**: run `flutter test apps/catalog/`.

### Where

| File | Purpose |
| --- | --- |
| `apps/catalog/test/widget_test.dart` | Modify — expand tests |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Read — gallery structure |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Read — section registry |

### How

1. Read the current catalog test and gallery structure.
2. Add section-count and duplicate-ID tests.
3. Add state matrix tests per layer.
4. Add responsive layout test.
5. Run and verify.

### Why

The catalog is supposed to be the ADS "storybook." If it only proves the app
exists, it is not protecting anything. Making it a real proof surface means
every promoted component is verified through the catalog automatically.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not create integration tests that require Riverpod providers or app-level
> setup. Catalog tests should be pure widget tests against the gallery page.

---

## Validation Commands

```bash
flutter test apps/catalog/
```

---

## Completion Evidence

- **Files created/modified**:
  - `apps/catalog/test/widget_test.dart` — expanded from 1 smoke test to 10
    contract tests
  - `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md` —
    changelog entry
- **Tests or validation commands**:
  - `flutter analyze apps/catalog/` → 0 issues (PASS)
  - `flutter test apps/catalog/` → 10/10 passed (PASS)
- **Local changelog entry**:
  `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: builders
- **Completion date**: 2026-06-09
