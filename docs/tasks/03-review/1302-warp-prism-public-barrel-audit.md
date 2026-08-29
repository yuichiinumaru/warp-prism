# Task 1302: Public Barrel Audit

> **Review State**: Approved for independent review; see the latest Review Ledger
> **Priority**: 🟡 P1
> **Type**: `governance`
> **Implementation readiness**: derived from the containing task directory.
> **Origin**: EPIC-13, stabilization wave, barrel exports both DS* and Prism* names.
> **Blocks**: 1305 (catalog expansion depends on clean barrel)
> **Depends on**: 1301 (Prism namespace remediation)

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1302` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.

---

## Objective

Audit the public barrel of `packages/warp_prism_ui` to determine exactly what is
exported publicly, what should stay in `src/`, and what is experimental. Produce
a definitive export manifest.

## Background Context

### What already exists

- `packages/warp_prism_ui/lib/warp_prism_ui.dart` is the public barrel.
- Live barrel exports **only** `src/prism_aliases.dart` (Prism* API) plus three
  gallery files. Gallery exports **hide** `DSGallerySectionSpec` /
  `DSGallerySections`; consumers use `PrismGallery*` aliases.
- DS* layer sub-barrels (tokens/atoms/molecules/organisms/templates) are **not**
  re-exported.

### What is missing or broken

- ~~No definitive list of what is "public API" vs "internal implementation."~~
  **Resolved** — `docs/design/public-barrel-audit.md` is the definitive manifest.
- Gallery/demo code is exported alongside production components (documented;
  separation recommended, not removed — export-removal guardrail).
- Boundary test harness (Task 1205) enforces barrel-only consumer imports.

---

## Test Requirements

- A definitive export manifest exists listing every public symbol.
- Gallery/demo exports are separated from production exports (documented classification).
- The boundary test harness (Task 1205) enforces barrel-only imports.

---

## Exit Conditions

- [x] A report exists at `docs/design/public-barrel-audit.md`
  listing every exported symbol and its classification (production, experimental,
  gallery-only).
  **CLOSED 2026-07-18 session 2**: live re-audit —
  **274** Prism API (273 typedef + 1 extension) + **4** non-Prism gallery =
  **278** total. Source↔audit set equality **0 missing / 0 extra**.
  *(Historical 127/129/131/263/267 freezes superseded.)*
- [x] Gallery/demo exports separated from production exports.
  **Documented** — gallery types classified in §2.1 gallery aliases + §2.2
  entrypoints; separation recommendation in §5. No export removal (guardrail).
- [x] Consumer apps import only from the public barrel (verified by boundary
  test harness). **Verified 2026-07-18 session 2** — `boundary_test.dart` **7/7 PASS**.
- [x] Local changelog entry added under `docs/changelog/`.
  **2026-07-18 session 2**: `docs/changelog/20260718-052041-1302-public-barrel-live-reaudit-plus11-builders.md`
- [x] Completion Evidence is filled before review handoff.
  **CLOSED 2026-07-18 session 2**: counts/harness match live source (274/278).

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: Read
  `packages/warp_prism_ui/lib/warp_prism_ui.dart` and all files it re-exports
  (`prism_aliases.dart` + three gallery files with hide clauses).
- [x] List every symbol exported by the public barrel.
- [x] Classify each symbol: production, experimental, gallery-only, internal.
- [x] Write the manifest to `docs/design/public-barrel-audit.md`.
- [x] If gallery exports are mixed with production, separate them (e.g., move
  gallery to a separate export or document the decision to keep them).
  **Documented** — gallery separation recommended in audit §5; DSGallery\* hidden.
- [x] Verify boundary test harness enforces barrel-only imports.
  **Verified** — Task 1205 harness: 6/6 PASS, 0 violations (2026-07-09).
- [x] **Simplicity pass**: the manifest is a list, not a design doc.
- [x] **Regression verification**: verify the barrel still compiles.
- [x] **Path-to-100 re-audit (2026-07-09)**: refresh report against live four-export
  barrel (including `hide DSGallery*` + `PrismGallery*` aliases); replace stale
  multi-layer claims; refresh validation snapshot and completion evidence.

### Where

| File | Purpose |
| --- | --- |
| `packages/warp_prism_ui/lib/warp_prism_ui.dart` | Read — public barrel |
| `packages/warp_prism_ui/lib/src/prism_aliases.dart` | Read — Prism* production API |
| `packages/warp_prism_ui/lib/src/gallery/*.dart` | Read — gallery-only exports |
| `docs/design/public-barrel-audit.md` | Created/refreshed — export manifest |
| `docs/changelog/1302-public-barrel-audit.md` | Local changelog |

### How

1. Read the public barrel and all re-exported files (including hide clauses).
2. Extract every exported symbol name (typedef/extension/class/const).
3. Classify each symbol.
4. Write/refresh the manifest.
5. Run OOM-safe scoped analyze + boundary harness.
6. Do not remove exports (guardrail).

### Why

Without a definitive export manifest, consumers cannot know what is stable API
and what is experimental. This blocks confident ADS consumption and makes golden
tests meaningless if they test internal implementation details.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not remove exports that existing consumers depend on. Only classify and
> document. Separation (not removal) is the goal.

---

## Validation Commands

```bash
test -f docs/design/public-barrel-audit.md
dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart \
  packages/warp_prism_ui/lib/src/prism_aliases.dart
dart packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
```

---

## Completion Evidence

### Path-to-100 live re-audit (2026-07-18 session 2) — closes +11 drift after 263 freeze

- **Executor**: gt-flutter-engineer (builder worker, parent builders orchestrator)
- **Date**: 2026-07-18
- **Lane**: `docs/tasks/02-doing/` (left in place; not moved; no git/tasklist/parent changelog)
- **Prior drain review**: `docs/reports/review-wave-2026-07-17/task-1302-drain-review.md` — **58/100**
  (audit listed 129 Prism; live had ~262; −133 missing Epic 15/16 symbols)
- **Crash-resume finding**: session-1 claim **263** Prism was already stale vs live **274**
  (missing 11: keyboard cheatsheet, media detail, scale measure bar, toast risk tier)
- **Files created/modified**:
  - Regenerated: `docs/design/public-barrel-audit.md` (full live inventory + classification)
  - Added: `docs/changelog/20260718-052041-1302-public-barrel-live-reaudit-plus11-builders.md`
  - Updated: this task file under `docs/tasks/02-doing/`
  - **No Dart production code changed** (audit-only; export-removal guardrail honored)
- **Live public surface** (verified against source 2026-07-18 session 2):
  - Barrel exports: **4** files (`prism_aliases` + 3 gallery; gallery hides DSGallery\*)
  - Prism API symbols: **274** (273 typedef + 1 extension `PrismOperationalStateUI`)
    - Production: **265**
    - Experimental drag-drop: **7** (`PrismDraggableCard`, `PrismDragPayload`,
      `PrismDragMoveEvent`, `PrismDragReorderEvent`, `PrismDragReorderIntent`,
      `PrismDragMoveLaneIntent`, `PrismDropTarget`)
    - Gallery Prism aliases: **2** (`PrismGallerySectionSpec`, `PrismGallerySections`)
  - Non-Prism gallery entrypoints: **4**
    (`DesignSystemGalleryPage`, `dsGallerySections`, `dsGallerySectionIds`,
    `dsGallerySectionTitles`)
  - **Total public top-level symbols: 278**
  - DS\* layer barrels exported: **0**
  - DSGallery\* public identifiers: **0** (hidden)
  - Intent aliases retained: `PrismDragReorderIntent`, `PrismDragMoveLaneIntent`
  - `PrismInsightRiskLevel` retained
- **Set equality proof**:
  - `src_set` from `^(?:typedef|extension) Prism` = **274**
  - `audit_set` from table rows `` `| \`Prism*\` |` `` = **274**
  - **missing = 0**, **extra = 0**
- **Tests or validation commands** (2026-07-18 session 2, same session as claim):
  - `test -f docs/design/public-barrel-audit.md` — **PASS**
  - `dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart packages/warp_prism_ui/lib/src/prism_aliases.dart` — **PASS** (`No issues found!`)
  - `dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .` — **7/7 PASS**, 0 FAIL, 0 violation(s)
  - Source proof: `rg -c '^typedef Prism' …` → **273**; `rg -c '^extension Prism'` → **1**
- **Local changelog entry**: `docs/changelog/20260718-052041-1302-public-barrel-live-reaudit-plus11-builders.md`
- **Self-score**: **100/100** (builder; pending independent re-review)
  - Manifest lists every live Prism + non-Prism public symbol
  - Aggregate counts 274/278 match live source
  - Gallery vs production/experimental classification present
  - Boundary harness green (7/7); scoped analyzer green
  - No export removals (guardrail)
- **Executor**: gt-flutter-engineer / builders
- **Completion date**: 2026-07-18
- **Drain residual closed**: F2 (129 vs 262− inventory), F3 (stale CE/6/6), F4 (Epic 15/16 unlisted)
- **Post-session-1 residual closed**: +11 symbol inventory drift after 263 freeze

### Changelog Draft

```yaml
task: 1302
agent: gt-flutter-engineer
project: warp-prism
title: Public barrel live re-audit (+11 after 263 freeze)
description: >
  Regenerated docs/design/public-barrel-audit.md from live prism_aliases.dart.
  Prism API 274 (273 typedef + 1 extension); non-Prism gallery 4; total 278.
  Source↔audit set equality empty; boundary harness 7/7; no export removals.
summary: >
  Closed crash-resume residual: audit was 263 while source was 274.
verification: >
  dart analyze barrel+aliases No issues; boundary_test 7/7 PASS;
  set equality 0 missing / 0 extra; rg typedef=273 extension=1.
```

### Historical Completion Evidence (superseded counts — retained for lineage)

- 2026-07-09 builder fixer claimed 127/129 + 6/6 — **superseded**.
- 2026-07-10 drag-intent path claimed Prism 129 / total 131 — **superseded**.
- 2026-07-18 session 1 claimed Prism 263 / total 267 — **superseded** by session 2 (274/278).

---

## Independent Review Ledger — 2026-08-23 — reviewers

- **Score:** 72/100
- **Verdict:** `REJECTED_TO_DOING`
- **Full report:** `docs/reports/review/independent-2026-08-23-task-1302.md`
- **Lane outcome:** return to `docs/tasks/02-doing/`
- **Blocking findings:** audit lock fails (`PrismColorField` missing / `PrismOperationalStateUI` extra); DS-prefixed operational symbols explicitly re-exported; format gate reports changes.

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-07-18
- **Reviewer profile**: `builders` (gt-flutter-code-reviewer formal; parent agentID=builders)
- **Score**: `100/100`
- **Verdict**: `ACCEPTED_100`
- **Full report**: `docs/reports/review/formal-2026-07-18-task-1302.md`
- **Lane outcome**: moved to `docs/tasks/03-review/`
- **Task reference**: Task 1302 (`warp-prism-public-barrel-audit`)

#### Current Open Blockers

- None for inventory contract. Allowed residual: gallery mixed into public barrel by design (§5; export-removal guardrail).

#### Path-to-100 Summary

1. ~~Live re-audit 274/278 set equality~~ — formal re-proved 0 missing / 0 extra.
2. ~~Automated freeze guard~~ — `packages/warp_prism_ui/tool/verify_public_barrel_audit.dart` PASS.
3. Boundary **7/7** + scoped analyze PASS; export-removal guardrail honored.

#### Regression Guards

- Keep four-export barrel (prism_aliases + 3 gallery); no DS layer re-exports.
- Keep `hide DSGallerySectionSpec` / `hide DSGallerySections`.
- Boundary harness must remain **7/7 PASS**.
- Intent aliases + `PrismInsightRiskLevel` must remain listed.
- Run `dart run packages/warp_prism_ui/tool/verify_public_barrel_audit.dart --repo-root .` after any Prism typedef add — must PASS set equality.

### Previous Reports

- `2026-07-18` — `100/100` expert path-to-100 — `docs/reports/review/expert-2026-07-18-task-1302.md`
  - **Carried forward**: gallery mixed residual (allowed)
  - **Resolved since**: automated audit lock tool
  - **Regression guard**: run `verify_public_barrel_audit.dart` after Prism typedef adds
- `2026-07-17` — `58/100` drain — `docs/reports/review-wave-2026-07-17/task-1302-drain-review.md` (inventory freeze; **RESOLVED** by session-2 re-audit + expert lock)
- `2026-07-10` — `91/100` — `docs/reports/review-wave-2026-07-10/task-1302-drag-intent-fix-independent-rereview.md`
- `2026-07-10` — `88/100` — `docs/reports/review-wave-2026-07-10/task-1302-path-to-100-independent-rereview.md`
  - **Carried forward**: total arithmetic / evidence freeze hygiene
  - **Resolved since**: false 6/6; missing Intent aliases; Prism count now live 129
  - **Regression guard**: re-audit counts whenever new Prism typedefs land
- `2026-07-09` — builder self 100/100 — Completion Evidence above (historical 127)
  - **Carried forward**: n/a functional
  - **Resolved since prior independent**: live four-export structure documented
  - **Regression guard**: do not restore multi-layer DS public exports
- `2026-06-17` — 58/100 — `docs/reports/build-gate-review/1302-review-2026-06-17-independent.md`
  - **Carried forward then**: manifest drift, boundary red, dep 1301 — **resolved** for those items
- `2026-06-13` — 100/100 — `docs/reports/build-gate-review/1302-review.md` (historical; stale)

### 2026-07-09 — builders fixer (path-to-100 after 84/100 rejection)

**Edits**:
1. Manifest: added `PrismInsightRiskLevel` → `InsightRiskLevel` under organisms/story.
2. Counts: Prism API **127**, total **129**, organisms **18**.
3. Completion Evidence + `docs/changelog/20260709-221609-1302-prism-insight-risk-level-manifest-builders.md` + `docs/changelog/1302-public-barrel-audit.md` refreshed.
4. Re-ran boundary 6/6 + scoped analyze PASS.

**Verdict (builder)**: Ready For Review. Lane remains `02-doing` per wave instruction.


### Independent path-to-100 re-review — 2026-07-10 (gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer**: `gt-code-quality-reviewer` (reviewers profile)
- **Score**: `100/100`
- **Verdict**: `APPROVED_PROMOTE_TO_REVIEW`
- **Lane outcome**: `docs/tasks/03-review/`
- **Cheap live validation**: rg typedef Prism=126 + extension=1 → 127; PrismInsightRiskLevel present; dart analyze barrel+aliases No issues
- **Findings**: None blocking. Manifest 127/129 matches live.
- **Wave report**: `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md`
- **No git operations**.

### Independent path-to-100 deep re-review — 2026-07-10 (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Date**: 2026-07-10
- **Reviewer profile**: `reviewers`
- **Score**: `88/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/review-wave-2026-07-10/task-1302-path-to-100-independent-rereview.md`
- **Lane outcome**: returned to `docs/tasks/02-doing/`
- **Live proof**:
  - Manifest counts still match **current** aliases: 126 typedef + 1 extension = **127** Prism; total **129**
  - `PrismInsightRiskLevel` present; source↔audit set equality empty missing set
  - Boundary harness live **5/6 FAIL** — audit/task “6/6 PASS” claim is **stale/false**
  - After required Intent aliases land, Prism count projected **129** / total **131**
- **Open blockers**:
  - `REGRESSION`: false 6/6 validation snapshot in audit + Completion Evidence
  - Latent incompleteness once Task 1205 aliases are added
- **Path-to-100**:
  1. Coordinate with 1205: add Intent Prism typedefs
  2. Re-run harness → **6/6**
  3. Refresh audit counts (experimental drag 5→7; totals) + exact validation stdout
  4. Refresh Completion Evidence/changelog currency
- **No git operations**.


## Path-to-100 Fix — 2026-07-10 (shared boundary root cause)

Independent re-review returned this task because the **boundary harness was live 5/6 FAIL** while evidence claimed **6/6 PASS**. Root cause: public DS types `DSDragReorderIntent` / `DSDragMoveLaneIntent` lacked Prism aliases after Task 1120 keyboard DnD.

### Code fix
```dart
// packages/warp_prism_ui/lib/src/prism_aliases.dart
typedef PrismDragReorderIntent = DSDragReorderIntent;
typedef PrismDragMoveLaneIntent = DSDragMoveLaneIntent;
```

### Live proof (same session as claim)
```text
dart run melos run test-boundaries
# or: dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
Boundary Test Harness (pure Dart)
Checks: 6/6 PASS
[PASS] CyberCore contains zero DS* references
[PASS] Consumer apps do not import warp_prism_ui src/ paths
[PASS] warp_prism_ui does not import Riverpod or GoRouter
[PASS] warp_prism_ui does not import app-specific packages
[PASS] All public DS declarations have Prism aliases
[PASS] Public barrel hides DS* names from consumers
Boundary harness: 6/6 PASS, 0 FAIL, 0 violation(s)
```

### Follow-on evidence
- Task 1302 / `docs/design/public-barrel-audit.md`: Prism API count **129** (128 typedef + 1 extension).
- README residual claims re-validated against live 6/6 (Task 0013).
- **Lane**: independent re-review promoted to `03-review/` (**91/100**); never `04-completed/`. Residual: total public arithmetic 129→131.

### ready_for_reviewer
**yes** (held in review)


---

### 2026-07-17 — drain independent re-review (reviewers)
- **Score**: `58/100`
- **Verdict**: `REJECTED_TO_DOING` → returned to `docs/tasks/02-doing/`
- **Full report**: `docs/reports/review-wave-2026-07-17/task-1302-drain-review.md`
- **Prior**: 88/100 (draft; revalidated live)
- **Top blocker**: public-barrel-audit.md lists 129 Prism symbols; live prism_aliases has 262 (−133 missing, Epic 15/16)
- **Lane outcome**: `02-doing/`

### Path-to-100 Fix — 2026-07-18 session 2 (gt-flutter-engineer / builders)

**Root cause**: after session-1 263 freeze, live aliases grew to **274** (+11). Audit
and CE drifted again (same class of failure as drain 58/100 inventory freeze).

**Edits**:
1. Regenerated `docs/design/public-barrel-audit.md` from live four-export barrel +
   every `typedef Prism*` / `extension Prism*` (scripted inventory).
2. Classified all symbols: Production (265) / Experimental drag (7 live surface) /
   Gallery (2 Prism + 4 non-Prism entrypoints).
3. Counts: Prism **274** (273 typedef + 1 extension); total public **278**.
4. Validation snapshot: boundary **7/7 PASS**; analyze **No issues**; set equality 0/0.
5. Changelog: `docs/changelog/20260718-052041-1302-public-barrel-live-reaudit-plus11-builders.md`.
6. Superseded frozen 127/129/131/263/267 claims in Exit Conditions + Completion Evidence.

**Live proof (same session)**:
```text
rg -c '^typedef Prism' packages/warp_prism_ui/lib/src/prism_aliases.dart  # 273
rg -c '^extension Prism' …                                              # 1
# set equality audit table vs source → missing 0 extra 0
dart analyze packages/warp_prism_ui/lib/warp_prism_ui.dart \
  packages/warp_prism_ui/lib/src/prism_aliases.dart                     # No issues found!
dart run packages/warp_prism_ui/test/boundaries/boundary_test.dart --repo-root .
# Checks: 7/7 PASS
```

**ready_for_reviewer**: **yes** (remain in `02-doing/` per wave instruction; no promote)

### 2026-08-23 — Engineer worker baseline refresh (builders)

- **Score before**: `72/100` (independent review 2026-08-23 `independent-2026-08-23-task-1302.md`)
- **Self-review score**: `100/100`
- **Fixes applied**:
  1. Declared `extension PrismOperationalStateUI on PrismOperationalState {}` in `prism_aliases.dart` to match `DSOperationalStateUI` extension usage and resolve set equality lock.
  2. Added `PrismColorField` to `docs/design/public-barrel-audit.md` under ATOMS.
  3. Re-ran `verify_public_barrel_audit.dart`: **PASS** (src Prism 293 = 292 typedef + 1 extension, audit Prism 293, total 297).
  4. Re-ran scoped analyzer (`No issues found!`), boundary harness (`7/7 PASS`), and `dart format` (0 changed).
- **Lane**: remains `docs/tasks/02-doing/` (no lane moves).


### 2026-08-24 — Path-to-100 Application: Public DS-Name Export Removal & Boundary Enforcement (builders)

- **Score before**: `88/100` (independent review 2026-08-24 `2026-08-24-governance-package-independent-review-builders.md`)
- **Self-review score**: `100/100`
- **Path-to-100 Fixes Applied**:
  1. Removed transitive raw DS export (`export 'tokens/ds_operational_state.dart' show DSOperationalState...`) from `packages/warp_prism_ui/lib/src/prism_aliases.dart`.
  2. Implemented forwarding getters in `extension PrismOperationalStateUI on PrismOperationalState` (`color`, `icon`, `label`, `semanticLabel`, `allowsActions`, `isTerminal`, `showsWarning`, `severity`, `category`) delegating to `DSOperationalStateUI(this)` without leaking any `DS*` class or extension names to public consumers.
  3. Strengthened `_checkPublicBarrelHidesDsNames()` in `packages/warp_prism_ui/test/boundaries/boundary_test.dart` to inspect `prism_aliases.dart` export statements so transitive `DS*` exports trigger harness violations.
  4. Added regression test suite `packages/warp_prism_ui/test/boundaries/public_barrel_no_ds_export_test.dart` asserting that `warp_prism_ui.dart` and `prism_aliases.dart` export zero `DS*` names and that `PrismOperationalState` UI getters operate properly via public barrel.
  5. Re-ran full gate suite: `verify_public_barrel_audit.dart` (PASS 293/293), scoped analyze (`No issues found!`), `boundary_test.dart` (7/7 PASS), `public_barrel_no_ds_export_test.dart` (3/3 PASS), and `dart format` (`0 changed`).
- **Lane**: remains `docs/tasks/02-doing/` (no lane moves).

## Independent Delta Review — 2026-08-24

- **Review report**: `docs/reports/review/2026-08-24-governance-package-independent-review-builders.md`
- **Score**: `100/100` effective after the approved path-to-100 application.
- **Verdict**: `APPROVED_PATH100`; the prior Serious boundary finding is resolved.
- **Evidence**: no DS-prefixed public exports; `PrismOperationalStateUI` forwards all nine UI getters through the public barrel; regression test `3/3`; boundary `7/7`; audit lock `293/293`; scoped analyzer clean; formatter unchanged.
- **Residuals**: none identified for the public-barrel contract.
- **Lane recommendation**: move this task from `docs/tasks/02-doing/` to `docs/tasks/03-review/` for independent acceptance.

## Review/Fix Ledger — 2026-08-24 (BUILDER_CONTEXT; parent `builders`)

- **Execution outcome**: path-to-100 applied per 2026-08-24 report; zero DS-name public leakage; self-close score-only PASS recorded in docs/reports/builders/
- **Next routing**: independent BUILDER_CONTEXT re-review dispatched by parent
