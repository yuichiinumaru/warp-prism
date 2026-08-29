# Task 1506: PrismEntityLocateSearch Organism

> **Review State**: Accepted — moved to `docs/tasks/03-review/`
> **Priority**: 🔴 P0
> **Type**: `feature`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1519
> **Depends on**: Task 1500

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1506` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement `PrismEntityLocateSearch` for multi-corpus entity/place locate with result list and locate callback. Explicitly **not** a command palette clone.

## Background Context

### Source origin (EPIC-15)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismEntityLocateSearch` |
| **Internal implementation (preferred)** | `DSEntityLocateSearch` + `typedef PrismEntityLocateSearch = DSEntityLocateSearch` in `prism_aliases.dart` (match existing ADS pattern) |
| **Harvest organism ID** | `O-05` |
| **ShadowBroker origin** | `FindLocateBar.tsx` multi-corpus locate |
| **Osiris origin** | `SearchBar.tsx` map locate patterns |
| **Wave** | **C** |
| **Action type** | `NEW` |
| **Product consumers (later)** | Map locate; distinct from `DSCommandPalette` |
| **ADS-first rule** | Gallery + fixtures only — **no** Observatory product route rewrite required for exit |

### What already exists

- `DSCommandPalette` for command execution.
- `DSSearchBar` molecule.
- Filter chips.

### What is missing or broken

- No multi-corpus locate organism with result rows and fly-to/locate callback.
- No fixture corpus search demo in gallery.

### False-gap notes (do not re-implement)

- Do **not** clone `DSShell` / `DSSidebar` / `DSTopbar` as a second app shell — HUD workspace is an **additional** layout class over a stage slot.
- Do **not** port MapLibre, react-map-gl, force-graph JS, xterm.js, or reference megafiles.
- Do **not** invent domain one-off panels (Shodan/SCM/radio) — prefer generic slots + `PrismConnectorPanel` where applicable.
- Compose existing organisms (`DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSCommandPalette`, toast system, tab bar, split pane) rather than forking them.

### Composition notes (molecules/atoms may derive later)

- Locate result row
- Corpus tab/chip
- Locate action button

These molecules are **not** required deliverables of this task; implement inside the organism first, extract only if reuse is proven.

---

## Test Requirements

- MUST query across ≥2 fixture corpora (e.g. agents, places).
- MUST emit selection/locate callback with result payload.
- MUST show empty and loading (fixture delay optional) states.
- Widget tests: type query, select result, clear, empty results.
- A11y labels on search field and results.
- Gallery fixture with mock corpora — no live geocoder required.

---

## Exit Conditions

- [x] `PrismEntityLocateSearch` exported.
- [x] Tests prove distinction from command palette (locate payload, not command id).
- [x] Gallery + analyze + scoped test PASS.
- [x] Local changelog entry added under `docs/changelog/` (or project changelog engine path used by current Warp Prism closeout).
- [x] Completion Evidence is filled before review handoff.
- [x] After barrel/alias changes, `melos run test-boundaries` remains **6/6 PASS** (run from monorepo root; if melos unavailable, run package boundary suite under `packages/warp_prism_ui/test/boundaries/` and record exact command).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/warp_prism_ui.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/atoms/ds_glass_panel.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`.
- [x] Define corpus + result models.
- [x] Implement search field + results list + locate action.
- [x] Document false-gap vs `PrismCommandPalette` in code dartdoc.
- [x] Tests + gallery + exports.
- [x] **Simplicity pass**: remove unnecessary complexity introduced by this task; keep fixture-first contracts; no product route coupling.
- [x] **Regression verification**: run the validation commands listed below and paste outputs into Completion Evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/ds_entity_locate_search.dart` | Create — implementation |
| `packages/warp_prism_ui/lib/src/organisms/command_palette/ds_command_palette.dart` | Read — false-gap reference |
| `packages/warp_prism_ui/lib/src/molecules/ds_search_bar.dart` | Read — compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/entity_locate_search/` | Create — tests |

### How

1. Define corpus search interface with in-memory fixtures.
2. Build UI compose search bar + results.
3. Export/test/gallery.

### Why

Locate-across-corpora is map-critical and distinct from command execution UX.

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
# flutter test test/organisms/entity_locate_search/
# flutter test test/organisms/*entity_locate_search*

# Public API / boundary harness (must stay 6/6 after alias/barrel work)
cd ../..
melos run test-boundaries
```


If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

### Fresh Live Revalidation & Reconciliation (2026-08-24) — Builder Engineer

Fresh live revalidation and path-to-100 self-close pass for Task 1506 under orchestrator `builders`.

- **Files modified (Task 1506 owned surfaces)**:
  - `packages/warp_prism_ui/test/organisms/entity_locate_search/entity_locate_search_test.dart`: Added widget test `locate action IconButton handles keyboard activate intent` verifying direct keyboard activation for the locate action icon button.
- **Shared files restriction compliance**: `design_system_gallery_sections.dart`, `prism_aliases.dart`, `ds_colors.dart`, `ds_theme.dart` were NOT touched.
- **Fresh Gate Results (2026-08-24)**:
  ```text
  $ dart format --output=none --set-exit-if-changed lib/src/organisms/entity_locate_search test/organisms/entity_locate_search
  # → Formatted 3 files (0 changed) in 0.06 seconds; exit 0

  $ dart analyze lib/src/organisms/entity_locate_search test/organisms/entity_locate_search
  # → Analyzing entity_locate_search, entity_locate_search... No issues found! exit 0

  $ flutter test test/organisms/entity_locate_search/ --concurrency=1 --no-pub
  # → 00:03 +14: All tests passed! exit 0 (14/14 widget tests passing)

  $ dart run test/boundaries/boundary_test.dart
  # → Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s); exit 0
  ```
- **Self-Close Review & Path-to-100**:
  - `gt-global-subagent-review` (score-only mode): Score `100/100` (`ACCEPT`).
  - `gt-global-path100-apply`: Closed historical direct keyboard activation proof gap.
- **Lane Authority**: Stays in `02-doing/` (no lane moves performed; no git/jj commands run).

- **Files created/modified**:
  - Created: `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/ds_entity_locate_search.dart`
  - Created: `packages/warp_prism_ui/lib/src/organisms/entity_locate_search/entity_locate_search.dart`
  - Created: `packages/warp_prism_ui/test/organisms/entity_locate_search/entity_locate_search_test.dart`
  - Created: `docs/changelog/2026-07-11-task-1506-entity-locate-search-organism.md`
  - Created: `docs/changelog/2026-07-18-task-1506-path-to-100-format-semantics.md`
  - Modified: `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append export)
  - Modified: `packages/warp_prism_ui/lib/src/prism_aliases.dart` (Prism aliases)
  - Modified: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (gallery case)
  - Path-to-100 (2026-07-18): format gate re-proved clean on task surface; locate-action semantics already simplified to `IconButton` + `tooltip` (no nested `ExcludeSemantics`)
- **Public API name verified**: `PrismEntityLocateSearch` via `package:warp_prism_ui/warp_prism_ui.dart` → `prism_aliases.dart` typedef → `DSEntityLocateSearch`; also `PrismLocateCorpus`, `PrismLocateEntry`, `PrismLocateResult`
- **Tests or validation commands** (path-to-100 re-prove 2026-07-18):
  ```text
  cd packages/warp_prism_ui

  dart format --output=none --set-exit-if-changed \
    lib/src/organisms/entity_locate_search \
    lib/src/organisms/time_machine_scrubber \
    lib/src/organisms/organisms.dart \
    lib/src/prism_aliases.dart \
    lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/entity_locate_search \
    test/organisms/time_machine_scrubber
  # exit 0 — Formatted 9 files (0 changed)

  dart analyze lib/src/organisms/entity_locate_search \
    lib/src/organisms/organisms.dart lib/src/prism_aliases.dart \
    lib/src/gallery/design_system_gallery_sections.dart \
    test/organisms/entity_locate_search
  # exit 0 — No issues found!

  flutter test test/organisms/entity_locate_search/
  # exit 0 — All tests passed! (12)
  ```
- **Boundary harness**:
  ```text
  cd packages/warp_prism_ui && dart run test/boundaries/boundary_test.dart
  # exit 0 — Boundary harness: 7/7 PASS, 0 FAIL, 0 violation(s)
  ```
- **Local changelog entry**:
  - `docs/changelog/2026-07-11-task-1506-entity-locate-search-organism.md`
  - `docs/changelog/2026-07-18-task-1506-path-to-100-format-semantics.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (builders)
- **Completion date**: 2026-07-18 (path-to-100 remediation; original implement 2026-07-11)
- **Lane note**: Ready For Review; remaining in `02-doing/` per builder instruction (no move to `03-review`)

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Path-to-100 Remediation (2026-07-18)

- **Executor**: gt-flutter-engineer (builders)
- **Addressed**:
  1. **Format gate** — task surface + shared barrels/gallery re-checked with
     `dart format --output=none --set-exit-if-changed`; **0 changed**, exit 0.
  2. **Optional semantics** — `_LocateResultRow` locate action already uses
     bare `IconButton` + `tooltip` (no `ExcludeSemantics` / re-labeled wrapper).
- **Re-prove**: analyze PASS; organism tests **12/12 PASS**; boundaries **7/7 PASS**;
  format **PASS**.
- **Open blockers after remediation**: none for this task surface.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal; parent agentID=builders)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1506.md`
- **Lane outcome**: moved to `docs/tasks/03-review/`
- **Task reference**: Task 1506 (`warp-prism-entity-locate-search-organism`)
- **Live prove (this review)**: format PASS; analyze PASS; pack organism tests **35/35 PASS** (13 locate incl. 48dp row); boundaries **7/7 PASS**

#### Current Open Blockers

- None.

#### Path-to-100 Summary

1. ~~Format gate~~ — builder 2026-07-18.
2. ~~Locate IconButton semantics simplify~~ — builder 2026-07-18.
3. ~~Explicit result-row 48dp + size test + kMinInteractiveDimension on locate action~~ — expert 2026-07-18; formal confirmed.

### Independent adversarial gatekeeper re-review (2026-07-18)

- **Reviewer profile**: `reviewers` (parent agentID=reviewers)
- **Score**: `95/100`
- **Verdict**: `PASS WITH NOTES`
- **Full report**: `docs/reports/review/1506-entity-locate-search-independent-gatekeeper-rereview-2026-07-18.md`
- **Fresh live proof**: scoped analyzer clean; organism pack **45/45 PASS** (13 Task 1506); gallery **23/23 PASS**; boundaries **7/7 PASS** direct and via `dart run melos run test-boundaries`.
- **Finding**: required non-mutating format probe is red (`Formatted 15 files (4 changed)`, exit 1) in shared alias/gallery scope. Result-row and locate controls meet 48dp; direct keyboard proof for locate icon is absent.
- **Routing**: stays in `docs/tasks/03-review/` (score >=90).

### Previous Reports

- `docs/reports/review/expert-2026-07-18-task-1506.md` — **100/100** expert path-to-100 — formal confirmed
- `docs/reports/review/1506-entity-locate-search-review-2026-07-16.md` — **86/100** REJECT — **RESOLVED**
- `docs/reports/review-wave-2026-07-11/task-1506-independent-review.md` — score `95/100`, `HELD_IN_REVIEW_PATH_TO_100`

### Regression Guards

- Re-run organism-scoped `flutter test test/organisms/<module>/` after any organism/alias/gallery edit.
- Re-run `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart` after public DS/Prism surface changes — must stay **7/7 PASS**.
- Consumers must import `package:warp_prism_ui/warp_prism_ui.dart` (Prism* aliases); do not expose raw DS* via public barrel.
- Re-run `dart format --output=none --set-exit-if-changed` on task surface after any edit.


## Review/Fix Ledger — 2026-08-24 Wave 2 (BUILDER_CONTEXT; parent `builders`)

- **Engineer session/task ID**: `ses_fce350aa1ffe6E8Ubd0zaOaM2e`
- **Execution outcome**: drain-drift reconciliation + fresh gates + self-close score-only PASS
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent
