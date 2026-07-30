# Task 1607: PrismProviderHealthMatrix Organism

> **Status**: `[x]` Completed (independent drain 2026-07-17)
> **Review State**: `HELD_IN_REVIEW_PATH_TO_100`
> **Priority**: 🟡 P1
> **Type**: `feature`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1613 (soft)
> **Depends on**: Task 1600
>
> **Soft**: Task 1601 gallery polish; Task 1602 PageShell may wrap gallery demo but is not required.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1607` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Implement **`PrismProviderHealthMatrix`** — grid of provider health cells (provider → optional account/model dimensions) with operational state, latency, and selection callback. **Fixture-first CyberCore** while Go backend lands. Public `Prism*` + `DS*` + alias; minimal gallery case.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Proposed public name** | `PrismProviderHealthMatrix` |
| **Internal** | `DSProviderHealthMatrix` + typedef |
| **Harvest ID** | **C-07** |
| **Origin** | OmniRoute / CyberCore provider health dashboards |
| **Wave** | **L** (CyberCore ops inspect) |
| **Action type** | `NEW` |

### What already exists

- `DSHealthCard`, `DSStatusGrid`, `DSMetricTile`, `DSUptimeBar`, operational state vocabulary.
- Status dots and sparklines.

### What is missing or broken

- No **matrix** organism for multi-provider × multi-cell health overview.
- Health card is single-entity; status grid is generic — neither is provider-health matrix IA.

### False-gap notes

- Do **not** call live provider APIs or store API keys.
- Do **not** rebrand Observatory default to OmniRoute teal.
- Do **not** port Recharts for health charts (use existing sparkline if needed).

### Composition notes

- Compose `DSHealthCard` / status dots for cells where fit.
- Matrix header axes (providers vs models/accounts) via simple table/grid layout.

---

## Test Requirements

- MUST render fixture matrix with ≥2 providers and ≥2 cells each (or 2D grid of cells).
- MUST map operational states using `DSOperationalState` (or Prism equivalent).
- MUST support cell tap/selection callback.
- Widget tests: default matrix, empty providers, degraded/error cell styling.
- A11y: grid semantics / cell labels include provider + state.
- Minimal gallery fixture providers (mock OpenAI/Anthropic-style names — no real keys).

---

## Exit Conditions

- [x] `PrismProviderHealthMatrix` exported.
- [x] Tests + minimal gallery PASS.
- [x] Fixture-only; no live health endpoints in package.
- [x] Analyze + scoped tests PASS; boundaries **6/6** after barrel/alias.
- [x] Local changelog under `docs/changelog/`.
- [x] Completion Evidence filled.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read EPIC-16, harvest session synthesis + references triage (OmniRoute health / CyberCore), Task 1600 brief if present, `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart`, `packages/warp_prism_ui/lib/src/organisms/ds_status_grid.dart`, `packages/warp_prism_ui/lib/src/molecules/ds_metric_tile.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_operational_state.dart`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_colors.dart`, `packages/warp_prism_ui/lib/src/tokens/ds_spacing.dart`, `packages/warp_prism_ui/test/health_dashboard_test.dart` if present.
- [x] Define cell/provider models for fixtures.
- [x] Implement matrix layout organism.
- [x] Export alias; tests; gallery.
- [x] **Simplicity pass**: static fixture matrix; no realtime polling in ADS package.
- [x] **Regression verification**: validation commands.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/src/organisms/provider_health_matrix/` | Create — module |
| `packages/warp_prism_ui/lib/src/organisms/provider_health_matrix/ds_provider_health_matrix.dart` | Create |
| `packages/warp_prism_ui/lib/src/molecules/ds_health_card.dart` | Read — compose if fit |
| `packages/warp_prism_ui/lib/src/organisms/ds_status_grid.dart` | Read — false-gap / compose |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Modify — export |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Modify — alias |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Modify — gallery |
| `packages/warp_prism_ui/test/organisms/provider_health_matrix/` | Create — tests |
| `docs/changelog/` | Create — changelog |

### How

1. Fixture data model with operational states.
2. Grid layout with headers; cells show state + optional latency.
3. Export/test/gallery/boundaries.

### Why

Provider health matrix is core CyberCore ops surface and GOLD in references triage; fixture-first unblocks UI while backend lands.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> No API keys, no live provider pings from `warp_prism_ui`.

> [!IMPORTANT]
> Fixture-first CyberCore. Keep WP multi-accent tokens (no global teal rebrand).

> [!WARNING]
> ADS-first. No product route rewrite required for exit.

---

## Validation Commands

```bash
cd packages/warp_prism_ui
dart analyze lib test
flutter test test/organisms/provider_health_matrix/

cd ../..
melos run test-boundaries
```

If Flutter tooling is unavailable, record the exact tooling failure and do not
claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - Created `packages/warp_prism_ui/lib/src/organisms/provider_health_matrix/ds_provider_health_matrix.dart`
  - Created `packages/warp_prism_ui/lib/src/organisms/provider_health_matrix/provider_health_matrix.dart`
  - Created `packages/warp_prism_ui/test/organisms/provider_health_matrix/ds_provider_health_matrix_test.dart`
  - Modified `packages/warp_prism_ui/lib/src/organisms/organisms.dart` (append export)
  - Modified `packages/warp_prism_ui/lib/src/prism_aliases.dart` (aliases + fixture helpers)
  - Modified `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` (gallery case)
  - Created `docs/changelog/2026-07-11-task-1607-provider-health-matrix-organism.md`
- **Public API name verified**: `PrismProviderHealthMatrix` via `package:warp_prism_ui/warp_prism_ui.dart` → `prism_aliases.dart` typedef → `DSProviderHealthMatrix`
- **Tests or validation commands**:
  - `dart analyze lib/src/organisms/provider_health_matrix lib/src/prism_aliases.dart lib/src/organisms/organisms.dart test/organisms/provider_health_matrix` → **No issues found** (exit 0)
  - `flutter test test/organisms/provider_health_matrix/` → **13/13 PASS** (exit 0)
  - `dart analyze lib test` → exit 0 (infos only; pre-existing residuals elsewhere)
- **Boundary harness**: `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` → **6/6 PASS** (exit 0). Note: `melos` CLI not on PATH; pure Dart harness used.
- **Local changelog entry**: `docs/changelog/2026-07-11-task-1607-provider-health-matrix-organism.md`
- **Agent-wiki / docs institutionalization**: N/A
- **Executor**: gt-flutter-engineer (builders)
- **Completion date**: 2026-07-11
- **Lane note**: Remains in `02-doing/` with Review State **Ready For Review** (no git; no lane promote to `03-review`).

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract.

### Latest Review — final gate 2026-07-17

- **Date**: 2026-07-17
- **Reviewer profile**: `reviewers` (final gate)
- **Score**: `94/100`
- **Verdict**: `APPROVED_PATH_TO_100`
- **Full report**: `docs/reports/review/1607-provider-health-matrix-final-gate-2026-07-17.md`
- **Lane outcome**: `accept-completed` (restore to `docs/tasks/04-completed/`)
- **Task reference**: Task 1607

#### Current Open Blockers

- `PERSISTENT` — **FMT-1607**: 1 lib file fails dart format (-2; recoverable).
- `PERSISTENT` (optional) — **I1**: table/grid semantic role polish.

#### Path-to-100 Summary

- `dart format` provider_health_matrix lib file; re-probe exit 0 (2 points recoverable).
- Optional: semantic table/grid role; DSHealthCard micro-layout.

### Previous Reports

- `2026-07-17` — `94/100` — `docs/reports/review-wave-2026-07-17/task-1607-drain-review.md` (AI-141 SUPERSEDED; FMT-EPIC16 added)
- `2026-07-16` — `84/100` — `docs/reports/review/1607-provider-health-matrix-quality-gate-2026-07-16.md` (AI-141 auto-reject)
- `2026-07-11` — `96/100` — `docs/reports/review-wave-2026-07-11/task-1607-independent-review.md`
  - **Carried forward**: I1 (table semantics), I2 (aggregate override fixture)
  - **Regression guard**: format debt FMT-1607 introduced; carry until resolved

### Regression Guards
