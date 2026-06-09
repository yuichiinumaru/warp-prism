# EPIC 04 — Warp-Prism Product Shell and Overview

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after EPIC 00 establishes entrypoint/router direction and EPIC 03 defines provider contracts.

## Goal

Create the application shell, routing, responsive layout frame, and Overview dashboard that make the ASW Observatory navigable before individual feature surfaces are built out.

## Source Evidence

- `prompt.txt` requires `lib/app/app.dart`, `lib/app/router.dart`, routing/deep-link support, desktop left rail, central content, and right inspector panel.
- `prompt.txt` requires an Overview dashboard with totals, blockers, review queue count, governance warnings, and current story panel.
- `draft.md` reports app shell files were missing or not located.

## Scope

- App root and router.
- Desktop-first shell layout with responsive fallback.
- Navigation to Gallery, Overview, Map, Operate, History, Governance, and Asset Detail.
- Overview dashboard consuming repository/provider state.
- Loading/error/empty states at the shell level.

## Out of Scope

- Full feature screen implementation.
- Advanced graph interactions.
- Write actions or external command execution.

## Candidate Stories

- Minimal router and app root.
- Shell layout and navigation rail.
- Overview metrics panels.
- Current story panel.
- Responsive shell fallback.

## Dependencies

- EPIC 00 for entrypoint compile gate.
- EPIC 01 for DS shell/navigation components.
- EPIC 03 for provider contracts.

## Acceptance Criteria for Epic Completion

- App launches into a coherent shell.
- Navigation targets exist for required surfaces.
- Overview displays real derived metrics from mock data.
- Shell supports desktop layout and a credible small-layout fallback.
