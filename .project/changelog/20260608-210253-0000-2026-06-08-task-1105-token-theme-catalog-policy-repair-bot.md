---
date: 20260608-210253
timestamp: 20260608-210253
agent: repair-bot
task: "1105"
description: "Changelog — 2026-06-08 — Task 1105: Token Theme Catalog Policy"
is_rebuild_safe: true
---

# Changelog — 2026-06-08 — Task 1105: Token Theme Catalog Policy

> **Task**: 1105 — Warp Prism Token Theme Catalog Policy
> **Type**: architecture / design-system
> **Impact**: design-system, governance

## What Changed

Created `docs/design/token-theme-catalog-policy.md` — the reusable ADS
governance contract for `warp_prism_ui`.

## Policy Decisions

1. **Token categories**: Defined three-layer token hierarchy (primitive →
   semantic → component). All 8 existing token classes mapped and documented.
2. **DS* vs Prism* boundary**: DS* names are internal implementation; Prism*
   names are the exported public API. Consumer apps import only Prism*.
3. **ThemeExtension deferred for MVP**: Current static-const token pattern
   retained. PrismThemeColors/PrismThemeTypography extensions planned for
   post-Melos task.
4. **Custom catalog MVP**: Widgetbook deferred. Existing
   DesignSystemGalleryPage + DSGallerySections serve as the ADS proof surface.
   Widgetbook revisit criteria defined.
5. **Component promotion gates**: Catalog case + state matrix + widget test +
   semantics test + golden test + Prism* alias + dependency isolation required
   before public export.
6. **15-state operational vocabulary integration**: All components displaying
   workspace entity state must document which of the 15 operational states they
   support, with color/icon/behavior/screen-reader-label contracts.
7. **Golden test policy**: Required for atoms, molecules, organisms, templates.
   Optional for tokens.
8. **Semantics test policy**: Required for all interactive components. WCAG AA
   contrast enforcement.
9. **ADS upgrade loop**: Governed flow for bugs/missing components discovered by
   consumer apps. Local ADS hacks prohibited.
10. **Gallery-to-catalog evolution**: Gallery pages live inside `warp_prism_ui`;
    catalog app is a thin shell that renders them.

## Source Evidence

- Task 1101 (charter/naming), Task 1102 (component inventory + operational
  state vocabulary), Task 1104 (Melos monorepo architecture)
- Tasks 0014, 0017 (token contract + gallery route evidence)
- Direct inspection of all 8 token files, gallery page, gallery sections, and
  test directory
