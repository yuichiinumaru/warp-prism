# Task 1601: Catalog / Gallery Showability Verify + Polish

> **Status**: `[/]` Held In Review — path-to-100 re-review S=96 (2026-07-11)
> **Review State**: `Held In Review` (path-to-100 accepted; lane `03-review/`)
> **Priority**: 🔴 P0
> **Type**: `verification`
> **Origin**: EPIC-16 (`docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`) + harvest reports `docs/reports/ads-harvest-session-synthesis-2026-07-10.md`, `docs/reports/ads-harvest-omniroute-visual-reference-2026-07-10.md`, `docs/reports/ads-harvest-references-catalog-triage-2026-07-10.md`, `docs/reports/ads-harvest-atomic-ds-references-2026-07-10.md`
> **Blocks**: N/A (soft enabler for organism gallery demos)
> **Depends on**: Task 1600 (soft — inventory brief preferred; may proceed if epic + harvest docs already freeze showability expectations)
>
> **Visibility scope**: README already documents `cd apps/catalog && flutter run`. This task
> **verifies smoke**, optionally improves section TOC/discovery, and may add a short demo
> one-pager under `docs/demo/` or `docs/reports/` if useful. Do **not** introduce Widgetbook.

> [!IMPORTANT]
> Task identity is lane-neutral. Use `Task 1601` plus optional slug for
> dependencies, blockers, review ledgers, reports, and architecture references.
> Lanes such as `02-doing` and `03-review` are mutable status, not identity.

---

## Objective

Prove and polish **ADS catalog/gallery showability** so stakeholders can demo the design system without guessing: verify catalog run path, smoke-compile/analyze catalog + gallery surfaces, improve discoverability (optional TOC/section notes), and leave a short demo script/one-pager if the README alone is still too thin for handoff.

## Background Context

### Source origin (EPIC-16)

| Field | Value |
| --- | --- |
| **Wave** | **V** (Visibility) |
| **Action type** | `VERIFY` + light docs polish |
| **Proof surface** | `apps/catalog` → `DesignSystemGalleryPage`; Observatory `/design-system` optional note |
| **Policy** | No Widgetbook — `docs/design/token-theme-catalog-policy.md` |

### What already exists

- README Setup step 4: `cd apps/catalog && flutter run` with ADS visibility note.
- Catalog app: `apps/catalog/lib/main.dart` → `MaterialApp` → `DesignSystemGalleryPage`.
- Gallery: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`, `design_system_gallery_registry.dart`, `design_system_gallery_sections.dart`.
- Gallery tests: `packages/warp_prism_ui/test/gallery/`.
- Melos: `test-catalog` script (per README validation table).

### What is missing or broken

- Epic notes section discovery for many organisms is scroll-heavy; TOC / section index may be weak.
- No single short “show someone in 60 seconds” demo one-pager may exist under `docs/demo/` or `docs/reports/`.
- Smoke verification of catalog analyze/test may not be recorded as EPIC-16 evidence.

### False-gap notes (do not re-implement)

- Do **not** add Widgetbook or external storybook packages.
- Do **not** rebrand gallery to OmniRoute teal.
- Do **not** block organism waves on perfect TOC — verify smoke is the hard gate; TOC polish is optional stretch.
- Organism registration completeness is **Task 1613**, not this task.

---

## Test Requirements

- MUST verify catalog app analyzes clean (or record exact residual issues unrelated to this task).
- MUST verify gallery package tests that already exist still pass (or document pre-existing failures).
- MUST confirm README still contains a correct catalog run command after any polish.
- MUST produce Completion Evidence with command outputs for catalog/gallery smoke.
- OPTIONAL: section TOC improvement in gallery page/registry **or** a `docs/demo/` / `docs/reports/` one-pager listing: bootstrap, run catalog, navigate to organisms section, key keyboard tips.
- MUST NOT introduce Widgetbook, MapLibre, Recharts, or live network gallery demos.

---

## Exit Conditions

- [x] Catalog smoke: `dart analyze` (or melos catalog analyze) PASS on `apps/catalog` (or residual issues listed as pre-existing).
- [x] Gallery smoke: relevant `flutter test` under `packages/warp_prism_ui/test/gallery/` PASS (or documented pre-existing). — **RE-VERIFIED 2026-07-11 path-to-100: live 17/17 PASS after DSTree scroll fixture + filter overflow fix**
- [x] README catalog run path still accurate; optional TOC/section polish landed **or** explicitly deferred with reason.
- [x] Demo one-pager created under `docs/demo/` or `docs/reports/` **or** Completion Evidence proves README + existing policy docs are sufficient with a quoted show-path.
- [x] Local changelog entry added under `docs/changelog/`.
- [x] Completion Evidence is filled before review handoff. — **REFRESHED 2026-07-11 with live PASS counts**

---

## Details

### What

Subtasks:

- [x] **Read existing code before modifying**: read `README.md` (Setup + ADS visibility), `docs/design/token-theme-catalog-policy.md`, `apps/catalog/lib/main.dart`, `apps/catalog/pubspec.yaml`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`, `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, `packages/warp_prism_ui/test/gallery/`, `docs/tasks/00-planning/EPIC-16-warp-prism-ads-cybercore-ops-and-agent-transcript-organisms.md`, Task 1600 brief if present.
- [x] Run catalog analyze + gallery tests; record results.
- [x] If section discovery is painful, add minimal TOC/jump aids in gallery **or** document deferred.
- [x] Optionally write `docs/demo/catalog-showability-YYYY-MM-DD.md` (or reports path) with 60-second demo script.
- [x] If editing README, keep changes minimal (TOC link / clarify desktop target) — README is protected; prefer small additive edits only when justified.
- [x] **Simplicity pass**: no Widgetbook; no mega redesign of gallery IA.
- [x] **Regression verification**: re-run smoke commands after polish.

### Where

| File | Purpose |
| --- | --- |
| `README.md` | Read / optional Modify — catalog run accuracy (protected) |
| `docs/design/token-theme-catalog-policy.md` | Read — no-Widgetbook policy |
| `apps/catalog/lib/main.dart` | Read — thin host |
| `apps/catalog/pubspec.yaml` | Read — deps |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` | Read / optional Modify — TOC polish |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | Read / optional Modify — section ids |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` | Read — section builders |
| `packages/warp_prism_ui/test/gallery/` | Read / optional Modify — smoke tests |
| `docs/demo/` or `docs/reports/` | Create optional demo one-pager |
| `docs/changelog/` | Create — changelog note |

### How

1. Bootstrap monorepo if needed (`dart pub get`, `dart run melos bootstrap`).
2. Analyze catalog; run gallery tests.
3. Demo path: document command + what stakeholder should see (tokens/atoms/organisms sections).
4. Optional polish only if cost is low; otherwise freeze deferred note for 1613.

### Why

EPIC-16 grows many organisms; stakeholders need a **known, documented, smoke-verified** show path today. Catalog run is already in README — verification and light polish close the visibility gap without inventing Widgetbook.

---

## Anti-Hallucination Guardrails

> [!CAUTION]
> Do not mark complete without recording smoke command evidence. Do not claim
> Widgetbook was added. Do not rebrand Observatory to teal.

> [!IMPORTANT]
> Preserve Warp Prism read-only mock-observatory semantics. Prefer fixtures.
> No live API keys, no MapLibre, no Recharts.

> [!WARNING]
> ADS visibility only. Do not rewrite Observatory product routes. Task 1613 owns
> full EPIC-16 organism registration completeness.

---

## Validation Commands

```bash
# Catalog app
cd apps/catalog
dart analyze
# Optional if tests exist:
# flutter test

# Gallery package surface
cd ../../packages/warp_prism_ui
dart analyze lib/src/gallery test/gallery
flutter test test/gallery/

# From monorepo root (optional melos)
cd ../..
# dart run melos run test-catalog
# dart run melos run analyze
```

If Flutter tooling is unavailable in the execution environment, record the exact
tooling failure and do not claim those checks passed.

---

## Completion Evidence

- **Files created/modified**:
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart` — Stateful gallery + **Section index** TOC (registry-driven jump chips); root `Material` for catalog host without Scaffold; stable registry IDs unchanged.
  - `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` — **2026-07-11 path-to-100**: DSTree organism fixture wrapped in `SingleChildScrollView` (fixed height 280 no longer overflows expanded provider tree); FilterWorkbench demo host raised to `720×480` for 2.0 text-scale headroom.
  - `packages/warp_prism_ui/lib/src/organisms/filter_workbench/ds_filter_workbench.dart` — **2026-07-11**: header + criteria scroll together; Apply/Clear footer remains pinned (avoids fixed-chrome overflow at large text scale).
  - `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` — TOC chip coverage test; Tokens `findsWidgets`; Color Palette scroll fix.
  - `docs/demo/catalog-showability-2026-07-10.md` — 60-second demo one-pager (create).
  - `docs/changelog/2026-07-10-task-1601-catalog-gallery-showability-verify-polish.md` — original local changelog.
  - `docs/changelog/2026-07-11-task-1601-gallery-tree-filter-overflow-fix.md` — path-to-100 overflow fix note.
  - README **not** edited (protected); catalog run path already accurate.

- **Tests or validation commands** (path-to-100 re-run, **2026-07-11 live**):

  | Command | Result |
  | --- | --- |
  | `cd apps/catalog && dart analyze` | **PASS** EXIT 0 — `No issues found!` |
  | `cd packages/warp_prism_ui && dart analyze lib/src/gallery lib/src/organisms/filter_workbench test/gallery` | **PASS** EXIT 0 — `No issues found!` |
  | `cd packages/warp_prism_ui && flutter test test/gallery/` | **PASS** EXIT 0 — **17/17** tests passed |
  | `cd packages/warp_prism_ui && flutter test test/organisms/filter_workbench/` | **PASS** EXIT 0 — **10/10** tests passed |
  | `cd apps/catalog && flutter test` | **PASS** EXIT 0 — **9/9** tests passed (incl. high text scale zero overflow) |

- **Before fix (independent review 2026-07-11)**:
  - Gallery: **15/17 FAIL** — `renders organism previews`, `buildOrganismsSection renders independently` (DSTree RenderFlex +18px)
  - Catalog: **8/9 FAIL** — high text scale overflow count 2 (DSTree + DSFilterWorkbench)

- **After fix (this session)**:
  - Gallery: **17/17 PASS**
  - Catalog: **9/9 PASS**

- **Demo one-pager**: `docs/demo/catalog-showability-2026-07-10.md`
  - Bootstrap → `cd apps/catalog && flutter run` → Section index → Organisms.
  - Alternate: Observatory `/design-system`.
  - Explicit no-Widgetbook / no-teal / registry-id stability notes.

- **TOC polish**: Landed — `Section index` chips keyed `gallery-toc-<section.id>`; jump uses progressive page-down + `Scrollable.ensureVisible`. Registry section **ids** untouched (`tokens` … `templates`).

- **README catalog run path** (unchanged, verified present):

  ```bash
  # 4. Run the ADS catalog / gallery (Storybook-class proof surface)
  #    Thin shell over DesignSystemGalleryPage in warp_prism_ui.
  cd apps/catalog && flutter run
  ```

- **Local changelog entries**:
  - `docs/changelog/2026-07-10-task-1601-catalog-gallery-showability-verify-polish.md`
  - `docs/changelog/2026-07-11-task-1601-gallery-tree-filter-overflow-fix.md`
- **Agent-wiki / docs institutionalization**: N/A (task-local demo + changelog sufficient)
- **Executor (path-to-100)**: gt-flutter-engineer (builders fixer subagent)
- **Completion date (path-to-100)**: 2026-07-11
- **Lane note**: Remains in `02-doing/` with Review State **Ready For Review** (no lane move by executor per task rules).

---

## Review Ledger

### 2026-07-11 — independent reviewers (gt-flutter-code-reviewer + gt-code-quality-reviewer)

- **Score**: `81/100`
- **Verdict**: `REJECTED_STAY_DOING`
- **Lane**: remains `docs/tasks/02-doing/`
- **Report**: `docs/reports/review-wave-2026-07-11/task-1601-independent-review.md`
- **Live gates (at rejection)**:
  - `apps/catalog` `dart analyze` → **PASS** No issues found
  - `warp_prism_ui` gallery analyze → **PASS** No issues found
  - `flutter test test/gallery/` → **FAIL 15/17** (organism previews + buildOrganismsSection; DSTree RenderFlex overflow +18px)
  - `apps/catalog` `flutter test` → **FAIL 8/9** (high text scale overflow)
  - TOC-only tests → **PASS** (Section index + registry IDs)
  - Demo one-pager + changelog → **PASS**
- **Blockers (addressed 2026-07-11 path-to-100)**:
  1. ~~Gallery smoke hard gate red; CE claims 17/17~~ → fixed DSTree scroll fixture; live **17/17**.
  2. ~~Catalog suite red; CE claims 9/9~~ → fixed tree + filter overflow; live **9/9**.
  3. ~~Refresh CE with live truth after fix~~ → CE table refreshed this session.
- **Path to 100** (executed):
  1. DSTree gallery fixture: `SingleChildScrollView` inside fixed height.
  2. FilterWorkbench: scrollable header/body + larger demo host; organism layout hardened.
  3. Re-ran gallery + catalog + filter suites; CE updated.
  4. TOC/demo preserved.

### 2026-07-11 — builders path-to-100 re-verify (post-fix)

- Gallery suite: **17/17 PASS** EXIT 0
- Catalog suite: **9/9 PASS** EXIT 0
- Filter workbench organism: **10/10 PASS** EXIT 0
- Analyze catalog + gallery/filter paths: **No issues found**
- Review State → **Ready For Review** (still `02-doing/`; executor does not self-promote lane)

### 2026-07-11 — independent path-to-100 re-review (gt-flutter-code-reviewer + code-quality-harness)

- **Score**: `96/100`
- **Verdict**: `HELD_IN_REVIEW_PATH_TO_100`
- **Lane**: moved `02-doing/` → `03-review/`
- **Report**: `docs/reports/review-wave-2026-07-11/task-1601-path-to-100-rereview.md`
- **Live gates (this re-review)**:
  - `apps/catalog` `dart analyze` → **PASS** No issues found
  - `warp_prism_ui` gallery + filter_workbench analyze → **PASS** No issues found
  - `flutter test test/gallery/` → **17/17 PASS** EXIT 0
  - `apps/catalog` `flutter test` → **9/9 PASS** EXIT 0 (high text scale zero overflow)
  - `flutter test test/organisms/filter_workbench/` → **10/10 PASS** EXIT 0
- **Prior blockers B1/B2/B3**: **RESOLVED** (tree scroll fixture + filter host/organism layout + CE currency)
- **Residuals (non-blocking)**: demo one-pager not annotated for overflow-fix notes (I1); organism-level FilterWorkbench scroll slightly wider than fixture-only (I2, acceptable, tested)
- **Never** `04-completed/` by this reviewer

### 2026-07-16 — independent re-review (adversarial gatekeeper)

- **Score**: `100/100`
- **Verdict**: `PERFECT`
- **Full report**: `docs/reports/review/1601-catalog-gallery-showability-independent-rereview-2026-07-16.md`
- **Lane outcome**: stays in `docs/tasks/03-review/` (100 band; never `04-completed`)
- **Delta**: prior I1/I2 residual improvements PERSISTENT as optional polish; hard smoke gates all green live (21/21 gallery, 9/9 catalog, analyze clean)
- **Live gates (this re-review)**: `apps/catalog` analyze PASS; gallery `flutter test` → **21/21** PASS (suite grew +4 tests, all green); catalog `flutter test` → **9/9** PASS; organism suites page_shell **9/9**, tree **13/13** PASS
- **No blockers**; at ceiling

---

## Review Ledger — 2026-07-17 Drain Wave (Batch 9)

| Field | Value |
| --- | --- |
| **Score** | 100/100 |
| **Verdict** | PERFECT |
| **Lane** | 04-completed |
| **Report** | `docs/reports/review-wave-2026-07-17/task-1601-drain-review.md` |
| **Top finding** | None |
| **Reviewer** | independent (parent agentID=reviewers) |
| **Prior treated as** | draft — live re-proved |
