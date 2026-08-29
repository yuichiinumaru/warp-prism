# Task 1515: PrismOpsControlCluster + PrismConnectorPanel

> **Review State**: `In 03-review`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1515` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement two public organisms: `PrismOpsControlCluster` (cluster of operational launcher controls) and `PrismConnectorPanel` (generic header/badge/refresh/minimize/body slot chrome). Prefer connector panel over domain one-off panels.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismOpsControlCluster + PrismConnectorPanel` |
| **Internal implementation (preferred)** | `DSOpsControlCluster + ConnectorPanel` + `typedef PrismOpsControlCluster + PrismConnectorPanel = DSOpsControlCluster + ConnectorPanel` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-16 / O-20` |
| **ShadowBroker origin** | Top-right ops launchers; shared minimizable panel chrome across domain panels |
| **Osiris origin** | Top C2 metrics/header actions; shared glass panel recipe |
| **Wave** | **G** |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore + Map ops chrome; generic connector — not domain clones |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- Glass panel, badges, icon buttons, status dots.
- Error boundary for panel isolation inspiration.

### What is missing or broken

- No ops launcher cluster organism.
- No reusable minimizable connector panel chrome organism.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Ops launcher button
- Connector header bar
- Minimize chevron control

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- Ops cluster: renders N launchers; invokes callbacks; disabled state.
- Connector panel: header title, badge, refresh, minimize/expand, body slot.
- Widget tests for open/minimize exclusive-ish body visibility.
- A11y labels on launchers and header actions.
- Gallery cases for both.

---

## Exit Conditions

- [x] Both public names exported.
- [x] Tests + gallery PASS.
- [x] No Shodan/SCM/radio domain clones.
- [x] Analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Implement `PrismOpsControlCluster` launcher model + UI.
- [x] Implement `PrismConnectorPanel` slot chrome.
- [x] Tests + gallery for both.
- [x] Exports + aliases.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/ops_control_cluster/` | Create — ops cluster |
| `packages/warp_prism_ui/lib/src/organisms/connector_panel/` | Create — connector panel |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — exports |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — aliases |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/ops_control_cluster/` | Create — tests |
| `packages/warp_prism_ui/test/organisms/connector_panel/` | Create — tests |

### How

1. Ship generic chrome before any domain content.
2. Fixture launchers only.
3. Export/test/gallery.

### Why

Ops launchers + shared connector chrome prevent a zoo of domain mega-panels.

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
flutter test test/organisms/ops_control_cluster/ test/organisms/connector_panel/
# Fallback:
# flutter test test/organisms/

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/organisms/ops_control_cluster/ds_ops_control_cluster.dart` (create — DS implementation, model, fixtures)
  - `packages/warp_prism_ui/lib/src/organisms/ops_control_cluster/ops_control_cluster.dart` (create — barrel export)
  - `packages/warp_prism_ui/lib/src/organisms/connector_panel/ds_connector_panel.dart` (create — DS implementation, fixtures)
  - `packages/warp_prism_ui/lib/src/organisms/connector_panel/connector_panel.dart` (create — barrel export)
  - `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (modify — added exports for both)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` (modify — added PrismOpsControlCluster, PrismOpsLauncher, PrismOpsControlClusterFixtures, PrismConnectorPanel, PrismConnectorPanelFixtures aliases)
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (modify — added _OpsConnectorPackDemo gallery section)
  - `packages/warp_prism_ui/test/organisms/ops_control_cluster/ops_control_cluster_test.dart` (create — 9 widget tests)
  - `packages/warp_prism_ui/test/organisms/connector_panel/connector_panel_test.dart` (create — 10 widget tests)
- **Public API name verified**: `PrismOpsControlCluster` + `PrismConnectorPanel` exported via `warp_prism_ui.dart` → `prism_aliases.dart`
- **Tests or validation commands**:
  - `cd packages/warp_prism_ui && dart analyze lib/src/organisms/ops_control_cluster/ lib/src/organisms/connector_panel/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/` → No issues found
  - `flutter test test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub` → **19/19 passed** (9 ops_control_cluster + 10 connector_panel)
  - `flutter test test/boundaries/ --no-pub` → **6/6 PASS** (boundary harness)
- **Boundary harness**: 6/6 PASS — `Shell: Checks: 6/6 PASS` / `Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)`
- **Local changelog entry**: `docs/changelog/2026-07-15-task1515-ops-control-cluster-connector-panel.md`
- **Agent-wiki / docs institutionalization**: N/A (evidence refresh pass — no substantive content change)
- **Executor**: builders (gt-evidence-refresher for evidence fill + promotion); pack re-verify 2026-07-18 gt-flutter-engineer
- **Completion date**: 2026-07-15
- **Pack re-verify (2026-07-18T05:28Z)**:
  - `flutter test test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1 --no-pub` → **21/21 PASS** (10 ops + 11 connector)
  - `dart analyze` owned surfaces → No issues found
  - Boundary harness → **7/7 PASS**
  - Lane: left in `02-doing` per builder compact (no promote)
- **Reconciliation & Fresh Validation**: 2026-08-24 by builder-engineer
  - `ds_ops_control_cluster.dart` reconciled: added `const` constructors to `DSOpsLauncher` items to make scoped analyze 100% clean
  - `dart analyze lib/src/organisms/ops_control_cluster/ lib/src/organisms/connector_panel/ test/organisms/ops_control_cluster/ test/organisms/connector_panel/` → **0 issues found** (exit 0)
  - `dart format --output=none --set-exit-if-changed lib/src/organisms/ops_control_cluster lib/src/organisms/connector_panel test/organisms/ops_control_cluster test/organisms/connector_panel` → **Formatted 0 changed** (exit 0)
  - `flutter test test/organisms/ops_control_cluster/ test/organisms/connector_panel/ --concurrency=1` → **All tests passed (21/21)!** (10 ops + 11 connector) (exit 0)
  - `dart run test/boundaries/boundary_test.dart` → **7/7 PASS** (exit 0)
  - Golden freeze respected: 0 goldens updated
  - Protected files collision constraint: 0 collision files edited
- **Lane note**: Reconciled — current lane is `03-review/`; no `04-completed/` promotion was performed

### Changelog Draft

```yaml
task: "1515"
agent: gt-flutter-expert
project: warp-prism
title: "PrismOpsControlCluster + PrismConnectorPanel expert path-to-100"
description: "Ops launcher cluster + generic minimizable connector panel chrome"
summary: >
  Expert re-review closed residual format + dense 48 floor assert; 21 widget
  tests green; no domain clones; boundaries 7/7; score 97→100.
verification: >
  flutter test ops_control_cluster + connector_panel 21/21; analyze clean; boundary 7/7
```

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
- **Full report**: `docs/reports/review/1515-ops-control-cluster-connector-panel-final-gate-2026-07-18.md`
- **Lane outcome**: remains in `03-review/`
- **Task reference**: Task 1515 (`1515-warp-prism-ops-control-cluster-connector-panel`)

#### Current Open Blockers

- ~~`EVIDENCE_GAP-GALLERY`: the complete gallery test invocation timed out at 120s with Flutter tester SIGTERM/cleanup errors. Isolated footer, EPIC-15 host-scroll, and EPIC-15 Ops builder tests pass.~~ Closed by fresh full gallery run: `flutter test test/gallery/design_system_gallery_test.dart --concurrency=1` → 22/22 passed (2026-08-24).

#### Path-to-100 Summary

- Resolve/document the full-gallery runtime budget without weakening targeted gallery proofs.

### Previous Reports

| Date | Score | Verdict | Report |
| --- | ---: | --- | --- |
| 2026-07-16 | 89 | REJECT | `docs/reports/review/1515-ops-control-cluster-connector-panel-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (expert) | `docs/reports/review/expert-2026-07-18-task-1515.md` |
| 2026-07-18 | 100 | ACCEPTED_100 (formal) | `docs/reports/review/formal-2026-07-18-task-1515.md` |
| 2026-07-18 | 96 | HELD_IN_REVIEW_PATH_TO_100 (skeptical final gate) | `docs/reports/review/1515-ops-control-cluster-connector-panel-final-gate-2026-07-18.md` |

#### Prior Open Blockers (closed)

- ~~Connector refresh/minimize 40dp~~ → `kMinInteractiveDimension` + tests
- ~~Ops dense 40dp~~ → dense keeps ≥48 hit target + test
- ~~Format dirty on pack surfaces~~ → format gate clean (expert 2026-07-18)

#### Regression Guards

- Dense launcher size ≥ 48
- Connector refresh/minimize size ≥ 48


## Review/Fix Ledger — 2026-08-24 Wave 3 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce106a5dffea64mIZ6YyKASV9`
- **Execution outcome**: drain-drift reconciliation + fresh gates + independent BUILDER_CONTEXT re-review PASS
- **Independent review**: 100/100 `ACCEPTED_100`; fresh gallery 22/22; boundary 7/7; scoped tests 21/21
- **Next routing**: remains in `03-review/` pending independent acceptance/closeout owner
