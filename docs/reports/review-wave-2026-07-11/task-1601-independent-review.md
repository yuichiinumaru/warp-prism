# Review Report: Task 1601 — Catalog / Gallery Showability Verify + Polish — 2026-07-11

## Review Lineage

- **Current task**: Task 1601 (`1601-warp-prism-catalog-gallery-showability-verify-polish`); live path at review start: `docs/tasks/02-doing/1601-warp-prism-catalog-gallery-showability-verify-polish.md`
- **Previous reports read**: none prior for Task 1601 (first independent review)
- **Related reports / policy considered**:
  - `docs/demo/catalog-showability-2026-07-10.md` (deliverable one-pager)
  - `docs/changelog/2026-07-10-task-1601-catalog-gallery-showability-verify-polish.md`
  - `docs/design/token-theme-catalog-policy.md` (no-Widgetbook)
  - EPIC-16 visibility wave notes in task origin
- **Review mode**: independent first review (gt-flutter-code-reviewer + gt-code-quality-reviewer)
- **Policy**: never `04-completed/`; S≥90 → `03-review/`; S&lt;90 stay `02-doing/` + path-to-100; no git / no tasklist
- **No git operations**

## Score And Verdict

- **Score**: `81/100`
- **Verdict**: `REJECTED_STAY_DOING`
- **Lane recommendation**: remain `docs/tasks/02-doing/`
- **Lane outcome**: stays `docs/tasks/02-doing/` (hard gallery smoke red + stale Completion Evidence)

## Delta Summary

### Delivered (implementation)

- Registry-driven **Section index** TOC on `DesignSystemGalleryPage` with stable `gallery-toc-<section.id>` keys.
- Progressive page-down + `Scrollable.ensureVisible` jump for lazy ListView.
- Root `Material` host so catalog (no Scaffold) can mount TextField demos.
- Demo one-pager under `docs/demo/catalog-showability-2026-07-10.md`.
- Local changelog present.
- TOC-specific tests present and **live green**.
- Catalog `dart analyze` **live green**.
- No Widgetbook / no teal rebrand / registry IDs stable.

### Blocking

- Gallery smoke hard gate is **red live**: `flutter test test/gallery/` → **15/17** (2 FAIL). Completion Evidence claims **17/17 PASS**.
- Catalog `flutter test` **live red**: high-text-scale overflow proof fails. Completion Evidence claims **9/9 PASS**.
- Failures are layout overflow under organisms gallery demos (notably `DSTree` fixed-height fixture overflowing by 18px), not TOC jump logic — but **Task 1601 owns the gallery smoke gate** and must either green it or honestly document residuals with exact suite/test names.

### Residuals / non-blocking for product path

- Concurrent EPIC-15/16 organism gallery fixtures (Map HUD, Tool Strip, Tree, Layer Control, Filter Workbench, etc.) densified Organisms section; overflow residual is demo sizing debt (likely Task 1603 tree fixture height 280 vs content), not a Widgetbook regression.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| B1 | NEW | **Blocker** | Open | Gallery suite not green; CE claims 17/17 | Live `flutter test test/gallery/` → +15 −2; fails: `renders organism previews`, `buildOrganismsSection renders independently` — `DSTree` RenderFlex overflow +18px (`ds_tree.dart:186`, fixture `height: 280`) |
| B2 | NEW | **Blocker** | Open | Catalog suite not green; CE claims 9/9 | Live `apps/catalog` `flutter test` → high text scale overflow expectation fails |
| B3 | NEW | High | Open | Proof Reality: Completion Evidence smoke table is stale | Task CE table claims all PASS 2026-07-10; live 2026-07-11 diverges |
| P1 | PASS | — | Closed | Catalog analyze clean | `cd apps/catalog && dart analyze` → No issues found |
| P2 | PASS | — | Closed | Gallery path analyze clean | `dart analyze lib/src/gallery test/gallery` → No issues found |
| P3 | PASS | — | Closed | TOC showability landed + tested | `Section index` + TOC chips; tests for TOC + unique IDs pass |
| P4 | PASS | — | Closed | Demo one-pager + changelog | `docs/demo/catalog-showability-2026-07-10.md`, changelog entry |
| P5 | PASS | — | Closed | README catalog run path still accurate | `cd apps/catalog && flutter run` present; README not needlessly edited |
| P6 | PASS | — | Closed | No Widgetbook / policy guardrails | No storybook package; demo script forbids teal/MapLibre/Widgetbook |

## Exit Condition Verification

| Exit condition | Status | Live evidence (this session) |
| --- | --- | --- |
| Catalog smoke analyze PASS (or residual listed) | **PASS** | `No issues found!` EXIT 0 |
| Gallery smoke `flutter test test/gallery/` PASS (or pre-existing documented) | **FAIL** | **15/17**; failures **not** documented as residual in CE (claimed PASS) |
| README catalog run path accurate; TOC polish landed or deferred | **PASS** | TOC landed; README command verified |
| Demo one-pager **or** CE proves README sufficient | **PASS** | One-pager present |
| Local changelog | **PASS** | `docs/changelog/2026-07-10-task-1601-…` |
| Completion Evidence filled before handoff | **PARTIAL** | Filled but **currency false** on smoke tables |

## Axiom Compliance

| Axiom | Status | Notes |
| --- | --- | --- |
| Analyzer Integrity | **PASS** (scoped) | Catalog + gallery analyze clean |
| Proof Reality | **FAIL** | CE 17/17 and 9/9 contradicted by live runs |
| Lifecycle Safety | **PASS** | ScrollController disposed on gallery page |
| Dependency Direction | **PASS** | No new illegal deps / no Widgetbook |
| UI Accessibility | **PASS** (TOC) | Chip keys; keyboard tip documented in demo |
| Release Security | **PASS** | Read-only fixtures; no live APIs |

## Live Snapshot (this review)

| Check | Claimed (CE) | Live 2026-07-11 independent |
| --- | --- | --- |
| `apps/catalog` `dart analyze` | PASS | **PASS** No issues found |
| `warp_prism_ui` gallery analyze | PASS | **PASS** No issues found |
| `flutter test test/gallery/` | 17/17 PASS | **15/17 FAIL** (2 overflow) |
| `apps/catalog` `flutter test` | 9/9 PASS | **8/9 FAIL** (high text scale overflows) |
| TOC chip coverage | Landed | **PASS** (isolated TOC tests green) |
| Demo one-pager | Present | **Present** |

### Commands run

```text
cd apps/catalog && dart analyze
# → No issues found! EXIT 0

cd packages/warp_prism_ui && dart analyze lib/src/gallery test/gallery
# → No issues found! EXIT 0

cd packages/warp_prism_ui && flutter test test/gallery/
# → +15 -2 Some tests failed
# FAIL DesignSystemGalleryPage renders organism previews
# FAIL PrismGallerySections buildOrganismsSection renders independently
# Root: A RenderFlex overflowed by 18 pixels on the bottom
#   Column ← … ← DSTree ← … height constraint h=262 (fixture SizedBox height: 280)

cd packages/warp_prism_ui && flutter test test/gallery/ --name "section index|renders without errors|registry section IDs"
# → +3 All tests passed (TOC-specific)

cd apps/catalog && flutter test
# → +8 -1 high text scale test produces zero overflow exceptions

# README
rg "cd apps/catalog && flutter run" README.md  # present
```

### Commands not run and why

- Full `melos run test-catalog` / package-wide `flutter test`: out of Task 1601 scoped smoke; gallery + catalog app suites are the named gates.
- Manual `flutter run` desktop visual: environment review is headless-CI style; code+test proof used instead.

## Path To 100

1. **Green gallery smoke** — fix Organisms demo layout debt that breaks non-swallowed overflow tests:
   - Raise / make scrollable the `DSTree` gallery fixture height (currently `height: 280` around tree), **or** clip with explicit `ClipRect`/`ListView` if intentional, **or** align overflow-swallowing in the two failing tests only if product accepts demo overflow (prefer real layout fix; Task 1603 owner may co-own tree fixture).
2. **Green catalog suite** — resolve `high text scale test produces zero overflow exceptions` (or document exact residual with owning task if policy allows — CE currently claims green, so must not leave as silent red).
3. **Refresh Completion Evidence** with live command outputs (counts, failing names if any residual remains, exit codes).
4. Re-run:
   - `cd apps/catalog && dart analyze && flutter test`
   - `cd packages/warp_prism_ui && flutter test test/gallery/`
5. Leave TOC/demo/changelog intact (already good).

## Lane Action

- **Stay** `docs/tasks/02-doing/1601-warp-prism-catalog-gallery-showability-verify-polish.md`
- Review State → residual / path-to-100 (not Ready For Review until smoke honest-green)
- Report: this file
