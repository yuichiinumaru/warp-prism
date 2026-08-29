# Task 1801 — Black Obsidian Token Migration and Semantic Palette Mapping

> **Planning Status**: Proposed — executable after Task 1800 approval
> **Priority**: P0
> **Type**: token/theme implementation
> **Parent**: EPIC-18
> **Depends on**: Task 1800
> **Blocks**: Tasks 1803–1806

## Objective

Implement the approved black-obsidian visual contract in shared Warp Prism tokens without
turning blue into a background or allowing components to invent structural colors.

## Scope

Primary surfaces:

- `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`
- `packages/warp_prism_ui/lib/src/tokens/ds_shadows.dart`
- `packages/warp_prism_ui/lib/src/tokens/ds_semantics.dart`
- token barrels and public Prism aliases as required
- token contract tests and visual token documentation

## Rules

- Background, base, elevated, hover, active, glass, and border tokens stay black/neutral
  obsidian according to Task 1800.
- Approved blue gets a bounded ladder for action/focus/link/highlight roles only.
- Green/amber/red remain semantic statuses.
- Teal remains scoped to `DSCyberCoreTealSkin` unless Task 1800 explicitly changes that
  decision.
- Asset/lane colors may remain differentiated but must be documented as semantic data
  mappings, not decorative chrome.
- No raw structural `Color(0x...)` values in components.

## Acceptance Criteria

- [ ] Exact Task 1800 palette values are implemented.
- [ ] `PrismColors` public aliases remain complete and accurate.
- [ ] Token tests assert black-obsidian backgrounds and the approved blue role boundaries.
- [ ] Tests prove status colors are not replaced by blue or teal.
- [ ] Existing CyberCore teal extension remains opt-in and does not mutate static defaults.
- [ ] No new hardcoded structural colors are introduced.
- [ ] Scoped analyzer, tests, and non-mutating format checks pass.
- [ ] A before/after token swatch artifact is attached to the report.

## Explicit Failure Cases

Reject the task if it:

- makes any blue token the scaffold/page background;
- changes all status colors to blue;
- globally changes `#00FFCC` into the default Observatory accent;
- updates goldens without visual approval;
- hides new raw colors inside component files.
