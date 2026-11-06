# Task 1851: Ribbon collapse-priority + tool-mode palette pattern (F-22) — HOLD

> **Epic:** `EPIC-P2-staged` (Story P2-A). **Source:** backlog F-22 card (§2) + EV-M7/TP-declared/`DawToolPalette`/`FloatingContextCommandBar` rows.
> **State:** HOLD in `00-planning/`. **Unlock condition:** Task 1870 (F-03) command-registry contract exists at least as an EXPERIMENTAL IDS spec (identity/label/chord/applicability/enabled-reason/enumeration), so the ribbon/palette pattern has a registry to sit over.
> **Mandate note:** Single-consumer until a second tool-palette host appears → EXPERIMENTAL pattern under MISSION §3.1.

## Outcome and boundaries

Define the ribbon + tool-mode palette as an ADS presentation pattern over the S2 command registry: contextual tabs with priority-collapse behaviour + floating contextual command bar, with eligibility/chord-collision owned by the IDS registry (F-03) and only mechanics here (edit-focus guard stays presentation per layer index). Donor M7 corroboration + Figcraft A2 self-doc seam feed the pattern; donor accidents (hash router, `keepFocus` hacks) never port.

Scope: pattern spec + reference composition + suite. Non-goals: registry itself (F-03), command computation, palette presentation system beyond the pattern.

## Success and verification

- Reference ribbon collapses by declared priority under narrowing constraints deterministically (golden); tool-mode palette lists only registry-eligible commands with disabled-reason propagation.
- Chord-collision/precedence cases defer to registry semantics — pattern never re-implements eligibility.
- Keyboard-only path works; a11y announcements for mode change.

## Where

| Surface | Evidence / anchor |
|---|---|
| Donor pattern | EV-M7 (contextual tabs, priority collapse); TP declared `DawToolPalette` / `FloatingContextCommandBar` (re-scan Tempest at promotion — U-ARITH) |
| Registry contract | Task 1870 (F-03) IDS `CommandIntent` registry (the HOLD — must exist first) |
| Prism target | ADS pattern over `DSCommandPalette` / `DSToolStripSlideout` extensions |
| Layer law | `.project/architecture/layer-contracts.md` §§1–2 (IDS pure Dart; focus mechanics in presentation) |

## Work

- [ ] Confirm Task 1870 registry contract shape at execution time; build against its established API (per AGENTS.md causal-dependency rule, construction on contract is legitimate — the HOLD lifts when the contract exists).
- [ ] Author collapse-priority spec (priority order injected, deterministic overflow behaviour) + tool-mode palette wiring.
- [ ] Reference composition + suite (collapse determinism, eligibility pass-through, keyboard path, a11y).
- [ ] Run validation below; keep EXPERIMENTAL (no barrel export).

## Validation

```bash
flutter analyze packages/warp_prism_ui packages/warp_prism_interaction
flutter test packages/warp_prism_ui/test/boundaries/boundary_test.dart
flutter test <new-suite-path>
```

Expected: analyze clean; no Flutter import in IDS surfaces; suites green.

## Gates

- Declared prerequisite: Task 1870 registry contract (EXPERIMENTAL spec minimum).
- MISSION §6 gates 2–7 before STABLE; second tool-palette host before STABLE.
- Parallelizable with: 1850 (disjoint writeset) once unblocked.
