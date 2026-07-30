# Task 1510: PrismOsintWorkbench Organism

> **Status**: `[x]` Ready For Review — Resubmit path-to-100
> **Review State**: `Ready For Review`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1510` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismOsintWorkbench`: tab registry, query input, history list, structured results, and optional map-handoff callback. Fixture datasets only; no live recon APIs.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismOsintWorkbench` |
| **Internal implementation (preferred)** | `DSOsintWorkbench` + `typedef PrismOsintWorkbench = DSOsintWorkbench` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-08` |
| **ShadowBroker origin** | `ReconPanel.tsx` / `ReconResults.tsx` (mode contract) |
| **Osiris origin** | `OsintPanel.tsx` tabbed recon — harvest **contract**, not ~1k LOC structure |
| **Wave** | **E** |
| **Action type** | `NEW` |
| **Product consumers (later)** | CyberCore recon UI; fixture-first until Go backend |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSTabBar`/`DSTabView`, `DSDataTable`, `DSSearchBar`, `DSLogViewer` for result-ish displays.
- Command palette (different job).

### What is missing or broken

- No tabbed OSINT/recon workbench organism.
- No query history + structured results + handoff callback package.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Tool tab registry item
- Query history list row
- Structured result card

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST host ≥2 fixture tool tabs via registry.
- MUST accept query submit and show structured results fixture.
- MUST retain query history list (session-local state).
- MUST expose optional `onMapHandoff` callback when result has geo payload.
- Widget tests: tab switch, submit query, history select, empty results, handoff tap.
- A11y labels on tabs, submit, history items.
- Gallery fixture-first demo; document no live keys.

---

## Exit Conditions

- [x] `PrismOsintWorkbench` exported.
- [x] Tests + gallery PASS.
- [x] Analyze + scoped test PASS.
- [x] Skip megafile structure explicitly in dartdoc/Completion Evidence.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Design tool-tab registry + query/result models.
- [x] Implement workbench shell composing tabs + results.
- [x] Fixture recon adapters (in-memory).
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/osint_workbench/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/osint_workbench/ds_osint_workbench.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/tab_bar/` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/data_table/ds_data_table.dart` | Read — optional results table |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/osint_workbench/` | Create — tests |

### How

1. Harvest tab+query+results contract only.
2. Implement with fixtures and optional map handoff callback.
3. Export/test/gallery.

### Why

CyberCore pilot needs recon workbench UI before Go APIs; fixture-first unblocks ADS and pilot screens.

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

> [!CAUTION]
> No live OSINT APIs, no API keys in localStorage, no domain one-off organisms (Shodan-only clones).

---

## Validation Commands

```bash
# From packages/warp_prism_ui (preferred scoped package gates)
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/
# Prefer organism-scoped path when present, e.g.:
# flutter test test/organisms/osint_workbench/
# flutter test test/organisms/*osint_workbench*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified** (resubmit 2026-07-18):
  - `packages/warp_prism_ui/lib/src/organisms/osint_workbench/ds_osint_workbench.dart` — assert `tools.length >= 2`; history row `minHeight: 48`; format
  - `packages/warp_prism_ui/test/organisms/osint_workbench/osint_workbench_test.dart` — single-tab assert test; 48dp history row test; format
  - `docs/changelog/2026-07-18-task-1510-osint-workbench-resubmit.md` (create)
  - Prior land: module, barrel export, prism aliases, gallery, original changelog
- **Public API name verified**: `PrismOsintWorkbench` via `typedef PrismOsintWorkbench = DSOsintWorkbench` in `prism_aliases.dart`, re-exported by `package:warp_prism_ui/warp_prism_ui.dart`
- **Megafile skip (explicit)**: Dartdoc on `DSOsintWorkbench` harvests **mode contract only** — not Osiris/ShadowBroker megafile structure
- **Resubmit blockers closed**:
  1. Format gate: PASS (`dart format --output=none --set-exit-if-changed` → 0 changed)
  2. Package analyzer: `dart analyze lib test` **exit 0** (pre-existing infos only; scoped organism/test **No issues found**)
  3. Multi-tab contract: `assert(tools.length >= 2)` + rejection test
  4. History row 48dp: `ConstrainedBox(minHeight: 48)` + size widget test
- **Tests or validation commands** (pack gate re-verify 2026-07-18T05:25Z):
  ```text
  cd packages/warp_prism_ui
  dart analyze lib/src/organisms/osint_workbench test/organisms/osint_workbench
  # → No issues found!  (exit 0)

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/osint_workbench test/organisms/osint_workbench
  # → Formatted 0 changed  (exit 0)

  flutter test test/organisms/osint_workbench/ --concurrency=1
  # → All tests passed! (14)  (exit 0)

  dart analyze lib test
  # → No issues found!  (exit 0)

  dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS  (exit 0)
  # melos unavailable; package boundary suite used
  ```
- **Boundary harness**: 7/7 PASS (`dart run test/boundaries/boundary_test.dart` from `packages/warp_prism_ui`)
- **Local changelog entry**: `docs/changelog/2026-07-18-task-1510-osint-workbench-resubmit.md` (+ prior `2026-07-11-task-1510-osint-workbench-organism.md`)
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (under builders)
- **Completion date**: 2026-07-18
- **Lane note**: Ready For Review — remains in `02-doing/` per builder instruction (no promote / no move to `03-review`)
- **Changelog Draft**:
  ```yaml
  task: 1510
  agent: gt-flutter-engineer
  project: warp-prism
  title: PrismOsintWorkbench path-to-100 resubmit
  description: ≥2-tab assert, 48dp history rows, format/analyze clean; fixture-only.
  summary: OSINT workbench resubmit ready for re-review.
  verification: 14 tests + package analyze clean + 7/7 boundaries
  ```

---

## Review Ledger

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `gt-flutter-code-reviewer` (builders; flutter-harness + code-quality-harness + design-system-harness)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1510.md`
- **Lane outcome**: **moved to `03-review/`** (formal gate; S=100; no git)
- **Prior expert fix verified**: tool tab minHeight 40→48 + size widget test

#### Current Open Blockers

- None

#### Path-to-100 Summary (completed)

1. ~~Format / analyzer / tools≥2 / history 48dp~~ DONE (builder)
2. ~~Tool tab interactive target 48dp + test~~ DONE (expert)
3. ~~Formal final gate~~ DONE — score 100 (**15** tests)

### Previous Reports

| Date | Score | Verdict | Report |
| --- | --- | --- | --- |
| 2026-07-11 | 95 | HELD_IN_REVIEW_PATH_TO_100 | `docs/reports/review-wave-2026-07-11/task-1510-independent-review.md` |
| 2026-07-16 | 86 | HELD_IN_REVIEW_RESUBMIT | `docs/reports/review/1510-osint-workbench-review-2026-07-16.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/expert-2026-07-18-task-1510.md` |
| 2026-07-18 | 100 | ACCEPTED_100 | `docs/reports/review/formal-2026-07-18-task-1510.md` |
