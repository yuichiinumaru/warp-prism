# Task 1522: Optional Keyboard Cheatsheet + Scale Bar + Risk Toast Variant

> **Review State**: `ACCEPTED_100` — independent BUILDER_CONTEXT reconciliation passed; awaiting review-owner acceptance
> **Priority**: 🟢 P2
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: N/A (optional Wave I; if completed, refresh Task 1519 matrix)
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1522` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Optional Wave I polish pack: implement `PrismKeyboardCheatsheet` overlay, `PrismScaleMeasureBar` (map scale chrome; organism or molecule — classify in implementation dartdoc), and a **risk-aware toast variant** of the **existing** toast system (O-28 behaviour — not a second toast stack).

### Source origin

| Public name | Harvest ID | ShadowBroker | Osiris |
| --- | --- | --- | --- |
| `PrismKeyboardCheatsheet` | O-24 | Keyboard overlay | `KeyboardShortcuts.tsx` |
| `PrismScaleMeasureBar` | O-26 | Scale bar | `ScaleBar.tsx` |
| Risk toast variant | O-28 | Geo-aware risk toasts | N/A |

## Background Context

### What already exists

- Toast system: `DSToast` / `DSToastManager` (+ Prism aliases).
- Glass overlays and panels.
- Map chrome pack (Task 1509) for related stage decoration.

### What is missing or broken

- No keyboard cheatsheet overlay organism.
- No scale measure bar component.
- No risk-styled toast variant integrated with existing manager.

### False-gap notes

- Do **not** create a parallel toast manager.
- Display config / REC strip (O-25) is **out of scope** unless trivial; prefer skip.
- Mesh comms (O-23) remains deferred outside this task.

### Composition notes (molecules may derive later)

- Shortcut row / keycap chip
- Scale segment bar
- Risk severity toast body variant

---

## Test Requirements

- Keyboard cheatsheet: open/close; lists fixture shortcuts; a11y labels on dismiss.
- Scale bar: renders fixture scale label/segments; read-only.
- Risk toast variant: maps severity to existing operational/risk colors via toast API extension or themed toast content — single manager.
- Widget tests for open/close cheatsheet and toast variant display.
- Gallery cases for all three polish items (or toast section extension).

---

## Exit Conditions

- [x] `PrismKeyboardCheatsheet` exported (alias + barrel as needed).
- [x] `PrismScaleMeasureBar` (or documented molecule name) exported.
- [x] Risk toast variant available without second toast stack.
- [x] Widget tests PASS for cheatsheet open/close and toast variant.
- [x] Gallery registration for optional pack (or Task 1519 matrix update).
- [x] `dart analyze` + scoped `flutter test` PASS.
- [x] Boundary harness 7/7 after alias/barrel work.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: toast system, operational colors, organisms barrel, prism_aliases, harvest O-24/O-26/O-28 notes.
- [x] Implement keyboard cheatsheet overlay with fixture shortcut groups.
- [x] Implement scale measure bar chrome.
- [x] Extend toast styling/API for risk variant — no new manager.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: scale bar kept as **molecule** (documented decision); no second toast stack.
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/keyboard_cheatsheet/` | Create — cheatsheet |
| `packages/warp_prism_ui/lib/src/molecules/ds_scale_measure_bar.dart` | Create — scale bar (molecule) |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` | Modify — risk variant support |
| `packages/warp_prism_ui/lib/src/molecules/ds_toast_manager.dart` | Read — single manager retained |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — exports |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/keyboard_cheatsheet/` | Create — tests |
| `packages/warp_prism_ui/test/molecules/ds_scale_measure_bar_test.dart` | Create — tests |
| `packages/warp_prism_ui/test/molecules/ds_toast_risk_variant_test.dart` | Create — tests |

### How

1. Implement cheatsheet overlay first.
2. Scale bar second (molecule).
3. Risk toast as variant of existing system third.
4. Export/test/gallery.

### Why

Wave I polish improves operator ergonomics without blocking P0 HUD/intel delivery.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Optional task — do not block EPIC acceptance if deferred with written reason in
> Task 1521. Do not create a second toast stack. Do not port mesh crypto.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. ADS-first fixtures
> only. No product route requirements.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/keyboard_cheatsheet/ test/molecules/ds_scale_measure_bar_test.dart test/molecules/ds_toast_risk_variant_test.dart
cd ../..
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/keyboard_cheatsheet/ds_keyboard_cheatsheet.dart`
  - `packages/warp_prism_ui/lib/src/organisms/keyboard_cheatsheet/keyboard_cheatsheet.dart`
  - `packages/warp_prism_ui/lib/src/molecules/ds_scale_measure_bar.dart`
  - `packages/warp_prism_ui/lib/src/molecules/ds_toast.dart` (risk tier + factory)
  - `packages/warp_prism_ui/lib/src/molecules/molecules.dart` (export scale bar)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (export cheatsheet)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (PrismKeyboard*, PrismScale*, PrismToastRiskTier)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` + registry
  - `packages/warp_prism_ui/test/organisms/keyboard_cheatsheet/keyboard_cheatsheet_test.dart` (7)
  - `packages/warp_prism_ui/test/molecules/ds_scale_measure_bar_test.dart` (5)
  - `packages/warp_prism_ui/test/molecules/ds_toast_risk_variant_test.dart` (9)
- **Classification decision (scale bar)**: **molecule** — compact read-only map chrome; no multi-region composition / exclusive tool state / overlay host lifecycle. Documented in `ds_scale_measure_bar.dart` dartdoc.
- **Risk toast**: `DSToastEntry.risk` + `DSToastRiskTier` only; **no** second `DSToastManager`.
- **Tests or validation commands** (2026-07-18T05:28Z):
  - `dart analyze` owned surfaces → **No issues found**
  - `flutter test test/organisms/keyboard_cheatsheet/` → **7/7 PASS**
  - `flutter test test/molecules/ds_scale_measure_bar_test.dart` → **5/5 PASS**
  - `flutter test test/molecules/ds_toast_risk_variant_test.dart` → **9/9 PASS**
  - Pack scoped total with siblings: **73/73 PASS**
- **Boundary harness**: **7/7 PASS**
- **Local changelog entry**: `docs/changelog/20260718-052900-1522-keyboard-scale-risk-toast-gt-flutter-engineer.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under parent builder-orchestrator)
- **Completion date**: 2026-07-18
- **Lane**: left in `02-doing` per builder compact (no promote)

### Changelog Draft

```yaml
task: "1522"
agent: gt-flutter-engineer
project: warp-prism
title: "Optional keyboard cheatsheet + scale bar + risk toast"
description: "Wave I polish: PrismKeyboardCheatsheet, PrismScaleMeasureBar molecule, DSToastRiskTier on existing manager"
summary: >
  Cheatsheet overlay, scale molecule (not organism), risk toast variant without
  second stack; gallery + aliases; 21 focused tests; boundaries 7/7.
verification: >
  dart analyze clean; keyboard 7 + scale 5 + risk 9 PASS; boundary 7/7
```

### Entrypoint Chain Proof

- **Claim**: helper/library-only ADS polish pack
- **Classification**: `helper/library-only` / fixture gallery
- **Helpers**: `DSKeyboardCheatsheet`, `DSScaleMeasureBar`, `DSToastEntry.risk`
- **Regression tests**: open/close cheatsheet, scale label, risk badge via single manager

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal parallel)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1522.md`
- **Lane outcome**: moved to `03-review`
- **Task reference**: Task 1522 (`1522-warp-prism-optional-keyboard-scale-risk-toast`)

#### Current Open Blockers

- None.

#### Path-to-100 Summary

- Already at 100 (formal independent re-proof of expert path-to-100).
- Live: analyze clean; keyboard 8 + scale 6 + risk 9 = **23/23**; boundary **7/7**.

#### Regression Guards

- Do not re-alias high risk color to `statusExposed`/`statusError`.
- Keep single `DSToastManager` (no second toast stack).
- Scale bar remains **molecule** (not organism).
- Cheatsheet keeps modal AT `scopesRoute` + `namesRoute`.

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1522.md` — expert path-to-100 100/100 (historical)
- `docs/reports/review/1522-keyboard-scale-risk-toast-adversarial-review-2026-08-23.md` — current independent adversarial review, 88/100

## Review Ledger Update — 2026-08-23

- **Score**: `88/100`
- **Verdict**: `HELD_IN_REVIEW_RESUBMIT`
- **Classification**: EVIDENCE_GAP — mandatory fresh format/test proof unavailable after required runtime stop on Task 1617
- **Live/source prove**: source inspection confirms single toast manager, molecule classification, modal semantics, token safety; historical focused pack proof was 23/23 + boundary 7/7 but was not re-claimed as fresh
- **Lane outcome**: route to `02-doing/`
- **Report**: `docs/reports/review/1522-keyboard-scale-risk-toast-adversarial-review-2026-08-23.md`
- **Path to 100**: dedicated analyzer/tests, dedicated non-mutating format, boundary 7/7, preserve single manager / molecule / scoped modal semantics guards.


## Independent Session Ledger — 2026-08-24

- **Reviewer profile:** independent `BUILDER_CONTEXT` reconciler
- **Score:** `100/100`
- **Verdict:** `ACCEPTED_100` / `PASS`
- **Full report:** `docs/reports/review/20260824-mixed-1807-1522-1616-independent-review.md`
- **Fresh evidence:** focused keyboard/scale/risk suite `23/23`; dedicated format check clean; single `DSToastManager`, molecule classification, and modal route semantics remain directly guarded; boundary `7/7`.
- **Lane outcome:** parent-authorized move from `02-doing` to `03-review` completed; current path is `docs/tasks/03-review/1522-warp-prism-optional-keyboard-scale-risk-toast.md`.

## Review/Fix Ledger — 2026-08-24 Wave 4 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fcde09181ffeGKqYbxb1MEOLp4`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent
