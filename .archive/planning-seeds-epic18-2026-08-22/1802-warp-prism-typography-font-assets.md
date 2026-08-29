# Task 1802 — Typography Roles and Font Asset Correctness

> **Planning Status**: Proposed — executable after Task 1800 approval
> **Priority**: P0
> **Type**: typography/assets/theme implementation
> **Parent**: EPIC-18
> **Depends on**: Task 1800
> **Blocks**: Task 1803 and visual acceptance

## Objective

Correct the role assignment and app loading of UI fonts. Normal interface text must not be
rendered as global monospace, while technical content must retain a dependable mono face.

## Scope

- `packages/warp_prism_ui/lib/src/tokens/ds_typography.dart`
- Catalog, Observatory, and CyberCore font declarations/assets
- App theme composition and role-specific text styles
- Typography contract tests and Catalog smoke evidence

## Required Roles

| Role | Font |
|---|---|
| Body/navigation/labels/headings | Approved Rajdhani-like or explicitly signed-off UI face |
| Code/log/terminal/IDs/timestamps/telemetry | JetBrains Mono |
| Numeric metrics | Explicitly chosen mono or UI role per approved contract |
| Fallback | Deterministic system sans/mono fallback |

## Acceptance Criteria

- [ ] `fontFamilyMono` is not applied as the global font for Observatory UI.
- [ ] Catalog and CyberCore load the intended UI and mono assets where required.
- [ ] Font asset declarations work in the actual app host, not only unit tests.
- [ ] Typography tests assert role separation and fallback behavior.
- [ ] Visual screenshot demonstrates readable normal UI text and technical data contrast.
- [ ] No automatic Orbitron adoption; any display font choice is explicit and approved.
- [ ] No claims of font correctness without a host-level smoke test.
