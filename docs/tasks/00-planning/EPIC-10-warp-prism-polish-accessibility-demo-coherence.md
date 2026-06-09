# EPIC 10 — Warp-Prism Polish, Accessibility, and Demo Coherence

> **Planning Status**: Active Epic
> **Executable?**: No — planning artifact only.
> **Promotion Gate**: Promote after core DS, data, shell, and first-pass feature surfaces exist.

## Goal

Turn the assembled prototype into a readable, accessible, responsive, and coherent demo that clearly communicates the ASW Observatory concept.

## Source Evidence

- `prompt.txt` requires ultradark obsidian glass, readable contrast, keyboard-friendly navigation, visible focus states, responsive layout, empty/loading/error states, and demo coherence.
- `research.md` recommends sparse glassmorphism, lazy lists, minimal blur, guided data-storytelling, and WCAG contrast discipline.

## Scope

- Accessibility audit and focus traversal.
- Responsive layout adjustments.
- Empty/loading/error state consistency.
- Performance review of glass/blur/opacity usage.
- Storytelling copy and guided insights.
- Demo script/readiness pass.

## Out of Scope

- Major architecture rewrites.
- New product features beyond prompt acceptance criteria.
- Production-grade real workspace ingestion.

## Candidate Stories

- WCAG contrast/focus state pass.
- Responsive shell and detail behavior pass.
- Empty/loading/error state pass.
- Performance/glass effect pass.
- Data storytelling and demo narrative pass.
- Final acceptance criteria audit.

## Dependencies

- Depends on EPIC 01-09 surfaces being present enough to polish.

## Acceptance Criteria for Epic Completion

- Prototype matches the requested visual direction without sacrificing readability.
- Keyboard focus and navigation are visible and usable.
- Screens handle loading/empty/error states consistently.
- The demo clearly answers: what exists, what matters now, why it changed, what is risky, and how assets connect.
