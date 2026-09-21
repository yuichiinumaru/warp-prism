---
date: 20260822-040000
timestamp: 20260822-040000
project: "warp-prism"
agent: "architects"
task: "1807,1808,EPIC-18"
description: "Visual convergence loop added: Task 1807 (PrismTokenRegistry override layer + PrismThemeEditor organism + live Catalog iteration + palette bake-back) and Task 1808 (PrismColorField molecule, P2) promoted; EPIC-18 graph amended — accent hexes converge visually instead of upfront swatch pick."
is_rebuild_safe: true
---

# EPIC-18 Amendment — Theme Editor Convergence Loop

## Summary

User decision (2026-08-22): exact accent hexes are no longer approved from static
swatches. The Catalog storybook gains a live Theme Editor so the product owner iterates
accent/surface colors visually and converged values are baked back into tokens.

## Decisions

- Override mechanism = `PrismTokenRegistry` backing ONLY the editable role set
  (blue ladder, focus, surfaces, border) via static getters; call sites unchanged;
  data accents/statuses stay `static const` until Task 1806.
- `PrismThemeEditor` ships as an ADS organism in `warp_prism_ui`; Catalog hosts it.
- `PrismTokenRegistry` is tooling-facing only; production code paths never mutate.
- Task 1805 final approval/golden refresh runs after bake-back on defaults.
- Task 1800 amended: provisional ladder unblocks 1801–1803; sign-off completes at
  convergence.

## Files

- Created: `docs/tasks/01-open/1807-warp-prism-token-override-theme-editor.md`
- Created: `docs/tasks/01-open/1808-warp-prism-color-field-molecule.md`
- Modified: `docs/tasks/00-planning/EPIC-18-warp-prism-black-obsidian-visual-direction-reset.md`
  (task graph + convergence loop amendment)
- Modified: `docs/tasks/01-open/1800-warp-prism-black-obsidian-visual-contract.md`
  (provisional-hexes exit conditions)
