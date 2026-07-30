# Task 1600: EPIC-16 Inventory + Catalog Showability Brief

> **Status**: `[x]` Done (independent review held in `03-review/`)
> **Review State**: `Held In Review (path-to-100 residual notes)`
> **Priority**: 🔴 P0
> **Type**: `governance`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: Task 1601–1616 (inventory lock for the full EPIC-16 open set)
> **Depends on**: N/A
>
> **Note**: Downstream hard edges are per-task (e.g. 1613→1602–1609, 1614→1613, 1615→1614).
> Soft edges: 1602/1603 → 1600 only; 1604–1611 soft-depend 1600 (+ soft 1601 for gallery polish).
> EPIC-15 (1500–1523) is **SEPARATE** — do not recreate Map HUD organisms here.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1600` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Produce a locked **EPIC-16 organism inventory + catalog showability brief** that freezes the skip list, maps each idea-catalog ID (C-01–C-13) to reserved Tasks 1600–1616, documents public `Prism*` naming, gallery/catalog demo path expectations, fixture-first CyberCore rules, and binary acceptance so builders implement without re-litigating harvest scope or EPIC-15 overlap.

## Background Context

### What already exists

- Active epic: `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`.
- Harvest synthesis (2026-07-10):
  - `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`
  - `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`
  - `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`
  - `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
- ADS organisms barrel: `packages/warp_prism_ui/lib/src/organisms/organisms.dart`.
- Public Prism aliases: `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
- Gallery registry/sections: `packages/warp_prism_ui/lib/src/gallery/`.
- Catalog host app: `apps/catalog/` (thin shell → `DesignSystemGalleryPage`).
- README already documents `cd apps/catalog && flutter run` (Task 1601 verifies/polish).
- EPIC-15 open set (1500–1523) owns Map HUD / OSINT / stage chrome — **out of EPIC-16 scope**.

### What is missing or broken

- No single builder-facing inventory brief freezing C-ID → Task → `Prism*` → wave.
- Skip list (no teal Observatory rebrand, no MapLibre/Recharts/Widgetbook, no EPIC-15 duplicates) not restated as a gate for 1601–1616 executors.
- Gallery section ID plan and golden families for EPIC-16 not codified in one place.
- Catalog showability path (README + demo one-pager + section TOC) needs a frozen expectation for Task 1601.

### Architect resolution notes (document in brief)

- **Naming**: public `Prism*`; internal `DS*` + typedef aliases in `prism_aliases.dart` matching ADS pattern.
- **Gallery strategy**: each organism task registers a **minimal** gallery case; Task 1613 audits cross-section completeness.
- **Product routes**: ADS-first — CyberCore/Observatory product route integration out of scope for organism exit.
- **Fixture-first**: all CyberCore-facing organisms (health, MCP, traffic, timing, transcript) use local fixtures only.
- **Optional 1616**: CyberCore teal ThemeExtension skin — **not** Observatory default; may remain deferred.
- **Hygiene 1612**: governance/docs/checklist + optional small test helpers — **not** a judatop widget port.

---

## Test Requirements

- Brief MUST list every C-01–C-13 with: proposed `Prism*` name(s), task ID (or deferred), wave, origin harvest paths, skip/false-gap notes.
- Brief MUST include explicit **skip list**: OmniRoute teal Observatory rebrand; Orbitron/scanlines; MapLibre; Recharts; Widgetbook; mesh crypto; live keys; mutation ALLOW/BLOCK; EPIC-15 O-01–O-22 duplicates; login/product pages from villa/judatop.
- Brief MUST include **public contract checklist**: barrel export, `Prism*` alias, gallery section id scheme, test path scheme, changelog, `melos run test-boundaries` 6/6 after barrel changes.
- Brief MUST include wave dependency graph V/J/K/L/M/N/X and cross-cutting 1613→1614→1615.
- Brief MUST document catalog showability: `apps/catalog` command, gallery registry path, optional `docs/demo` or `docs/reports` one-pager expectation for Task 1601.
- Brief MUST be discoverable under `docs/reports/` with EPIC-16 in the title.

---

## Exit Conditions

- [x] Inventory brief markdown exists (recommended: `docs/reports/epic-16-organism-contract-brief-2026-07-10.md` or dated equivalent).
- [x] C-ID ↔ Task 16NN ↔ `Prism*` mapping table complete for tasks 1601–1616.
- [x] Skip list and EPIC-15 non-overlap notes frozen with “do not re-implement” language.
- [x] Gallery registration + golden family expectations documented for Task 1613/1614.
- [x] Soft dependency notes recorded for parallel waves (1602/1603 on 1600 only; 1605 soft on 1604).
- [x] Catalog showability expectations frozen for Task 1601.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff.

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`, `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`, `packages/warp_prism_ui/lib/src/organisms/organisms.dart`, `packages/warp_prism_ui/lib/src/prism_aliases.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `apps/catalog/lib/main.dart`, `README.md` (catalog run section), `docs/design/token-theme-catalog-policy.md`, `docs/tasks/000-template.md`.
- [x] Inventory current organisms directory tree and barrel exports; list already-covered composites that must not be re-tasked under EPIC-16 names.
- [x] Build C-ID mapping table to Task 1600–1616 and note optional 1616 as skin-only.
- [x] Freeze skip list and false-gap notes (vs EPIC-15 Map HUD / terminal workspace / agent shell panel).
- [x] Document public API contract (Prism alias, organisms barrel, gallery section ids, test locations).
- [x] Document catalog showability path and Task 1601 polish scope (verify smoke, optional TOC, demo one-pager).
- [x] Write the brief under `docs/reports/` and link from Completion Evidence (edit EPIC-16 only if user approves protected planning edits).
- [x] **Simplicity pass**: brief is a map, not a redesign essay; prefer tables.
- [x] **Regression verification**: confirm every Task 1601–1616 file in `01-open/` is referenced; flag numbering gaps.

### Where

| File | Purpose |
| --- | --- |
| `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md` | Read — canonical epic |
| `docs/reports/ads-harvest-session-synthesis-2026-07-10.md` | Read — session synthesis |
| `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md` | Read — OmniRoute visual-ref |
| `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md` | Read — references triage |
| `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md` | Read — judatop/ahmedm hygiene |
| `packages/warp_prism_ui/lib/src/organisms/` | Read — current organism inventory |
| `packages/warp_prism_ui/lib/src/organisms/organisms.dart` | Read — barrel |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read — public alias pattern |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Read — section registration |
| `apps/catalog/lib/main.dart` | Read — catalog host |
| `README.md` | Read — catalog run docs (protected — ask before edit) |
| `docs/reports/epic-16-organism-contract-brief-2026-07-10.md` | Create — inventory + contract brief |
| `docs/changelog/` | Create — local changelog note for Task 1600 |

### How

1. Diff harvest idea catalog (C-01–C-13) against `organisms.dart` and EPIC-15 task names to confirm no accidental duplicates.
2. Tabulate C-01–C-13 → task/wave/priority/public name/origin paths.
3. Write skip list, composition-not-fork rules, fixture-first CyberCore rules.
4. Freeze catalog showability expectations for 1601.
5. Publish brief; do not implement widgets in this task.

### Why

Without a locked inventory, parallel builders will re-argue scope, rebrand Observatory teal, re-port engines, or recreate EPIC-15 HUD organisms under new names. This governance task is the anti-drift lock for the entire EPIC-16 wave set.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not implement Flutter widgets in Task 1600. Do not open product routes.
> Do not expand scope to EPIC-15 Map HUD organisms (1501–1523).

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Brief language must
> forbid MapLibre/Recharts/Widgetbook ports, live keys, and Observatory teal rebrand.

---

## Validation Commands

```bash
# Governance / docs only — still verify paths exist
test -f docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md
test -f docs/reports/ads-harvest-session-synthesis-2026-07-10.md
test -f docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md
test -f docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md
test -f docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md
ls packages/warp_prism_ui/lib/src/organisms/
test -f apps/catalog/lib/main.dart
# After brief is written:
test -f docs/reports/epic-16-organism-contract-brief-2026-07-10.md
# Optional: confirm open tasks 1601-1616 exist when this closes after promotion
ls docs/tasks/01-open/16*.md 2>/dev/null | wc -l
```

If Flutter tooling is unavailable, that does **not** block this governance task;
path existence checks are sufficient.

---

## Completion Evidence

- **Files created/modified**:
  - Created: `docs/reports/epic-16-organism-contract-brief-2026-07-10.md` (locked inventory brief)
  - Created: `docs/changelog/20260710-204831-1600-epic-16-inventory-catalog-showability-brief-gt-flutter-engineer.md`
  - Modified: `docs/tasks/02-doing/1600-warp-prism-epic-16-inventory-catalog-showability-brief.md` (this file — evidence + Ready For Review; lane stays `02-doing/`)
- **Brief path**: `docs/reports/epic-16-organism-contract-brief-2026-07-10.md`
- **Tests or validation commands**:
  ```text
  test -f docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md  → PASS
  test -f docs/reports/ads-harvest-session-synthesis-2026-07-10.md                                    → PASS
  test -f docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md                           → PASS
  test -f docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md                            → PASS
  test -f docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md                                 → PASS
  ls packages/warp_prism_ui/lib/src/organisms/                                                        → PASS (baseline barrel present)
  test -f apps/catalog/lib/main.dart                                                                  → PASS
  test -f docs/reports/epic-16-organism-contract-brief-2026-07-10.md                                  → PASS
  ls docs/tasks/01-open/16*.md | wc -l                                                                → 15 (1602–1616)
  # 1601 currently in 02-doing/ (parallel visibility task); no numbering gap 1600–1616
  ```
  Flutter analyze/test not required for this governance-only task.
- **Local changelog entry**: `docs/changelog/20260710-204831-1600-epic-16-inventory-catalog-showability-brief-gt-flutter-engineer.md`
- **Agent-wiki / docs institutionalization**: N/A (brief under `docs/reports/` is the durable lock)
- **Executor**: gt-flutter-engineer (builder worker under parent agentID=builders)
- **Completion date**: 2026-07-10
- **Lane note**: Builder left file in `02-doing/`; independent reviewer promotes to `03-review/` (no `04-completed`).
- **EPIC-16 planning edit**: Not modified (protected planning; brief is discoverable without epic edit).

---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-16
- **Reviewer profile**: `reviewers` (independent adversarial gatekeeper)
- **Score**: `100/100`
- **Verdict**: `PERFECT`
- **Full report**: `docs/reports/review/1600-epic-16-inventory-catalog-showability-brief-independent-rereview-2026-07-16.md`
- **Lane outcome**: stays in `docs/tasks/03-review/` (100 band; never `04-completed`)
- **Task reference**: Task 1600
- **Delta**: prior F1 (stale lane paths) RESOLVED (filesystem stabilized); prior F2 (informal `PrismStageChrome*` shorthand) PERSISTENT as documentation polish only — no naming integrity threat, no deduction at ceiling

#### Current Open Blockers

- none

#### Path-to-100 Summary

- At ceiling. F2 is documentation polish; may be addressed in a future brief refresh but does not block any downstream task.

### Previous Reports

- `docs/reports/review-wave-2026-07-11/task-1600-independent-review.md` — initial independent review 2026-07-11 (S=98)

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | PERFECT |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1600-drain-review.md` |
| **Top finding** | None |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |
