# Task 1800 — Black Obsidian Visual Contract and Approval Packet

> **Planning Status**: Proposed — architect/task-architect validation required
> **Executable?**: Yes after EPIC-18 plan approval; intended lane `01-open` then `02-doing`
> **Priority**: Critical / P0
> **Type**: governance + visual contract
> **Parent**: EPIC-18 — Warp Prism Black Obsidian Visual Direction Reset
> **Blocks**: Tasks 1801–1806 and new visual component work
> **Depends on**: Product/user visual approval of this contract

## Objective

Freeze a precise, human-approved visual contract so builders cannot reinterpret the
identity as blue backgrounds, teal-everywhere, rainbow chrome, or global monospace.

The default visual identity is **black obsidian**. Blue is a constrained accent/highlight
only. The contract must include approved palette samples, typography roles, composition
examples, forbidden patterns, and the screenshot that becomes the target for later visual
acceptance.

## Required Contract

- Deep background and structural surfaces are black/near-black obsidian.
- Blue may be used for primary action, focus, links, selection, and data highlighting.
- Blue MUST NOT be used as the default background or dominant panel fill.
- Green/amber/red retain semantic status roles.
- Teal `#00FFCC` remains opt-in CyberCore/OmniRoute skin or controlled highlight.
- JetBrains Mono is technical-role-only; it is not the global UI font.
- Rajdhani or another explicitly approved UI font is used for normal interface roles.
- No persistent scanline/ambient-blue effects without explicit approval.
- New structural colors require token-level approval.

## Evidence to Include

- References: `references/cc-reference-images/`, `references/cc-visual-id/`.
- OmniRoute/CyberCore evidence: `cybernetics-core/omniroute-2/src/app/globals.css`,
  `src/app/rajdhani.css`, and the corresponding reference report.
- Current divergences: `DSColors`, `DSTypography`, Observatory theme wiring, Catalog
  theme wiring, and `DSCyberCoreTealSkin`.
- One product-approved target screenshot or visual board.

## Acceptance Criteria

- [ ] User/product owner approves the written black-obsidian contract.
- [ ] Palette table has exact values for background, base, elevated, border, primary
      accent, muted accent, focus accent, and semantic statuses.
- [ ] Typography table specifies UI, display, code, metric, and fallback roles.
- [ ] At least one approved target screenshot exists and is referenced from this task.
- [ ] Forbidden-pattern checklist is explicit.
- [ ] Architect/task architects confirm the contract supersedes conflicting default
      statements in Task 1105, EPIC-17, and Task 1616 where applicable.
- [ ] No implementation or golden regeneration is claimed by this planning task.

## Architect Questions

1. What exact blue accent ladder is approved while keeping all backgrounds black?
2. Is Rajdhani mandatory or the preferred reference font with a fallback?
3. Which app/viewport is the canonical screenshot host?
4. What artifact constitutes human visual approval?
5. Does this amend Task 1105 in place or supersede it through EPIC-18?

## Out of Scope

- Changing tokens or components.
- Regenerating goldens.
- Making teal or blue a global structural background.
- Deleting existing components.
