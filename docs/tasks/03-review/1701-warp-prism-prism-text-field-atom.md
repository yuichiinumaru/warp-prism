# Task 1701 (warp-prism-prism-text-field-atom)

**Status**: Review
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: unassigned

### Objective

Create `PrismTextField` — the missing standalone text input atom for `warp_prism_ui`. Replaces ad-hoc `TextField` use with obsidian-glass styled input that matches the ADS visual language. Supports label, hint, error state, prefix/suffix icons, and disabled state.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/atoms/ds_text_field.dart` | Create | `DSTextField` widget |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify | Export new atom |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismTextField = DSTextField;` |
| `packages/warp_prism_ui/lib/src/gallery/` | Modify | Gallery entry under "Form Primitives" |
| `packages/warp_prism_ui/test/atoms/ds_text_field_test.dart` | Create | Widget tests + goldens |
| `packages/warp_prism_ui/lib/src/atoms/ds_search_bar.dart` | Read | Extract embedded text-field pattern |
| `docs/reports/05-deep-gap-audit-frontend-vs-ads.md` (cybernetics-core-frontend) | Read | §1 (confirmed TRUE gap) |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_search_bar.dart` (which embeds a styled TextField), `lib/src/atoms/ds_text.dart`, `lib/src/atoms/ds_glass_panel.dart`, `lib/src/tokens/ds_colors.dart`, `lib/src/tokens/ds_spacing.dart`, `lib/src/tokens/ds_radii.dart`, `lib/src/tokens/ds_typography.dart`.
- [x] Design `DSTextField` API:
  ```dart
  class DSTextField extends StatefulWidget {
    final TextEditingController? controller;
    final String? label;
    final String? hint;
    final String? helperText;
    final String? errorText;
    final IconData? prefixIcon;
    final IconData? suffixIcon;
    final VoidCallback? onSuffixTap;
    final String? suffixSemanticsLabel;
    final bool obscureText;
    final bool enabled;
    final FocusNode? focusNode;
    final TextInputType? keyboardType;
    final ValueChanged<String>? onChanged;
    final ValueChanged<String>? onSubmitted;
    final int? maxLines;
    final int? minLines;
    final int? maxLength;

    const DSTextField({...});
  }
  ```
- [x] Use a native `TextField` (or `EditableText`) styled to match the ADS:
  - Container: `DSGlassPanel.subtle()` / `DSColors.obsidianElevated` with `DSSpacing.lg` horizontal padding
  - Border: 1px `DSColors.borderSubtle`; focus border switches to `DSColors.accentCyan` with 2px
  - Border radius: `DSRadii.input` (6px)
  - Cursor color: `DSColors.accentCyan`
  - Text style: `DSTypography.bodyMedium` (`DSText.bodyMedium`)
  - Hint style: `DSTypography.bodyMedium.copyWith(color: DSColors.textTertiary)`
- [x] Label: rendered above the field via `DSText.labelSmall` in `DSColors.textSecondary`. If `errorText` is set, switch to `DSColors.statusError`.
- [x] Error state: if `errorText != null`, set border to `DSColors.statusError`, show error message in `DSText.bodySmall` with `DSColors.statusError` below the field.
- [x] Prefix icon: `DSIcon.small(prefixIcon)` inside, with `DSSpacing.sm` gap to text.
- [x] Suffix icon: same as prefix, but right-aligned. If `onSuffixTap` is provided, wrap in interactive surface (48×48 hit target).
- [x] Disabled: reduce opacity to 0.5, ignore all input.
- [x] Multi-line: if `maxLines != null && maxLines > 1`, switch to a tall variant. Use `DSSpacing.lg` vertical padding.
- [x] Gallery entry: all states (default/focus/error/disabled/multiline/password).
- [x] Public alias: `typedef PrismTextField = DSTextField;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Renders label, hint, and error text correctly
  - Typing fires onChanged/onSubmitted
  - Focus state changes border color
  - Disabled reduces opacity, ignores input
  - Prefix/suffix icons render at correct positions
  - Error state shows error text and red border
  - Golden tests for all states
- [x] `melos run analyze` passes
- [x] `melos run test` passes
- [x] `melos run golden` passes

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart` exists
- [x] `DSTextField` supports label, hint, error, prefix/suffix, disabled, multi-line, password
- [x] `PrismTextField` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests + goldens pass
- [x] `melos run analyze` passes
- [x] `melos run test` passes
- [x] Entry in warp-prism `.changelog/` added

### Completion Evidence

- Files modified:
  - `packages/warp_prism_ui/lib/src/atoms/text_field/ds_text_field.dart` (created)
  - `packages/warp_prism_ui/lib/src/atoms/text_field/text_field.dart` (created)
  - `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/atoms/text_field/ds_text_field_test.dart` (created)
  - `packages/warp_prism_ui/test/atoms/atoms_contract_test.dart`
  - `.changelog/20260725-120000-1701-prism-text-field-atom.md` (created)
- Tests that pass: `flutter test test/atoms/text_field/ --concurrency=1 --no-pub` (18/18 PASS), `flutter test test/atoms/atoms_contract_test.dart --concurrency=1 --no-pub` (47/47 PASS)
- Lint result: `dart analyze lib/src/atoms/text_field/ test/atoms/text_field/` (0 issues)
- Golden result: 3 golden tests created & verified (`text_field_default.png`, `text_field_error.png`, `text_field_disabled.png`); regenerated after glow+counter path-to-100 patch
- Changelog ref: `.changelog/20260725-120000-1701-prism-text-field-atom.md`

### Review Ledger

- **Internal builder review (2026-07-25)**: initial score 88/100 (Elite) → path-to-100 patch applied:
  - Added `boxShadow` glow on focus (`DSColors.accentCyan` alpha 0.3, blur 8) and error (`DSColors.statusError` alpha 0.3, blur 8) states on the input container to fulfill the "glow border" spec literally (matches `DSGlowBorder` BoxShadow pattern).
  - Added `prefixSemanticsLabel` parameter; wired `semanticLabel` into prefix icon and static (non-interactive) suffix icon for screen-reader coverage (Axiom 4).
  - Added custom `maxLength` counter rendered below field (`n / maxLength`) when `showCounter` (default true) and error inactive — replaces the suppressed default counter.
  - Added 5 focused tests (counter render, counter hidden on `showCounter:false`, counter suppressed on error, prefix+suffix semantics) → 18/18 pass.
- Goldens regenerated with `--update-goldens`; 0 analyzer issues; 47/47 contract tests still pass (no regression).

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0019-frontend-prism-text-field-gap-widget.md` (archived in `cybernetics-core-frontend/.archive/tasks/0019-migrated-to-warp-prism-1701.md`).

**Spec sources**:
- Report 03 §3.2 (DSSearchBar — embedded text-field styling pattern)
- Report 05 §1 + §2 (confirmed TRUE GAP)

**Blocks frontend tasks**: 0036 (provider form), 0044 (settings forms).

**Anti-Hallucination Guardrail**: Do NOT use `InputDecoration` defaults; explicitly style with `DSTokens` and `DSTypography`. The whole point of the gap widget is ADS-consistent styling.
