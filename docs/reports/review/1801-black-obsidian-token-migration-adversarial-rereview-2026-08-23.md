# NOVA Adversarial Review — Task 1801

- **Task**: 1801 — Black Obsidian Token Migration and Semantic Palette Mapping
- **Review mode**: independent adversarial re-review / accepted-100 contradiction check
- **Review date**: 2026-08-23
- **Previous report**: `docs/reports/review/1801-black-obsidian-token-migration-independent-review-2026-08-22.md` (100/100, ACCEPTED_100)
- **Score**: **58/100**
- **Verdict**: **REJECT**
- **Lane action**: move from `docs/tasks/03-review/` to `docs/tasks/02-doing/` (collision-safe; no destination collision found)

## Blocking finding — accepted evidence is stale

The task claims a 35-row / 35-file cyan classification ledger and accepted-100 status. A fresh live scan of `packages/warp_prism_ui/lib/src/` finds **38** files containing `accentCyan` or `0xFF00D4FF`. Parsing the task's ledger yields **35 rows / 35 unique paths**.

Missing from the claimed ledger:

1. `packages/warp_prism_ui/lib/src/molecules/color_field/ds_color_field.dart` — `DSColorField.defaultPresets` includes `DSColors.accentCyan` at line 63.
2. `packages/warp_prism_ui/lib/src/organisms/theme_editor/prism_theme_editor.dart` — export dialog icon/code preview and editor swatch usage at lines 103, 143, and 243.
3. `packages/warp_prism_ui/lib/src/theme/ds_theme.dart` — canonical M3 `tertiary` and `tertiaryContainer` deliberately retain cyan at lines 27–29.

There are no stale ledger rows, so this is an incomplete coverage set, not merely harmless stale documentation. The task's “100% verifiable coverage” assertion is contradicted by the live filesystem.

## Passing evidence (does not offset the blocker)

- Black Obsidian token/theme tests: **48/48 PASS** in the combined token/theme run.
- Boundary harness: **7/7 PASS**.
- Scoped analyzer: exit 0, 2 informational deprecation diagnostics, 0 errors.
- Live palette values match the contract: `#030506`, `#080C0E`, `#0C1114`, `#12181C`, `#121D22`; blue ladder `#2F81FF/#1D64D8/#114299`; focus `#802F81FF`; statuses preserved.
- Swatch SVG exists and goldens were not regenerated in this review.

## Findings

- **PERSISTENT / BLOCKING**: cyan ledger does not match the current 38-file filesystem set (35 claimed).
- The three omitted paths require explicit classification: passive preset/data/editor use may be valid, but the task cannot claim exhaustive coverage until they are listed and independently dispositioned.
- No direct score is awarded for accepted-100 claims contradicted by live coverage evidence.

## Path to 100

1. Expand the ledger to exactly 38 live paths, including `ds_color_field.dart`, `prism_theme_editor.dart`, and `ds_theme.dart`, or migrate any forbidden interactive uses.
2. Re-run the deterministic scan and prove row/path-set equality.
3. Re-run analyzer, token/accessibility, boundary, non-golden, and golden-freeze checks; do not regenerate baselines.
4. Re-review before promotion back to `03-review/`.

## Commands / evidence

- Fresh Python path-set reconciliation → `LEDGER_ROWS 35 UNIQUE 35`, `SCAN_PATHS 38`, `MISSING_FROM_LEDGER 3`, `STALE_LEDGER 0`.
- `dart analyze lib/src/tokens lib/src/theme test/tokens test/theme` → exit 0; 2 infos, 0 errors.
- `flutter test test/tokens/ds_token_contract_test.dart test/theme/prism_theme_test.dart --concurrency=1 --no-pub` → **48/48 PASS**.
- `dart test/boundaries/boundary_test.dart --repo-root ../..` → **7/7 PASS**.
