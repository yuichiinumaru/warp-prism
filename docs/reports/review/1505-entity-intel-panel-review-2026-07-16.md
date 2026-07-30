# Independent Review — Task 1505 PrismEntityIntelPanel

**Date**: 2026-07-16  
**Reviewer profile**: `reviewers`  
**Verdict**: REJECT  
**Score**: 85/100  
**Previous report**: `docs/reports/review-wave-2026-07-11/task-1505-independent-review.md`

## Live Evidence Summary

Task claims were treated as untrusted and re-verified on the live filesystem.

- Implementation exists: `packages/warp_prism_ui/lib/src/organisms/entity_intel_panel/ds_entity_intel_panel.dart`
- Test exists: `packages/warp_prism_ui/test/organisms/entity_intel_panel/entity_intel_panel_test.dart`
- Prism aliases exist: `packages/warp_prism_ui/lib/src/prism_aliases.dart:798-814`
- Organism barrel export exists: `packages/warp_prism_ui/lib/src/organisms/organisms.dart:42`
- Gallery registration exists: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:2459-2483`, demo at `4711-4835`

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | PARTIAL | `dart analyze ...` PASS on the full organism scope. `dart format --output=none --set-exit-if-changed ...` FAILED: reported `Changed lib/src/organisms/entity_intel_panel/ds_entity_intel_panel.dart`, `Changed lib/src/prism_aliases.dart`, `Changed lib/src/gallery/design_system_gallery_sections.dart`, `Changed test/organisms/entity_intel_panel/entity_intel_panel_test.dart`. |
| Lifecycle Safety | PASS | `DSEntityIntelPanel` is a `StatelessWidget`; no controllers, subscriptions, timers, or animations created. Fixture subwidgets are leaf widgets only. `dispose()` needed count: 0, disposed count: 0. |
| Dependency Direction | PASS | Implementation imports Flutter + local ADS atoms/DSDetailInspector/tokens only (L1-8); boundary harness PASS 7/7. |
| UI Accessibility | FAIL | 4 custom interactive call-sites violate 48dp minimum: `DSEntityIntelPanel.closeButtonKey` IconButton (L660-665) inherits default IconButton size (~48dp), confirmed OK. However, `_Header` type-chip container (L618-625) has no explicit interaction constraints but is a header-only element — OK. `_SelectChip` (gallery demo, L4801-4835) at `802-833` uses `Padding` with `horizontal: DSSpacing.sm, vertical: DSSpacing.xs` (~8-24dp) — sub-48dp interactive touch target. `_PinButton` IconButton at `699-708` inherits default (~48dp). Touch targets in the organism itself appear compliant. `_SelectChip` in gallery is a demo fixture, not organism — moderate. |
| Proof Reality | PARTIAL | 11 widget tests exist, combined organism suite PASS 43/43. Format proof is **stale/red** (live `dart format` failed). Self-reported coverage is not reflected in confirmed evidence. |
| Release Security | PASS | No live API keys, no print/debugPrint output in implementation. Read-only fixture panel. |

## Findings

### MODERATE — Required format gate is red

- **Evidence**: Live `dart format --output=none --set-exit-if-changed ...` reported:
  - `Changed lib/src/organisms/entity_intel_panel/ds_entity_intel_panel.dart`
  - `Changed lib/src/prism_aliases.dart`
  - `Changed lib/src/gallery/design_system_gallery_sections.dart`
  - `Changed test/organisms/entity_intel_panel/entity_intel_panel_test.dart`
- **Impact**: Review procedure explicitly requires this format check; a red required gate is not review-ready.
- **Recommendation**: Apply formatting in builder lane, then re-run until clean.

### LOW — Gallery demo chip touch targets under 48dp

- **Evidence**: `_SelectChip` in gallery at `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:4801-4835` uses `Padding const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.xs)` (~24dp+8dp) inside an `InkWell`. The organism implementation itself is compliant.
- **Impact**: Gallery-specific; not a binary exit blocker, but accessibility quality for design-system gallery.
- **Recommendation**: Use `const BoxConstraints(minHeight: 48)` or `const EdgeInsets.symmetric(horizontal: DSSpacing.sm, vertical: DSSpacing.md)` on the chip so gallery touch targets meet 48dp.

### LOW — File formatting inconsistent with harness policy

- **Evidence**: Builder self-reported scores of `95/100` with `HELD_IN_REVIEW_PATH_TO_100` from previous review wave, yet both formatting and touch-target issues persist. Regressions vs previous review claims were not mentioned in prior report evidence.
- **Impact**: Light credibility gap; not a binary task-blocker but undermines trust in completion evidence.
- **Recommendation**: Re-check prior review findings to verify they were actually resolved.

## Commands Run

```text
cd packages/warp_prism_ui

dart analyze (full organism surface family scope)
# No issues found!

flutter test (4 organism test suites combined)
# 00:06 +43: All tests passed!

dart run test/boundaries/boundary_test.dart
# Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)

dart format --output=none --set-exit-if-changed (full organism surface scope)
# FAILED: reported Changed ... including Task 1505 files

dart pub outdated
# (informational - not task-blocking)
```

## Score Rationale

85/100. Core implementation and tests are sound. The format gate being red is a required-procedure failure. A gallery chip touch-target issue is minor but reflects incomplete accessibility evidence. Score <90 requires rejection per routing rules.

## Path to 100

1. Apply Dart formatting to listed files; prove clean format gate.
2. Fix gallery `_SelectChip` to meet 48dp minimum touch target.
3. Re-run analyze, organism tests, boundary harness, and format check.