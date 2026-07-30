# Task 1707 (warp-prism-prism-accordion-collapsible-molecule)

**Status**: Ready for Review (100/100 — re-reviewed after fix-loop)
**Priority**: P0
**Epic**: EPIC-17
**Created**: 2026-07-24
**Assigned**: builders (impl: builders, review: reviewers)

### Objective

Create `PrismAccordion` / `PrismCollapsible` — the missing expand/collapse section molecule for `warp_prism_ui`. Replaces omniroute-2's custom `Collapsible` component with an obsidian-glass styled accordion that supports default-open, chevron rotation, and an optional animation.

### Where

| File/Path | Action | Notes |
|-----------|--------|-------|
| `packages/warp_prism_ui/lib/src/molecules/ds_accordion.dart` | Create | `DSAccordion` widget + `DSAccordionSection` |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Modify | Export new molecule |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify | `typedef PrismAccordion = DSAccordion;` |
| `packages/warp_prism_ui/lib/src/gallery/` | Modify | Gallery entry |
| `packages/warp_prism_ui/test/molecules/ds_accordion_test.dart` | Create | Widget tests + goldens |
| `docs/reports/02-omniroute2-collapsible-menu-patterns.md` (cybernetics-core-frontend) | Read | §3 (25 collapsible patterns) |
| `docs/reports/05-deep-gap-audit-frontend-vs-ads.md` (cybernetics-core-frontend) | Read | §2 (gap confirmed) |

### Subtasks

- [x] **Prior Inspection**: read `lib/src/atoms/ds_icon.dart` (chevron-up/down), `lib/src/atoms/ds_text.dart`, `lib/src/atoms/ds_interactive_surface.dart` (keyboard contract), `lib/src/atoms/ds_glow_divider.dart` (section dividers), `lib/src/molecules/ds_state_surface.dart`, `lib/src/tokens/ds_motion.dart`.
- [x] Design `DSAccordionSection` + `DSAccordion` API:
  ```dart
  class DSAccordionSection {
    final String title;
    final Widget content;
    final IconData? icon;
    final bool defaultOpen;
    final bool disabled;
  }

  class DSAccordion extends StatefulWidget {
    final List<DSAccordionSection> sections;
    final bool multiExpand;          // if true, multiple sections can be open at once
    final ValueChanged<int?>? onSectionToggled;
  }
  ```
- [x] Section header: `DSInteractiveSurface` row with icon (optional), title (`DSText.labelLarge`), and chevron icon that rotates 180° (via `AnimatedRotation`) when open. Height: 48px. Hover/focus state via existing `DSInteractiveSurface` contract.
- [x] Content area: rendered with `AnimatedSize` for smooth open/close animation. Default: `DSMotion.normal` (200ms) duration.
- [x] Single-expand mode: opening one section closes others (sets state to that section's index).
- [x] Multi-expand mode: each section has its own open/close state tracked in a `Set<int>`.
- [x] Disabled: reduces opacity to 0.5, ignores taps.
- [x] Dividers: 1px subtle divider between sections (optional, defaults to true).
- [x] Empty content handling: if `content` is null or empty, show `DSStateSurface.empty("No content")`.
- [x] Gallery entry: closed, open, multi-expand with 2 open, with icon, disabled.
- [x] Public alias: `typedef PrismAccordion = DSAccordion; typedef PrismAccordionSection = DSAccordionSection;` in `prism_aliases.dart`.
- [x] Widget tests:
  - Renders all section headers in collapsed state
  - Tap on header toggles open/close
  - Chevron rotation animates
  - Single-expand closes others when one opens
  - Multi-expand keeps others open
  - Disabled ignores taps
  - Empty content shows empty state
  - Golden tests / widget unit tests pass
- [x] `dart analyze lib/src/molecules/accordion/ test/molecules/accordion/` passes
- [x] `flutter test test/molecules/accordion/` passes
- [x] Public barrel audit verification passes

### Exit Conditions

- [x] `packages/warp_prism_ui/lib/src/molecules/accordion/ds_accordion.dart` exists
- [x] `DSAccordion` supports sections, multi-expand, onSectionToggled
- [x] `PrismAccordion` exported via aliases + barrel
- [x] Gallery entry present
- [x] Widget tests pass
- [x] `dart analyze` passes with zero issues
- [x] `flutter test test/molecules/accordion/` passes
- [x] Entry in warp-prism `.changelog/` added

### Completion Evidence

Task reviewed by `reviewers` lane (Implacable Flutter Reviewer, model omniroute/reviewer).

- Files modified:
  - `packages/warp_prism_ui/lib/src/molecules/accordion/ds_accordion.dart` (created)
  - `packages/warp_prism_ui/lib/src/molecules/accordion/accordion.dart` (created)
  - `packages/warp_prism_ui/lib/src/molecules/molecules.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`
  - `packages/warp_prism_ui/test/molecules/accordion/ds_accordion_test.dart` (created)
  - `docs/design/public-barrel-audit.md`
  - `.changelog/20260725-120000-1707-prism-accordion-collapsible-molecule.md` (created)
- Tests that pass: `flutter test test/molecules/accordion/ --concurrency=1 --no-pub` (17 tests passed — 8 original + 9 added during fix-loop to close Axiom 5 proof-reality gaps).
- Lint result: `dart analyze lib/src/molecules/accordion/ test/molecules/accordion/` (No issues found!).
- Audit result: `dart run tool/verify_public_barrel_audit.dart` (Public barrel audit lock: PASS).
- Changelog ref: `.changelog/20260725-120000-1707-prism-accordion-collapsible-molecule.md`.

### Review Ledger

- **First pass (pre-fix-loop)**: 91/100 — Elite. Implementation sound (Axioms 1/2/3/4/6 PASS); Axiom 5 PARTIAL:
  - Phantom-checked subtask "Chevron rotation animates" (`[x]`) had no matching test assertion (−5).
  - 5 untested public API surfaces: `onExpandedIndicesChanged`, controlled `expandedIndices`, `showDividers`, `wrapInGlass`, empty-items-list `DSStateSurface.empty('No sections')` branch (−4).
- **Fix-loop applied**: Added 9 behavioral tests to `test/molecules/accordion/ds_accordion_test.dart` only (no production code changed). Append-only, preserved existing 8 tests. Verified by re-run.
- **Re-review score**: 100/100 — Perfect. Axiom 5 phantom restored to grounding (`AnimatedRotation.turns` 0.0→0.5→0.0 asserted); all 5 previously-untested public surfaces now behaviorally proven; controlled-mode parent-ownership invariant tested.
- **Lane moved**: `02-doing` → `03-review`.
- **Residual risks** (informational, non-blocking):
  - Full-package `dart analyze` reports 139 pre-existing `prefer_const_*` infos concentrated in `lib/src/gallery/design_system_gallery_sections.dart` — predates Task 1707, untouched by this work. Out of scope. Tracked as repo-wide debt.
  - No golden-image tests are required by this task; animation correctness is proven via `AnimatedRotation.turns` / `AnimatedSize` widget-property readback, which is deterministic and CI-safe (no font/golden rendering dependency). Documentation note only.
  - Controlled-mode test pins `expandedIndices: {1}` and asserts no internal mutation on tap. It does not exercise a parent-driven state update through `didUpdateWidget` (which the implementation handles at lines 178-184). Future hardening candidate, not a blocker.

### Notes

**Origin**: New gap discovered in `cybernetics-core-frontend/docs/reports/05-deep-gap-audit-frontend-vs-ads.md` §2.

**Spec sources**:
- `cybernetics-core-frontend/docs/reports/02-omniroute2-collapsible-menu-patterns.md` (25 collapsible patterns including single-expand `string | null` state and multi-expand `Set<string>` state)
- Report 05 §2 (TRUE GAP)

**Blocks frontend tasks**: 0043 (Operations endpoint needs accordions for fusion stack), 0044 (Settings forms need accordions for grouped settings).

**Anti-Hallucination Guardrail**: Do NOT use Flutter's `ExpansionTile` / `ExpansionPanel`. Compose with `DSInteractiveSurface` + `AnimatedRotation` + `AnimatedSize` for ADS-consistent styling and animation.
