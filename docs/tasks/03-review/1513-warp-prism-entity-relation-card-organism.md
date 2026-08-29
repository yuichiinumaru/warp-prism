# Task 1513: PrismEntityRelationCard Organism

> **Review State**: `In 03-review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500, Task 1512

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1513` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismEntityRelationCard`: compact relation preview with mini graph (compose `DSGraphCanvas` or simplified preview), legend, and footer actions. Fixture graph data only.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismEntityRelationCard` |
| **Internal implementation (preferred)** | `DSEntityRelationCard` + `typedef PrismEntityRelationCard = DSEntityRelationCard` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-10` |
| **ShadowBroker origin** | Entity relation expand card patterns |
| **Osiris origin** | `EntityGraphPanel.tsx` expand graph preview (compose `DSGraphCanvas`; do not port force-graph JS) |
| **Wave** | **F** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map + graph coupling; preview card not full graph editor |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSGraphCanvas` and graph subpackage.
- Detail inspector / intel panel hosts.

### What is missing or broken

- No relation expand card organism bridging selection and graph preview.
- No gallery fixture for entity relations.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Relation legend item
- Expand-graph footer
- Mini graph viewport frame

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST render fixture related nodes/edges preview.
- MUST include legend and footer action callbacks.
- MUST compose graph canvas or a constrained preview without force-graph JS.
- Widget tests: expand/collapse if applicable, footer action, empty relations.
- A11y labels on footer actions.
- Gallery fixture entity.

---

## Exit Conditions

- [x] `PrismEntityRelationCard` exported.
- [x] Tests + gallery PASS.
- [x] No JS force-graph dependency.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define relation card model.
- [x] Implement card chrome + preview graph composition.
- [x] Footer actions + legend.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/ds_entity_relation_card.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/ds_graph_canvas.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/graph/` | Read — typed graph model if useful |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/entity_relation_card/` | Create — tests |

### How

1. Compose existing graph canvas in a card frame.
2. Use fixture relations.
3. Export/test/gallery.

### Why

Selection→relation preview is a key investigation affordance in both harvests without requiring a full graph workspace.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark this task complete without running the validation commands and
> filling Completion Evidence. Do not claim gallery/catalog registration without
> a navigable section or an explicit deferred note pointing at Task 1519.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. No live API keys, no mesh crypto, no MapLibre engine port, no SQLite.

> [!WARNING]
> ADS-first delivery: fixtures + design-system gallery are sufficient. Do **not**
> rewrite Observatory Map/Operate/History routes unless a separate integration
> task exists. Do not touch unrelated Ganthritor child projects.


---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/entity_relation_card/
# flutter test test/organisms/*entity_relation_card*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified** (resubmit 2026-07-18 path-to-100):
  - `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/ds_entity_relation_card.dart` — slim host (~170 LOC)
  - `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/entity_relation_card_legend.dart` — 48dp legend filter + keyboard activation
  - `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/entity_relation_card_sections.dart` — header/body/footer composition
  - `packages/warp_prism_ui/lib/src/organisms/entity_relation_card/entity_relation_card.dart` — module barrel
  - `packages/warp_prism_ui/test/organisms/entity_relation_card/ds_entity_relation_card_test.dart` — 7 tests (incl. 48dp legend)
  - Prior land: organisms.dart export, prism aliases, gallery fixture
- **Public API name verified**: `PrismEntityRelationCard` via `typedef PrismEntityRelationCard = DSEntityRelationCard` in `prism_aliases.dart`
- **No force-graph JS**: composes `DSGraphCanvas` only
- **Resubmit blockers closed** (review 2026-07-16 score 88):
  1. Legend filter hit regions ≥ 48dp (`kEntityRelationLegendMinTouchTarget`)
  2. Widget test asserts legend width/height ≥ 48
  3. File split: host + legend + sections
- **Tests or validation commands** (pack gate 2026-07-18T05:25Z):
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
  # → No issues found!  (exit 0)

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/entity_relation_card test/organisms/entity_relation_card
  # → Formatted 0 changed  (exit 0)

  flutter test test/organisms/entity_relation_card/ --concurrency=1
  # → All tests passed! (7)  (exit 0)

  dart analyze lib test
  # → No issues found!  (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS  (exit 0)
  ```
- **Boundary harness**: 7/7 PASS (`dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui`)
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1513-entity-relation-card-resubmit.md` (+ prior `2026-07-15-task1513-entity-relation-card-organism.md`)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under builders)
- **Completion date**: 2026-07-18
- **Reconciliation & Fresh Validation**: 2026-08-24 by builder-engineer
  - `dart analyze lib/src/organisms/entity_relation_card test/organisms/entity_relation_card` → **0 issues found** (exit 0)
  - `dart format --output=none --set-exit-if-changed lib/src/organisms/entity_relation_card test/organisms/entity_relation_card` → **Formatted 0 changed** (exit 0)
  - `flutter test test/organisms/entity_relation_card/ --concurrency=1` → **All tests passed (8/8)!** (exit 0)
  - `dart run test/boundaries/boundary_test.dart` → **7/7 PASS** (exit 0)
  - Golden freeze respected: 0 goldens updated
  - Protected files collision constraint: 0 collision files edited
- **Lane note**: Reconciled — current lane is `03-review/`; no `04-completed/` promotion was performed

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `reviewers` (skeptical final gate)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/1513-entity-relation-card-final-gate-2026-07-18.md`
- **Lane outcome**: remains in `03-review/`
- **Task reference**: Task 1513 (`1513-warp-prism-entity-relation-card-organism`)

#### Current Open Blockers

- ~~`EVIDENCE_GAP-GALLERY`: the complete gallery test invocation timed out at 120s with Flutter tester SIGTERM/cleanup errors. Isolated footer, EPIC-15 host-scroll, and EPIC-15 builder tests pass.~~ Closed by fresh full gallery run: `flutter test test/gallery/design_system_gallery_test.dart --concurrency=1` → 22/22 passed (2026-08-24).

#### Path-to-100 Summary

- Resolve/document the full-gallery runtime budget without weakening targeted gallery proofs.

### Previous Reports

| Date | Score | Verdict | Report |
| --- | ---: | --- | --- |
| 2026-07-16 | 88 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1513-entity-relation-card-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (expert) | `docs/reports/review/expert-2026-07-18-task-1513.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (formal) | `docs/reports/review/formal-2026-07-18-task-1513.md` |
| 2026-07-18 | 96 | HELD_IN_REVIEW_PATH_TO_100 (skeptical final gate) | `docs/reports/review/1513-entity-relation-card-final-gate-2026-07-18.md` |

#### Prior Open Blockers (closed)

- ~~Legend chip below 48dp~~ → ConstrainedBox min 48 + size test
- ~~Mega-widget 458 LOC~~ → host + legend + sections split
- ~~Footer actions without explicit 48 minSize~~ → `minimumSize` + height test (expert 2026-07-18)

#### Regression Guards

- Legend filter width/height ≥ 48
- Footer inspect/expand height ≥ 48


## Review/Fix Ledger — 2026-08-24 Wave 3 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce106a5dffea64mIZ6YyKASV9`
- **Execution outcome**: drain-drift reconciliation + fresh gates + independent BUILDER_CONTEXT re-review PASS
- **Independent review**: 100/100 `ACCEPTED_100`; fresh gallery 22/22; boundary 7/7; scoped tests 8/8
- **Next routing**: remains in `03-review/` pending independent acceptance/closeout owner
