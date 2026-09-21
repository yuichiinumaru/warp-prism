# Task 1808 Independent Adversarial Review — PrismColorField

- **Review date**: 2026-08-23
- **Reviewer**: `reviewers`
- **Previous report**: `docs/reports/review/1808-prism-color-field-molecule-independent-review-2026-08-23.md` (accepted delta claimed 100/100)
- **Current score**: **90/100**
- **Verdict**: **NARROW PATCH — remain in `docs/tasks/03-review/`**

## Boundary and contract proof

- `DSColorField` is exposed as `PrismColorField` from `prism_aliases.dart`; gallery registration is live in `design_system_gallery_sections.dart` (`_ColorFieldDemo`).
- Hex parser accepts `#RGB`, `#RRGGBB`, and `#AARRGGBB`, trims whitespace, rejects `#RGBA`/garbage, and formats alpha deterministically.
- Widget coverage exercises valid/invalid/recovery paths, swatches, keyboard activation, focus traversal, disabled state, clear/eyedropper, and semantics.
- Default swatches are ADS tokens (`DSColors.*`), not literal visual values. Action/swatch targets are 48dp.
- No teal default leakage was found in this surface; the molecule uses black-obsidian/Prism tokens and opt-in-safe palette constants.

## Live commands and evidence

```text
cd packages/warp_prism_ui
flutter analyze lib/src/molecules/color_field test/molecules/color_field lib/src/atoms/text_field/ds_text_field.dart lib/src/molecules/molecules.dart lib/src/prism_aliases.dart
# PASS: No issues found

flutter test test/molecules/color_field/ --concurrency=1 --no-pub
# PASS: 25/25

dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# PASS: 7/7

dart format --output=none --set-exit-if-changed [reviewed color-field + shared registration paths]
# FAIL: would reformat 7 files, including color-field source/tests and shared registration/API files
```

The scoped analyzer/test gate is clean, but the non-mutating format gate is not. The larger gallery file also emits 198 info findings when included in a broader analyzer invocation; this report does not convert those unrelated gallery baseline findings into a color-field code failure.

## Findings

### MODERATE — Reviewed color-field surface is not format-clean (NEW / evidence correction)

- The live non-mutating formatter reported changes to `lib/src/molecules/color_field/ds_color_field.dart`, `lib/src/molecules/color_field/hex_color_parser.dart`, `test/molecules/color_field/ds_color_field_test.dart`, plus shared API/registration files.
- The prior accepted report did not provide a non-mutating format proof. This is a current gate failure, not a reason to reject the parser or semantics implementation.

### LOW — Parser tests use a `src/` deep import (PERSISTENT test-boundary debt)

- `test/molecules/color_field/hex_color_parser_test.dart` imports `package:warp_prism_ui/src/molecules/color_field/hex_color_parser.dart` while widget tests use source imports too.
- Production consumers have a Prism alias/barrel, but parser itself is not a public Prism API. Keep this intentional if parser is internal, or expose a documented public parser API and test through it; do not silently broaden the public surface.

## Path to 100

1. Run `dart format` on the color-field source/tests and every changed shared registration/API file; re-run `--set-exit-if-changed`.
2. Re-run the 25 tests, scoped analyzer, and 7/7 boundary harness after formatting.
3. Decide/document whether the parser remains internal (deep-import test acceptable by policy) or needs a public Prism parser API.
4. Preserve regression guards: no `#RGBA` acceptance, 48dp action/swatch targets, complete semantics, and token-only default presets.

## Routing

Score is 90, so task remains in `docs/tasks/03-review/` for a narrow formatting/API-boundary patch. No code was changed by this review.
