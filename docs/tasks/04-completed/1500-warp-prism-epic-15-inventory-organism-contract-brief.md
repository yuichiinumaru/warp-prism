# Task 1500: EPIC-15 Inventory + Organism Contract Brief

> **Status**: `[x]` Done (independent review held in `03-review/`)
> **Review State**: `Held In Review (path-to-100 residual notes)`
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-15 (`docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`) + harvest reports `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
> **Blocks**: Task 1501–1523 (inventory lock for the full EPIC-15 open set)
> **Depends on**: N/A
>
> **Note**: Downstream hard edges are per-task (e.g. 1513→1512, 1518→1517, 1520→1519→1521).
> Soft edges to Task 1501 are documented on 1503/1509/1512/1514/1516 so waves can fan out.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1500` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Produce a locked **EPIC-15 organism inventory brief** that freezes the skip list,
maps each harvest organism ID (O-01–O-28) to a reserved Task 15NN, documents the
public `Prism*` naming contract, gallery registration expectations, and binary
acceptance criteria so builders implement without re-litigating harvest scope.

## Background Context

### What already exists

- Active epic: `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`.
- Harvest reports (2026-07-10):
  - `docs/reports/ads-organism-harvest-unified-2026-07-10.md`
  - `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`
  - `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`
- Existing ADS organisms barrel: `packages/warp_prism_ui/lib/src/organisms/organisms.dart`.
- Public Prism aliases: `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Gallery registry/sections: `packages/warp_prism_ui/lib/src/gallery/`.
- EPIC-13 public-contract hardening tasks (1301–1309) define barrel/alias/golden expectations.
- Already covered organisms listed in epic (do not re-task): `DSShell`, `DSSidebar`, `DSTopbar`, `DSDetailInspector`, `DSGraphCanvas`, `DSTimeline`, `DSLaneBoard`, `DSLogViewer`, `DSCommandPalette`, `DSDataTable`, tab/split/virtual-scroll/status-grid/toast/error-boundary.

### What is missing or broken

- No single builder-facing inventory brief that freezes O-ID → Task → `Prism*` name → wave.
- Skip list is in epic/reports but not restated as a gate for Task 1501–1523 executors.
- Gallery section ID plan and expected golden families for EPIC-15 not codified in one place.
- Dependency soft-vs-hard edges (e.g. Layer panel vs HUD layout slot) need explicit notes.

### Architect resolution notes (document in brief)

- **Naming**: public `Prism*`; internal `DS*` + typedef aliases matching current ADS pattern unless EPIC-13 remediations already require Prism-native classes.
- **Gallery strategy**: each organism task registers a **minimal** gallery case; Task 1519 audits cross-section completeness and catalog ordering.
- **Product routes**: ADS-first — Observatory Map route integration is out of scope for organism exit.
- **Deferred mesh (O-23)**: explicitly **not** tasked in 1500–1523; remains P2 backlog outside this promotion set.
- **Stage chrome pack**: O-11/O-12/O-13 delivered as Task 1509 multi-organism pack (three public names).

---

## Test Requirements

- Brief MUST list every O-01–O-22 and O-24–O-28 with: proposed `Prism*` name, task ID (or deferred), wave, origin paths, skip/false-gap notes.
- Brief MUST include explicit **skip list** matching epic Non-Goals (MapLibre port, mesh crypto, megafile copies, live keys).
- Brief MUST include a **public contract checklist**: barrel export, `Prism*` alias, gallery section id scheme, test path scheme, changelog expectation.
- Brief MUST include wave dependency graph A→H and cross-cutting 1519→1520→1521.
- Brief MUST be discoverable under `docs/reports/` or `docs/tasks/00-planning/` with EPIC-15 in the title.

---

## Exit Conditions

- [x] Inventory brief markdown file exists (recommended path: `docs/reports/epic-15-organism-contract-brief-2026-07-10.md` or dated equivalent).
- [x] O-ID ↔ Task 15NN ↔ `Prism*` mapping table is complete for all promoted tasks 1501–1523.
- [x] Skip list and already-covered organisms are frozen with “do not re-implement” language.
- [x] Gallery registration + golden family expectations documented for Task 1519/1520.
- [x] Soft dependency notes recorded for 1503/1509/1512/1514/1516 vs Task 1501.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md`, `docs/reports/ads-organism-harvest-unified-2026-07-10.md`, `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md`, `docs/reports/ads-organism-harvest-osiris-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `docs/tasks/00-planning/EPIC-13-warp-prism-ads-public-contract-and-catalog-hardening.md`, `docs/tasks/000-template.md`.
- [x] Inventory current organisms directory tree and barrel exports; list already-covered composites.
- [x] Build O-ID mapping table to Task 1501–1523 and note deferred O-23 (mesh) outside set.
- [x] Freeze skip list and false-gap notes from harvest reports.
- [x] Document public API contract (Prism alias, organisms barrel, gallery section ids, test locations).
- [x] Document validation command expectations (`dart analyze`, scoped `flutter test`, `melos run test-boundaries` 6/6).
- [x] Write the brief under `docs/reports/` (or planning) and cross-link from EPIC-15 references if editing epic is approved; otherwise only create the report and link from Completion Evidence.
- [x] **Simplicity pass**: brief is a map, not a redesign essay; prefer tables.
- [x] **Regression verification**: confirm every Task 1501–1523 file in `01-open/` is referenced; flag numbering gaps.

### Where

| File | Purpose |
| --- | --- |
| `docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md` | Read — canonical epic |
| `docs/reports/ads-organism-harvest-unified-2026-07-10.md` | Read — unified harvest |
| `docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md` | Read — ShadowBroker harvest |
| `docs/reports/ads-organism-harvest-osiris-2026-07-10.md` | Read — Osiris harvest |
| `packages/warp_prism_ui/lib/src/organisms/` | Read — current organism inventory |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Read — barrel |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read — public alias pattern |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Read — section registration |
| `docs/reports/epic-15-organism-contract-brief-2026-07-10.md` | Create — inventory + contract brief |
| `docs/changelog/` | Create — local changelog note for Task 1500 |

### How

1. Diff harvest idea catalog against `organisms.dart` to confirm no accidental duplicates.
2. Tabulate O-01–O-28 → task/wave/priority/public name/origin paths.
3. Write skip list and composition-not-fork rules.
4. Publish brief; do not implement widgets in this task.

### Why

Without a locked inventory, parallel builders will re-argue scope, re-port engines, or re-create shell organisms. This governance task is the anti-drift lock for the entire EPIC-15 wave set.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not implement Flutter widgets in Task 1500. Do not open product routes.
> Do not expand scope to molecule/atom extraction epics.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Brief language must
> forbid MapLibre ports and live key usage.

---

## Validation Commands

```bash
# Governance / docs only — still verify paths exist
test -f docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md
test -f docs/reports/ads-organism-harvest-unified-2026-07-10.md
ls packages/warp_prism_ui/lib/src/organisms/
# After brief is written:
test -f docs/reports/epic-15-organism-contract-brief-2026-07-10.md
# Optional: confirm open tasks 1501-1523 exist when this closes after promotion
ls docs/tasks/01-open/15*.md 2>/dev/null | wc -l
```

If Flutter tooling is unavailable, that does **not** block this governance task;
path existence checks are sufficient.

---

## Completion Evidence

- **Files created/modified**:
  - **Created**: `docs/reports/epic-15-organism-contract-brief-2026-07-10.md` (423 lines) — locked O-ID↔Task↔Prism\* inventory, skip list, already-covered list, wave graph A→H, soft/hard deps, public contract checklist, gallery section ID scheme, golden family expectations for 1519/1520.
  - **Created**: `docs/changelog/2026-07-10-task-1500-epic-15-organism-contract-brief.md`
  - **Modified**: this task file (status, checkboxes, Completion Evidence). Left in `02-doing/` for independent review (not moved to `03-review/`).
- **Tests or validation commands** (all PASS):
  ```text
  test -f docs/tasks/00-planning/EPIC-15-warp-prism-ads-organism-expansion-from-reference-harvest.md  → EPIC15_OK
  test -f docs/reports/ads-organism-harvest-unified-2026-07-10.md                                    → UNIFIED_OK
  test -f docs/reports/ads-organism-harvest-shadowbroker-2026-07-10.md                               → SB_OK
  test -f docs/reports/ads-organism-harvest-osiris-2026-07-10.md                                     → OSIRIS_OK
  test -f docs/reports/epic-15-organism-contract-brief-2026-07-10.md                                 → BRIEF_OK
  ls packages/warp_prism_ui/lib/src/organisms/                                                       → existing barrel tree listed
  ls docs/tasks/01-open/15*.md | wc -l                                                               → 23 (Tasks 1501–1523)
  for n in 1501..1523: file exists                                                                  → no numbering gaps
  ```
  Flutter tooling not required for this governance task.
- **Local changelog entry**: `docs/changelog/2026-07-10-task-1500-epic-15-organism-contract-brief.md`
- **Agent-wiki / docs institutionalization**: N/A (governance brief under `docs/reports/` is the durable lock; no agent-wiki edit per builder rules)
- **Brief link for downstream builders**: `docs/reports/epic-15-organism-contract-brief-2026-07-10.md`
- **Regression notes**:
  - O-23 (`PrismMeshCommsPanel`) deferred outside 1500–1523.
  - O-25 (`PrismDisplayConfigChrome`) not tasked (1522 may skip REC strip).
  - Continuous task band 1500–1523; reserved 1524–1529 unused.
  - Epic file not edited (cross-link only from Completion Evidence / changelog per task How).
- **Executor**: gt-flutter-engineer (builder worker under parent agentID=builders)
- **Completion date**: 2026-07-10

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-11
- **Reviewer profile**: `reviewers` (gt-code-quality-reviewer)
- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-11/task-1500-independent-review.md`
- **Lane outcome**: moved to `docs/tasks/03-review/`
- **Task reference**: Task 1500 (`1500-warp-prism-epic-15-inventory-organism-contract-brief`)

#### Current Open Blockers

- none (no blocking findings)

#### Path-to-100 Summary

- Fix brief §7 public-name count **23 → 22** (non-optional `Prism*` across 1501–1518).
- Freeze O-28 public-name language (`PrismRiskAlertToastVariant` **or** explicit `n/a — toast variant only`).

### Previous Reports

### Re-Review 2026-07-16 — adversarial gate (implacable reviewer)

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers`
- **Score**: `98/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Full report**: `docs/reports/review/task-1500-epic15-adversarial-review-2026-07-16.md`
- **Lane outcome**: remains in `03-review/`

#### Re-review summary
- **F1 RESOLVED** (brief §7 count 22; reviewer direct patch)
- **F2 RESOLVED** (O-28 frozen `n/a — toast system variant only`; reviewer direct patch)
- **NEW FI1** — shared `dart format` drift across EPIC-15 warp_prism_ui files (−2); not Task 1500 specific
- Tasks 1501–1523 integrity confirmed; 1500 governance paths all PASS; brief patches applied

#### Path-to-100
1. Apply `dart format` across `packages/warp_prism_ui` before EPIC-15 wave closeout (shared surface).
2. Reviewer patches (count 22, O-28 freeze) already applied 2026-07-16.

### Previous Reports

- 2026-07-11 — 96/100 — `docs/reports/review-wave-2026-07-11/task-1500-independent-review.md`
  - **Carried forward**: F1 (count)→RESOLVED; F2 (O-28 freeze)→RESOLVED
  - **Regression guard**: brief §7 count=22; O-28=`n/a — toast system variant only`

### Independent drain review — 2026-07-17 (gt-flutter-code-reviewer + code-quality-harness)
- **Score**: `99/100` (prior draft 96)
- **Verdict**: `ACCEPTED_WITH_PATH_TO_100`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1500-drain-review.md`
- **Live proof**: brief public-name count fixed to **22**; mapping/skip/soft-deps hold
- **Lane**: moved `03-review/` → `04-completed/`

---

### 2026-07-18 — builders path-to-100 residual batch5

| Field | Value |
| --- | --- |
| **Wave** | path-to-100-wave-2026-07-17 / batch5 |
| **Executor** | builders (parent agentID=builders) |
| **Lane** | remain `docs/tasks/03-review/` (no lane move; no git/tasklist) |
| **Notes** | `docs/reports/path-to-100-wave-2026-07-17/batch5-notes.md` |

**Residuals applied**: frozen proposed O-28 public name `PrismRiskAlertToastVariant` (optional; no required typedef until 1522) in master O-ID table of epic-15 contract brief.
**Remaining**: none task-scope (optional Wave I still deferred).



---

### 2026-07-18 — independent path100 re-review (BATCH R5 / reviewers)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | ACCEPTED_COMPLETED |
| **path-to-100 applied** | YES |
| **Lane** | `04-completed/` |
| **Report** | `docs/reports/review-wave-2026-07-18/task-1500-path100-rereview.md` |
| **Top finding** | None |
| **Exits** | brief O-01–O-28; skip list; soft-deps; O-28 name freeze |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved after batch5 residual wave |
