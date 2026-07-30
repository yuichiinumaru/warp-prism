# Task 1520: EPIC-15 Goldens + Boundary Alias Audit

> **Status**: `[x]` Complete — independent internal review **PASS 100/100**
> **Review State**: `Review` (moved to `03-review` after score-100 gate)
> **Priority**: 🟡 P1
> **Type**: `testing`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1521
> **Depends on**: Task 1519
>
> **Scope note**: Goldens cover **delivered** EPIC-15 organisms at time of execution (minimum:
> Wave A–F public names from Tasks 1501–1513). Waves G–I goldens are optional same-pass if
> those organisms already landed; otherwise schedule a follow-up golden pass rather than blocking.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1520` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Add **default-state golden baselines** for key EPIC-15 organism families and run a **boundary + Prism alias audit** so public contract remains clean (no DS* leakage to consumers; boundaries 6/6).

### Golden families (minimum)

Per epic acceptance:

1. HUD workspace (`PrismMapHudWorkspace`) default state
2. One intel organism (prefer `PrismEntityIntelPanel` or `PrismOsintWorkbench`)
3. One CyberCore workbench (`PrismOsintWorkbench` or `PrismAiAnalystPanel` / terminal shell)

Plus alias audit for all new `Prism*` exports.

## Background Context

### What already exists

- Golden MVP from Task 1306 under `packages/warp_prism_ui/test/goldens/`.
- Boundary harness under `packages/warp_prism_ui/test/boundaries/` and `melos run test-boundaries`.
- Prism aliases file and public barrel.
- Gallery registration completeness from Task 1519.

### What is missing or broken

- No goldens for EPIC-15 organism families.
- Alias/barrel may drift after many parallel organism landings.
- Risk of DS* names leaking into public barrel.

---

## Test Requirements

- At least **3** new golden tests for EPIC-15 default states (HUD + intel + cybercore family).
- Goldens MUST use fixed surface sizes and deterministic fixture data (no timers flaking; pumpAndSettle carefully).
- Alias audit MUST list every new public `Prism*` typedef/export and confirm consumers can import from `package:warp_prism_ui/warp_prism_ui.dart`.
- Boundary tests MUST remain **6/6 PASS**.
- No MapLibre/network dependencies in golden pumps.

---

## Exit Conditions

- [x] ≥3 EPIC-15 golden tests + committed PNG baselines under `packages/warp_prism_ui/test/goldens/`.
- [x] `flutter test` on new golden files PASS (or documented environment skip with justification — prefer pass).
- [x] Alias/barrel audit note in Completion Evidence (table of Prism names → implementation).
- [x] `melos run test-boundaries` → **6/6 PASS** (live harness **7/7 PASS**; melos CLI absent — ran `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart`).
- [x] `dart analyze` on touched test/lib paths clean of errors.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `packages/warp_prism_ui/test/goldens/` (existing golden tests), `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/test/boundaries/`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, EPIC-15 acceptance criteria in epic file, and the three target organism implementations.
- [x] Add golden tests for MapHudWorkspace + one intel + one cybercore organism default states.
- [x] Generate and commit golden PNGs.
- [x] Run boundary harness; fix any alias/barrel regressions.
- [x] Produce alias audit table in Completion Evidence.
- [x] **Simplicity pass**: default state only; no full state-matrix goldens.
- [x] **Regression verification**: goldens + boundaries + analyze.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/test/goldens/` | Create — new golden tests + PNGs |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read/Modify — alias fixes if audit finds gaps |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — public surface |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Read — exports |
| `packages/warp_prism_ui/test/boundaries/` | Read — harness expectations |
| `docs/changelog/` | Create — changelog note |

### How

1. Mirror Task 1306 / Task 1614 golden style.
2. Pump organisms with fixed window and fixtures.
3. Audit aliases vs organisms barrel.
4. Run boundaries.

### Why

Goldens protect visual drift of new HUD/intel/cybercore families; boundary audit protects EPIC-13 public contract after mass organism landing.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not expand golden matrix to every organism. Minimum three families.
> Do not introduce MapLibre for goldens.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixture/mock
> data. If golden environment is non-deterministic, document and prefer widget
> tests over flaky goldens — still attempt goldens first.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test/goldens
flutter test test/goldens/
cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/test/goldens/prism_map_hud_workspace_golden_test.dart` (create)
  - `packages/warp_prism_ui/test/goldens/prism_entity_intel_panel_golden_test.dart` (create)
  - `packages/warp_prism_ui/test/goldens/prism_osint_workbench_golden_test.dart` (create)
  - `packages/warp_prism_ui/test/goldens/goldens/prism_map_hud_workspace_default.png` (create)
  - `packages/warp_prism_ui/test/goldens/goldens/prism_entity_intel_panel_default.png` (create)
  - `packages/warp_prism_ui/test/goldens/goldens/prism_osint_workbench_default.png` (create)
  - `docs/changelog/2026-07-16-task-1520-epic-15-goldens-boundary-alias-audit.md` (create)
  - `docs/tasks/02-doing/1520-warp-prism-epic-15-goldens-boundary-alias-audit.md` (this file — evidence)
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart` — **read only** (no gaps; no edits)

- **Golden list**:
  | Family | Widget | Test | PNG | Surface |
  | --- | --- | --- | --- | --- |
  | HUD | `PrismMapHudWorkspace` | `prism_map_hud_workspace_golden_test.dart` | `goldens/prism_map_hud_workspace_default.png` | 1200×800 |
  | Intel | `PrismEntityIntelPanel` | `prism_entity_intel_panel_golden_test.dart` | `goldens/prism_entity_intel_panel_default.png` | 400×560 (widget 360×520) |
  | CyberCore | `PrismOsintWorkbench` | `prism_osint_workbench_golden_test.dart` | `goldens/prism_osint_workbench_default.png` | 800×600 (widget 720×560) |

- **Alias audit table** (EPIC-15 organism public `Prism*` → implementation; all importable via `package:warp_prism_ui/warp_prism_ui.dart`):

  | Prism* public name | Implementation | organisms.dart export | Alias present |
  | --- | --- | --- | --- |
  | `PrismMapHudWorkspace` | `DSMapHudWorkspace` | `map_hud_workspace/` | yes |
  | `PrismToolStripSlideout` / `PrismToolStripItem` | `DSToolStripSlideout` / `DSToolStripItem` | `tool_strip_slideout/` | yes |
  | `PrismFilterWorkbench` (+ section/criterion types) | `DSFilterWorkbench`… | `filter_workbench/` | yes |
  | `PrismLayerControlPanel` (+ group/item/freshness) | `DSLayerControlPanel`… | `layer_control_panel/` | yes |
  | `PrismTimeMachineScrubber` (+ density types) | `DSTimeMachineScrubber`… | `time_machine_scrubber/` | yes |
  | `PrismEntityLocateSearch` (+ locate types) | `DSEntityLocateSearch`… | `entity_locate_search/` | yes |
  | `PrismEntityIntelPanel` (+ selection/dossier/fixtures) | `DSEntityIntelPanel`… | `entity_intel_panel/` | yes |
  | `PrismWatchlistDock` (+ item/fixtures) | `DSWatchlistDock`… | `watchlist_dock/` | yes |
  | `PrismCoordinateStatusBar` (+ feed/fixtures) | `DSCoordinateStatusBar`… | `coordinate_status_bar/` | yes |
  | `PrismMapLegend` (+ category/item/fixtures) | `DSMapLegend`… | `map_legend/` | yes |
  | `PrismArtifactWorkbench` (+ artifact types/fixtures) | `DSArtifactWorkbench`… | `artifact_workbench/` | yes |
  | `PrismStatusTicker` (+ item/mode/controller/fixtures) | `DSStatusTicker`… | `status_ticker/` | yes |
  | `PrismOsintWorkbench` (+ tool/result/history/fixtures) | `DSOsintWorkbench`… | `osint_workbench/` | yes |
  | `PrismAiAnalystPanel` (+ turn/role/controller/fixtures) | `DSAiAnalystPanel`… | `ai_analyst_panel/` | yes |
  | `PrismFloatingAnalyticsHud` (+ section/metric/controller/fixtures) | `DSFloatingAnalyticsHud`… | `floating_analytics_hud/` | yes |
  | `PrismMapCanvasStage` (+ controller/layer/feature/fixtures) | `DSMapCanvasStage`… | `map_canvas_stage/` | yes |
  | `PrismOpsControlCluster` (+ launcher/fixtures) | `DSOpsControlCluster`… | `ops_control_cluster/` | yes |
  | `PrismConnectorPanel` (+ fixtures) | `DSConnectorPanel`… | `connector_panel/` | yes |
  | `PrismTerminalWorkspace` (+ pane/layout/controller) | `DSTerminalWorkspace`… | `terminal_workspace/` | yes |
  | `PrismEntityRelationCard` | `DSEntityRelationCard` | `entity_relation_card/` | yes |
  | `PrismAgentShellPanel` (+ line/controller types) | `DSAgentShellPanel`… | `agent_shell_panel/` | yes |

  **Barrel contract**: public barrel exports only `src/prism_aliases.dart` + gallery (DSGallery* hidden). No direct `organisms.dart` export. No DS* direct exports. Audit script: **21/21 organism families OK, 0 gaps**. Total Prism typedefs in aliases file: **261**.

- **Boundary harness**: **7/7 PASS** (task text said 6/6; live harness post-1612 has 7 checks — documented, not a regression)
  ```
  Checks: 7/7 PASS
  [PASS] CyberCore contains zero DS* references
  [PASS] Consumer apps do not import warp_prism_ui src/ paths
  [PASS] warp_prism_ui does not import Riverpod or GoRouter
  [PASS] warp_prism_ui does not import app-specific packages
  [PASS] warp_prism_ui does not import forbidden persistence or IO packages
  [PASS] All public DS declarations have Prism aliases
  [PASS] Public barrel hides DS* names from consumers
  ```
  Command: `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart`  
  Note: `melos` CLI not on PATH; equivalent pure-Dart harness used.

- **Tests or validation commands**:
  | Command | Result |
  | --- | --- |
  | `flutter test --update-goldens` (3 new golden files, concurrency=1, no-pub) | **PASS** (baselines generated) |
  | `flutter test` (3 new golden files, concurrency=1, no-pub) | **3/3 PASS** |
  | `dart analyze` on 3 golden tests + `prism_aliases.dart` | **No issues found** |
  | Boundary harness (direct dart run) | **7/7 PASS** |

- **Local changelog entry**: `docs/changelog/2026-07-16-task-1520-epic-15-goldens-boundary-alias-audit.md`
- **Agent-wiki / docs institutionalization**: N/A for this closeout (task evidence + changelog sufficient; parent agentID `builders`)
- **Executor**: builders (Wave D / gt-flutter-engineer)
- **Completion date**: 2026-07-16
- **Ready for review**: **yes** (executor leaves task in `02-doing` per wave instruction; parent may move to `03-review`)

### Residual risks

- OSINT golden captures **idle** default (empty results pane) because `_hasSubmitted` gates result list; submitted-results golden deferred as optional.
- Optional G–H goldens (`PrismFloatingAnalyticsHud`, terminal/agent shell) not added — low priority, out of minimum scope.
- Font/engine pixel drift across CI hosts is inherent to Flutter goldens; fixed sizes + single `pump()` mitigate timer flakiness.

---

## Review Ledger

| Field | Value |
| --- | --- |
| Reviewer | reviewers (gt-flutter-code-reviewer) |
| Date | 2026-07-16 |
| Score | **100 / 100** |
| Verdict | **PASS** |
| Report | `docs/reports/review/1520-epic-15-goldens-boundary-alias-audit-review-2026-07-16.md` |
| Lane action | `02-doing` → `03-review` (score-100 gate) |

### Reviewer re-run evidence
- `dart analyze` (3 goldens + `prism_aliases.dart`): **No issues found**
- `flutter test` (3 EPIC-15 goldens, concurrency=1, --no-pub): **3/3 PASS**
- Boundary harness (`dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart`): **7/7 PASS**
- PNG baselines present with matching dimensions (1200×800 / 400×560 / 800×600)
- Public barrel: Prism aliases only; 22 EPIC-15 family typedefs present; **261** total `typedef Prism*`
- No MapLibre/network deps in golden pumps (fixture stage only)

### Independent review (gatekeeper, 2026-07-16)

| Date | Reviewer | Score | Verdict | Report |
| --- | --- | --- | --- | --- |
| 2026-07-16 | reviewers (independent adversarial gatekeeper) | **96** | **PASS WITH NOTES** | `docs/reports/review/1520-epic-15-goldens-boundary-alias-audit-independent-review-2026-07-16.md` |

**Finding**: EPIC-15 golden tests pass all functional gates (goldens, boundaries, analyzer, deps, alias audit, full golden suite 60/60) but `dart format` reports the three new EPIC-15 golden files would be changed. Path to 100: `dart format` the three files and re-run the scoped format probe.

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 96/100 |
| **Verdict** | PASS WITH NOTES |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1520-drain-review.md` |
| **Top finding** | EPIC-15 golden tests still format-dirty |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: `dart format` on three EPIC-15 golden tests; format probe clean.
**Live**: 3/3 EPIC-15 goldens **PASS**; format clean.
**Remaining**: none task-scope.



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1520-path100-rereview.md` |
| **Top finding** | None |
| **Exits** | 3 EPIC-15 goldens PASS; PNGs present; alias audit; boundaries 7/7; format clean |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
