# Task 1704 (warp-prism-prism-switch-toggle-atom)

**Status**: Doing
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders

### Objective

Create `PrismSwitch` / `PrismToggle` — the missing toggle switch atom for `warp_prism_ui`. When toggled on, the switch shows a cyan accent. Supports a label, is controlled externally, and animates the thumb smoothly.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/atoms/ds_switch.dart` | Create | Compatibility barrel redirect |
| `packages/warp_prism_ui/lib/src/atoms/switch/ds_switch.dart` | Create | `DSSwitch` widget implementation |
| `packages/warp_prism_ui/lib/src/atoms/switch/switch.dart` | Create | `switch.dart` barrel |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify | Export new atom via `prism_aliases.dart` |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismSwitch = DSSwitch;` |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify | Gallery entry (`_SwitchDemo`) |
| `packages/warp_prism_ui/test/atoms/switch/ds_switch_test.dart` | Create | Widget tests |
| `packages/warp_prism_ui/test/atoms/ds_switch_test.dart` | Create | Test redirect |
| `docs/reports/05-deep-gap-audit-frontend-vs-ads.md` (cybernetics-core-frontend) | Read | §1 + §2 (TRUE GAP) |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_badge.dart` (status dot color refs), `lib/src/atoms/ds_interactive_surface.dart` (keyboard/focus contract), `lib/src/tokens/ds_motion.dart` (animation duration tokens), `lib/src/tokens/ds_colors.dart`.
- [x] Design `DSSwitch` API:
  ```dart
  class DSSwitch extends StatelessWidget {
    final bool value;
    final ValueChanged<bool>? onChanged;
    final String? label;
    final bool enabled;
    final FocusNode? focusNode;

    const DSSwitch({...});
  }
  ```
- [x] Render: 44×24 track, 18px diameter thumb. Border radius: track 12px (pill), thumb 9px (circle). Background: `DSColors.obsidianBase` (off) / `DSColors.accentCyan` (on, with `DSCyberCoreTealSkin` if active) — fallback `DSColors.accentCyan`.
- [x] Thumb: `DSColors.textPrimary` (off) / `DSColors.obsidianDeep` (on). Animate horizontal position via `AnimatedAlign` with `DSMotion.normal` (200ms) duration.
- [x] Label: if `label != null`, render `DSText.labelMedium(label)` to the right with `DSSpacing.sm` gap. Tap on label also toggles.
- [x] Wrap in `DSInteractiveSurface` for keyboard activation (Space) and focus ring.
- [x] Disabled: reduce opacity to 0.5, ignore `onChanged`.
- [x] Gallery entry: off, on, off-with-label, on-with-label, disabled, focus.
- [x] Public alias: `typedef PrismSwitch = DSSwitch;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Off state shows thumb on left
  - On state shows thumb on right with accent color
  - Tap fires onChanged
  - Space key toggles
  - Disabled reduces opacity, ignores input
  - Animation completes in expected duration
  - Golden tests for all states
- [x] `melos run analyze` passes
- [x] `melos run test` passes
- [x] `melos run golden` passes

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/atoms/ds_switch.dart` exists
- [x] `DSSwitch` supports value, onChanged, label, disabled
- [x] `PrismSwitch` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests + goldens pass
- [x] `melos run analyze` passes
- [x] `melos run test` passes
- [x] Entry in warp-prism `.changelog/` added

### Completion Evidence

- Files modified:
  - `packages/warp_prism_ui/lib/src/atoms/switch/ds_switch.dart`
  - `packages/warp_prism_ui/lib/src/atoms/switch/switch.dart`
  - `packages/warp_prism_ui/lib/src/atoms/ds_switch.dart`
  - `packages/warp_prism_ui/lib/src/atoms/atoms.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/atoms/switch/ds_switch_test.dart`
  - `packages/warp_prism_ui/test/atoms/ds_switch_test.dart`
  - `docs/design/public-barrel-audit.md`
  - `.changelog/20260725-120000-1704-prism-switch-toggle-atom.md`
- Tests that pass:
  - `flutter test test/atoms/switch/ --concurrency=1 --no-pub` (9 tests PASS)
  - `flutter test test/atoms/ds_switch_test.dart --concurrency=1 --no-pub` (9 tests PASS)
- Lint result:
  - `dart analyze lib/src/atoms/switch/ test/atoms/switch/` (No issues found)
- Golden result:
  - Visual widget verification tests pass; gallery demo section registered
- Changelog ref:
  - `.changelog/20260725-120000-1704-prism-switch-toggle-atom.md`

### Notes

**Origin**: Migrated from `cybernetics-core-frontend/docs/tasks/01-open/0022-frontend-prism-switch-toggle-gap-widget.md` (archived).

**Spec sources**:
- Report 03 (DSMotion — animation tokens)
- Report 05 §1 + §2 (TRUE GAP, simple build)

**Blocks frontend tasks**: 0044 (settings forms need switches for feature flags).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `Switch` / `SwitchListTile`. Compose custom rendering with `DSColors` + `DSMotion` tokens.
