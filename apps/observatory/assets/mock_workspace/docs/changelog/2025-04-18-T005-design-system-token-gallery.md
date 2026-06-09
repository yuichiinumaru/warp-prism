---
id: 2025-04-18-T005-design-system-token-gallery
date: 2025-04-18
project: asw-observatory
task: T005
type: feature
impact:
  - design-system
  - gallery
  - tokens
skills:
  - design-system-harness
  - frontend-quality-harness
---

# Design system token gallery route

## Why

The design system has 40 files across tokens, atoms, molecules, organisms, and templates. Without a gallery page, there is no way to visually verify that every component renders correctly before building feature screens.

## Changed

- Defined the gallery route contract: one page showing all tokens, atoms, molecules, and organisms.
- Specified sections for color tokens, typography, spacing, status semantics, badges, chips, cards, panels, task cards, asset cards, timeline items, graph nodes, and state surfaces.
- Planned the gallery as a mandatory pre-feature gate: the design system must be demonstrable before any workspace page is built.

## Evidence

- `assets/mock_workspace/docs/tasks/01-open/T005-design-system-token-gallery-route.md` defines the gallery contract.
- Target: `lib/pages/design_system_gallery_page.dart`.
