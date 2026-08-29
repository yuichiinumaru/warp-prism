# Independent Review — Task 1302 Public Barrel Audit — 2026-08-23

## Review mode

Independent live re-audit of the public barrel, manifest, automated lock, boundary harness, and scoped analyzer. Historical 100/100 reports were treated as claims to verify, not as authority. No production code was changed for this review.

## Verdict

- **Score:** 72/100
- **Verdict:** `REJECTED_TO_DOING`
- **Lane recommendation:** move `docs/tasks/03-review/1302-warp-prism-public-barrel-audit.md` to `docs/tasks/02-doing/`

The four-export barrel and boundary checks remain healthy, but the definitive-manifest contract is currently false and the public surface still explicitly re-exports DS-prefixed operational symbols.

## Findings

### F1 — CRITICAL — automated manifest lock fails

`dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart --repo-root .` reports:

```text
src Prism: 292 (292 typedef + 0 extension)
audit Prism rows: 292
audit non-Prism gallery: 4
barrel exports: 4
FAIL: audit missing 1 live Prism symbols (sample: PrismColorField)
FAIL: audit has 1 extra Prism symbols not in source (sample: PrismOperationalStateUI)
Public barrel audit lock: FAIL
```

Independent set extraction confirms the same mismatch:

- live `prism_aliases.dart`: 292 typedefs, 0 `Prism*` extensions
- manifest table: 292 Prism rows
- missing: `PrismColorField`
- extra: `PrismOperationalStateUI`

This directly violates the task's definitive export-manifest and source↔audit equality exit condition.

### F2 — HIGH — DS-prefixed operational symbols are explicitly re-exported

`packages/warp_prism_ui/lib/src/prism_aliases.dart:135` contains:

```dart
export 'tokens/ds_operational_state.dart'
    show DSOperationalState, DSOperationalSeverity,
    DSOperationalCategory, DSOperationalStateUI;
```

The public barrel exports `prism_aliases.dart`, so these DS names are part of the consumer-visible API despite the documented contract that DS names are implementation details. The audit instead lists `PrismOperationalStateUI` as an extension, but no such `Prism*` extension declaration exists in the live source. The boundary harness's 7/7 result does not catch this explicit `show` export.

### F3 — LOW — format gate is not clean on audited alias surface

`dart format --output=none --set-exit-if-changed packages/warp_prism_ui/lib/src/prism_aliases.dart ...` exits 1 and reports `prism_aliases.dart` as changed. This is not the primary rejection reason, but it means the reported formatting proof is not current.

## Passing evidence

- `dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart` → **No issues found**.
- `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **7/7 PASS**.
- `packages/warp_prism_ui/lib/warp_prism_ui.dart` has four exports and hides `DSGallerySectionSpec` / `DSGallerySections`.

## Required fixes before re-review

1. Make the manifest and live aliases use one canonical naming model: either declare a real `PrismOperationalStateUI` extension and list it, or document/export the actual DS extension consistently without violating the DS-hidden contract.
2. Add `PrismColorField` to the manifest and remove the stale `PrismOperationalStateUI` row, or regenerate the complete manifest from the corrected source.
3. Stop re-exporting DS-prefixed operational symbols from the public alias barrel unless an explicit compatibility exception is documented and the public-barrel contract is updated.
4. Re-run the lock, scoped analyzer, boundary harness, and non-mutating format check in the same session.

## Axiom summary

| Axiom | Status |
| --- | --- |
| Analyzer integrity | PASS (scoped) |
| Lifecycle safety | N/A |
| Dependency direction | PARTIAL — four-export structure passes, DS operational names leak |
| UI accessibility | N/A |
| Proof reality | FAIL — lock mismatch and stale manifest naming |
| Release security | PASS |

## Evidence paths

- `packages/warp_prism_ui/lib/warp_prism_ui.dart`
- `packages/warp_prism_ui/lib/src/prism_aliases.dart:135,340`
- `packages/warp_prism_ui/tool/verify_public_barrel_audit.dart`
- `docs/design/public-barrel-audit.md:49,64`
- `packages/warp_prism_ui/test/boundaries/boundary_test.dart`
