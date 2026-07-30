# Review Report: Task 1305 — Catalog Contract Expansion — 2026-06-13

## Review Lineage

- **Current task**: Task 1305 (`catalog-contract-expansion`); live path inspected: `docs/tasks/03-review/1305-warp-prism-catalog-contract-expansion.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1305-review.md` — latest score **66/100**, verdict **REJECTED**.
- **Related reports considered**: none beyond the Task 1305 ledger and previous build-gate report.
- **Review mode**: re-review / review-wave-1 final gate.
- **Governance read first**: `AGENTS.md`, `.agents/rules/definition-of-done.md`, `.agents/skills/code-quality-harness/SKILL.md`, `.agents/skills/flutter-harness/SKILL.md`, `.agents/skills/code-quality-harness/workflows/review-report-lineage.md`.

## Score And Verdict

- **Score**: **62/100 — Debt**
- **Verdict**: **REJECTED**
- **Lane recommendation**: return to doing; no lane move performed by this reviewer.

The catalog package itself improved: `flutter analyze lib/`, `flutter test`, and `dart format --set-exit-if-changed lib/ test/` from `apps/catalog/` all pass under the user-requested command set. The task still cannot be approved because the required UI-gallery analyzer gate fails with **296 info-level issues**, the catalog test package fails a full `lib/ test/` analyzer check with **1 info-level issue**, and the prior contract-proof gaps remain open: duplicate IDs are section-only, high text scale permits **13** overflows, state matrices are shallow, and responsive tests do not prove layout adaptation.

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Catalog formatting is clean. `dart format --set-exit-if-changed lib/ test/` from `apps/catalog/` reports **2 files, 0 changed**.
- `RESOLVED`: Catalog tests execute and pass. `flutter test` from `apps/catalog/` reports **14/14 passed**.
- `RESOLVED`: Previous catalog test `prefer_const_constructors` infos at the high-text-scale wrapper are no longer present under the user-requested `flutter analyze lib/`; the command reports **0 issues** for catalog `lib/`.
- `RESOLVED`: The public UI barrel now exports `DSOperationalStateUI` at `packages/warp_prism_ui/lib/warp_prism_ui.dart:23-27`, so the test no longer needs a private `src/` import to access `state.label`.
- `SUPERSEDED`: The prior `overflowCount >= 0` high-scale assertion was replaced. It is no longer unlimited, but the current `lessThanOrEqualTo(13)` assertion still accepts **13** overflows and does not prove high text scale is handled.

### Persistent Findings

- `PERSISTENT`: Duplicate-ID proof covers **10** gallery section IDs only; it does not cover component IDs or case IDs.
- `PERSISTENT`: State-matrix tests are named by layer but do not enumerate the Task 1106 case contract per layer.
- `PERSISTENT`: Responsive tests prove renderability/no captured overflow, not breakpoint adaptation or geometry change.
- `PERSISTENT`: The implementation import remains in `apps/catalog/test/widget_test.dart:13-14`; it is now also an analyzer issue under full `lib/ test/` analysis.
- `PERSISTENT`: Changelog and task completion evidence are stale: they claim **10** tests, while current catalog test declarations are **14**.

### Regressions

- `REGRESSION`: none proven against the previous report. Current failures are either persistent findings or newly surfaced by the expanded review command set.

### New Findings

- `NEW`: The user-requested `flutter analyze lib/src/gallery/` from `packages/warp_prism_ui/` fails with **296 info-level issues**: **274** `PREFER_CONST_CONSTRUCTORS`, **19** `PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES`, and **3** `DEPRECATED_MEMBER_USE`.
- `NEW`: `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:1716-1719` contains a fake secret-shaped `fullValue: 'sk-1234567890abcdef'` fixture. It is not a real key, but release/security scanning should not have to distinguish fake secret-shaped strings in source.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No component/case registry exists; grep found **2** gallery ID references total: `apps/catalog/test/widget_test.dart:54` and `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart:120`.
- `EVIDENCE_GAP`: No test asserts zero Flutter layout errors at high text scale; the current test explicitly allows **13** overflows.
- `EVIDENCE_GAP`: No responsive test compares compact-vs-expanded geometry, breakpoint mode, column count, or public layout state.
- `EXTERNAL_BLOCKER`: none.

## Axiom Compliance

| # | Axiom | Status | Evidence |
| ---: | --- | --- | --- |
| 1 | Analyzer Integrity | **FAIL** | `apps/catalog`: required `flutter analyze lib/` PASS with **0** issues, but full package check `flutter analyze lib/ test/` FAILS with **1** `unnecessary_import` at `apps/catalog/test/widget_test.dart:14`. `packages/warp_prism_ui`: required `flutter analyze lib/src/gallery/` FAILS with **296** info issues. `analysis_options.yaml` enables `prefer_const_constructors`, `prefer_const_declarations`, and `avoid_print` in both package roots; the local ignore at `apps/catalog/test/widget_test.dart:13` has no documented task justification. |
| 2 | Lifecycle Safety | **PASS** | `apps/catalog/lib` + `apps/catalog/test` create **0** controllers/subscriptions/timers/listeners and have **0** dispose obligations. Reviewed gallery source has **2** `DSTabController` fields at `design_system_gallery_sections.dart:2639` and `:2719`, **2** `addListener` calls at `:2683` and `:2750`, and **2** matching controller disposals at `:2687-2689` and `:2754-2756`. Classification: **SAFE**. |
| 3 | Dependency Direction | **PARTIAL** | Runtime catalog app imports Flutter and the public UI barrel only at `apps/catalog/lib/main.dart:1-2`. Catalog test imports the public barrel at `apps/catalog/test/widget_test.dart:12` and still suppresses an implementation import at `:13-14`. The public barrel already exports the needed extension at `packages/warp_prism_ui/lib/warp_prism_ui.dart:23-27`, making the private import both unnecessary and boundary-unsafe. Classification: **MODERATE**. |
| 4 | UI Accessibility | **PARTIAL** | Reviewed gallery source has **12** activation/mutation callback hooks (`onTap`: **8**, `onReorder`/`onMove`: **2**, `onClose`: **2**), **1** hover-only `MouseRegion`, **8** `semanticLabel` arguments, and **0** explicit `Semantics(` widgets in `packages/warp_prism_ui/lib/src/gallery/`. High text scale accepts **13** overflows at `apps/catalog/test/widget_test.dart:287-297`. Classification: **MODERATE**. |
| 5 | Proof Reality | **PARTIAL** | Claimed catalog tests exist and pass (**14/14**), and gallery tests pass (**13/13**). Proof quality remains incomplete: duplicate proof is section-only at `apps/catalog/test/widget_test.dart:53-64`; high-scale proof allows **13** overflows at `:287-297`; state tests at `:113-237` are presence-heavy; responsive tests at `:305-435` do not assert adaptation. Classification: **MODERATE**. |
| 6 | Release Security | **PARTIAL** | `apps/catalog` contains **0** `print(` / `debugPrint(` matches and **0** real credential matches in reviewed source. Gallery source contains **0** `print(` / `debugPrint(` matches, but includes a fake secret-shaped string `sk-1234567890abcdef` at `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:1716-1719`. Classification: **LOW** security hygiene issue. |

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | `NEW` | High | Open | Required UI gallery analyzer gate fails with **296** info-level issues. | 2026-06-13 review-wave-1 | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart` including `:163`, `:373`, `:387`, `:2477`, `:2479`; command output counted **274** const-constructor, **19** const-literal, **3** deprecated-member issues. |
| F2 | `PERSISTENT` | High | Open | Catalog test still carries an implementation import suppression, now reported as an unnecessary import under full package analysis. | `docs/reports/build-gate-review/1305-review.md` | `apps/catalog/test/widget_test.dart:13-14`; `packages/warp_prism_ui/lib/warp_prism_ui.dart:23-27`; `flutter analyze lib/ test/` from `apps/catalog/` reports **1** info. |
| F3 | `PERSISTENT` | Medium | Open | Duplicate-ID proof covers **10** section IDs only, not component IDs or case IDs. | `docs/reports/build-gate-review/1305-review.md` | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart:50-121`; `apps/catalog/test/widget_test.dart:53-64`; grep found **0** `componentId`/`caseId` registry surfaces. |
| F4 | `SUPERSEDED` | Medium | Open | High-text-scale proof is no longer unbounded, but it encodes a baseline that allows **13** overflows. | `docs/reports/build-gate-review/1305-review.md` | `apps/catalog/test/widget_test.dart:241-301`, especially `:287-297`. |
| F5 | `PERSISTENT` | Medium | Open | State-matrix tests are layer-labeled but do not enumerate Task 1106 default/loading/empty/error/degraded/disabled/long-text/narrow/high-scale cases per layer. | `docs/reports/build-gate-review/1305-review.md` | Atom `apps/catalog/test/widget_test.dart:113-137`; molecule `:139-193`; organism `:195-216`; template `:218-237`. |
| F6 | `PERSISTENT` | Medium | Open | Responsive tests assert renderability/ListView presence, not layout adaptation. | `docs/reports/build-gate-review/1305-review.md` | Compact/expanded render tests `apps/catalog/test/widget_test.dart:305-395`; ListView structure test `:412-435`. |
| F7 | `PERSISTENT` | Low | Open | Changelog and completion evidence are stale relative to current implementation. | `docs/reports/build-gate-review/1305-review.md` | Changelog claims **10** tests at `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md:15-40`; task completion evidence claims **10/10** at `docs/tasks/03-review/1305-warp-prism-catalog-contract-expansion.md:128-137`; current catalog test declarations are **14**. |
| F8 | `NEW` | Low | Open | Gallery source contains a fake secret-shaped string that can trip release/security scanning. | 2026-06-13 review-wave-1 | `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart:1716-1719`. |

### Specific Code Change Recommendations

1. **Fix gallery analyzer integrity**: in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`, apply analyzer-safe `const` constructors/literals across the **293** const-related issues and replace deprecated `.withOpacity(...)` at `:163`, `:2477`, and `:2479` with `.withValues(alpha: ...)`. Re-run `flutter analyze lib/src/gallery/` until it reports **0** issues.
2. **Remove the private import**: delete `apps/catalog/test/widget_test.dart:13-14`. `package:warp_prism_ui/warp_prism_ui.dart` already exports `DSOperationalStateUI`, so `state.label` remains visible without `src/` access.
3. **Add component/case IDs**: introduce a public gallery contract such as `DSGalleryCaseSpec(sectionId, id, label, builder)` beside `DSGallerySectionSpec`; expose `dsGalleryCaseIds`; add a test that asserts uniqueness over the complete case ID set, not only `dsGallerySectionIds`.
4. **Make high text scale a real contract**: replace `lessThanOrEqualTo(13)` at `apps/catalog/test/widget_test.dart:291-297` with `equals(0)` after fixing layout overflows, or move the known-overflow baseline to a separate debt test that does not satisfy the Task 1305 high-scale exit condition.
5. **Rewrite state matrices as table-driven tests**: for each atomic layer, define exact applicable cases from Task 1106: default, loading, empty, error/degraded, disabled, long text, narrow, and high text scale. Encode non-applicable cases with explicit exemption strings.
6. **Measure responsive adaptation**: in the compact/expanded tests, assert at least one measurable breakpoint contract, for example different card width, different `Wrap` run count, different template geometry, or a public layout-mode value between **800px** and **1400px**.
7. **Replace fake secret-shaped fixture**: change `fullValue: 'sk-1234567890abcdef'` to a non-secret-shaped demo literal such as `fullValue: 'demo-redacted-placeholder'`, or pass only a masked demo value.
8. **Update stale evidence**: after the analyzer/test fixes, update the changelog and completion evidence to state **14** catalog tests, **13** gallery tests, exact analyzer outputs, and exact format output.

## Evidence Reviewed

### Task And Governance

- `AGENTS.md`
- `.agents/rules/definition-of-done.md`
- `.agents/skills/code-quality-harness/SKILL.md`
- `.agents/skills/flutter-harness/SKILL.md`
- `.agents/skills/code-quality-harness/workflows/review-report-lineage.md`
- `docs/tasks/03-review/1305-warp-prism-catalog-contract-expansion.md`
- `docs/reports/build-gate-review/1305-review.md`

### Files Listed In Task `Where` Table

- `apps/catalog/test/widget_test.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_page.dart`
- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`

### Additional Evidence Files Read

- `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart`
- `packages/warp_prism_ui/lib/warp_prism_ui.dart`
- `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart`
- `apps/catalog/lib/main.dart`
- `apps/catalog/pubspec.yaml`
- `packages/warp_prism_ui/pubspec.yaml`
- `apps/catalog/analysis_options.yaml`
- `packages/warp_prism_ui/analysis_options.yaml`
- `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md`

### File Existence Verification

| Claimed / relevant file | Exists | Evidence |
| --- | --- | --- |
| `apps/catalog/test/widget_test.dart` | yes | Read successfully; **14** test declarations at lines `45`, `53`, `67`, `77`, `94`, `113`, `139`, `195`, `218`, `241`, `305`, `351`, `397`, `412`. |
| `docs/changelog/2026-06-09-task-1305-catalog-contract-expansion.md` | yes | Read successfully; content stale at lines `15-40`. |
| `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_registry.dart` | yes | Read successfully; **10** section specs at lines `50-115`. |
| `packages/warp_prism_ui/test/gallery/design_system_gallery_test.dart` | yes | Read successfully; **13** test declarations. |

### Commands Run

| Command | Working directory | Result |
| --- | --- | --- |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter analyze lib/` | `apps/catalog/` | **PASS** — **0** issues. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter test` | `apps/catalog/` | **PASS** — **14/14** tests passed. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache dart format --set-exit-if-changed lib/ test/` | `apps/catalog/` | **PASS** — formatted **2** files, **0** changed. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter analyze lib/src/gallery/` | `packages/warp_prism_ui/` | **FAIL** — **296** info issues. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter test test/gallery/` | `packages/warp_prism_ui/` | **PASS** — **13/13** tests passed. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache flutter analyze lib/ test/` | `apps/catalog/` | **FAIL** — **1** info: `unnecessary_import` at `test/widget_test.dart:14:8`. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache dart analyze --format machine lib/src/gallery/` | `packages/warp_prism_ui/` | **FAIL** — counted **296** issues: **274** `PREFER_CONST_CONSTRUCTORS`, **19** `PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES`, **3** `DEPRECATED_MEMBER_USE`. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache dart pub outdated` | `apps/catalog/` | **INFO** — **7** dependencies constrained older than resolvable, **3** upgradable dependencies locked older. |
| `TMPDIR=/home/sephiroth/working/ganthritor/warp-prism/tmp PUB_CACHE=/home/sephiroth/working/ganthritor/warp-prism/tmp/pub-cache dart pub outdated` | `packages/warp_prism_ui/` | **INFO** — same workspace result: **7** dependencies constrained older than resolvable, **3** upgradable dependencies locked older. |

## Path To 100

1. Make `packages/warp_prism_ui/` gallery analyzer-clean: **0** errors, **0** warnings, **0** infos for `flutter analyze lib/src/gallery/`.
2. Make `apps/catalog/` full analyzer-clean: remove `apps/catalog/test/widget_test.dart:13-14` and require `flutter analyze lib/ test/` to return **0** issues.
3. Add a stable component/case registry and duplicate-ID proof for every catalog case, not only the **10** section IDs.
4. Fix high-text-scale layout so `apps/catalog/test/widget_test.dart` can assert **0** overflows at `TextScaler.linear(2.0)`.
5. Convert the four layer tests into exact table-driven state matrices covering Task 1106 cases or documented per-case exemptions.
6. Replace renderability-only responsive checks with compact-vs-expanded geometry or breakpoint assertions.
7. Remove the fake secret-shaped `sk-...` fixture from gallery source.
8. Update changelog and completion evidence with exact current command outputs and test counts.
9. Re-run and record: `flutter analyze lib/ test/` from `apps/catalog/`, `flutter test` from `apps/catalog/`, `dart format --set-exit-if-changed lib/ test/` from `apps/catalog/`, `flutter analyze lib/src/gallery/` from `packages/warp_prism_ui/`, and `flutter test test/gallery/` from `packages/warp_prism_ui/`.

## Task Ledger Patch Suggestion

```markdown
### 2026-06-13 — review-wave-1 independent review
**Score**: 62/100 — Debt
**Verdict**: REJECTED → return to doing; reviewer performed no lane move
**Full report**: `docs/reports/review-wave-1/1305-review.md`
**Previous report**: `docs/reports/build-gate-review/1305-review.md`
**Diagnostics**: `apps/catalog flutter analyze lib/` PASS (0 issues) | `apps/catalog flutter test` PASS (14/14) | `apps/catalog dart format --set-exit-if-changed lib/ test/` PASS (2 files, 0 changed) | `packages/warp_prism_ui flutter analyze lib/src/gallery/` FAIL (296 info issues) | `packages/warp_prism_ui flutter test test/gallery/` PASS (13/13) | extra `apps/catalog flutter analyze lib/ test/` FAIL (1 unnecessary import)
**Open blockers**:
- `NEW`: UI gallery analyzer gate fails with 296 info-level issues in `packages/warp_prism_ui/lib/src/gallery/design_system_gallery_sections.dart`.
- `PERSISTENT`: catalog test still suppresses a private `src/` import at `apps/catalog/test/widget_test.dart:13-14`; remove it because the public barrel exports the needed extension.
- `PERSISTENT`: duplicate-ID proof covers 10 section IDs only; no component/case ID registry exists.
- `SUPERSEDED`: high-text-scale test no longer accepts unlimited overflows, but still allows 13 overflows at `apps/catalog/test/widget_test.dart:287-297`.
- `PERSISTENT`: state-matrix and responsive tests remain presence/renderability checks rather than full Task 1106 matrices and breakpoint adaptation proof.
- `PERSISTENT`: changelog/completion evidence still claim 10 tests while current catalog test declarations are 14.
**Path-to-100 summary**: fix gallery analyzer to 0 issues, remove the private import, add component/case IDs, require 0 high-scale overflows, table-drive state matrices, assert responsive geometry, remove fake `sk-...` fixture, and refresh evidence.
```
