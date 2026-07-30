# 0010 — Warp-Prism Foundation Audit Analyzer Baseline

> **Original Audit Date**: 2026-06-07 (historical pre-monorepo snapshot)
> **Prior mid-wave RED inventory**: 2026-07-09 (builders; **SUPERSEDED** — claimed ~920 ERROR)
> **Prior compile-green inventory**: 2026-07-09 (claimed obs 69 / UI 75 INFO; **SUPERSEDED** as exact INFO currency)
> **Live Refresh Date**: 2026-07-17 (drain review — UI INFO 31→28; lib dart 86→157)
> **Auditor (original)**: Hermes Agent
> **Auditor (live currency refresh)**: builders (Task 0010 fixer — honest live inventory)
> **Scope**: Honest foundation **baseline inventory** — not a product remediation task
> **Method**: Filesystem inventory + scoped `dart analyze --format=machine` + `flutter --version`
> **Verdict (live)**: Scoped `lib/` analyzer is **compile-green (0 ERROR)** across all four packages.
> Lint **INFO** debt remains (observatory **52**, UI **24** as of 2026-07-17). Full monorepo `flutter test` green is **not** claimed.

---

## 0. Classification (read first)

| Layer | What it is | Reproducible today? |
|---|---|---|
| **Historical (2026-06-07)** | Root Flutter app inventory under `lib/` before Melos migration | **No** — root `lib/` is **ABSENT** |
| **Mid-wave RED (earlier 2026-07-09)** | Observatory `DS*` vs public `Prism*` barrel → ~920 ERROR | **No** — migration closed; counts **stale** |
| **Prior INFO snapshot (2026-07-09)** | Compile-green with claimed obs 69 / UI 75 INFO | **Partially** — 0 ERROR still true; **INFO counts lower now** |
| **Live monorepo (2026-07-10 re-inventory)** | Package-scoped inventory under `apps/*` and `packages/*` | **Yes** — commands and machine logs below |

This report deliberately separates historical / mid-wave evidence from **live** monorepo evidence.
Do **not** treat historical root-app claims, mid-wave 920-ERROR RED, or prior 69/75 INFO totals as current truth.
Do **not** invent package-test green without a fresh full `flutter test` capture.

> [!IMPORTANT]
> Task contract forbids greenwashing a RED world. It also forbids documenting RED after the world is compile-green.
> Honesty requires **current** truth — including exact INFO totals for an audit baseline.

---

## 1. Executive Summary (Live 2026-07-10 re-inventory)

Warp Prism is a **Melos workspace** (`pubspec.yaml` `workspace: packages/**, apps/**`), not a single root Flutter app.

| Package | Role | `lib/**/*.dart` | Live `dart analyze --format=machine` on `lib` | Exit |
|---|---|---:|---|---|
| `packages/warp_prism_ui` | Design system library | **157** | **24 INFO, 0 ERROR, 0 WARNING** | **0** |
| `apps/observatory` | Main ASW Observatory app | **109** | **53 INFO, 0 ERROR, 0 WARNING** | **0** |
| `apps/catalog` | Catalog app | **1** | **0 issues** | **0** |
| `apps/cybercore` | CyberCore app | **16** | **0 issues** | **0** |

**Package compile-gate status (scoped `lib/`): GREEN (0 ERROR).**  
**Lint baseline status: INFO debt only** (not clean under analysis_options lint rules).  
**Full `flutter test` package-green: NOT CLAIMED** (inventory of test files only).

### Primary failure class (live)

| Class | Status |
|---|---|
| Observatory `DS*` consumer vs `Prism*` public barrel | **CLOSED** — residual `DS*` ≈ **1** (doc comment only); `Prism*` ≈ **1219** |
| Compile ERRORs in scoped package `lib/` | **None** (all four packages EXIT 0, 0 ERROR) |
| Lint INFO debt | **Open inventory** — prefer_const_*, deprecated `withOpacity`, minor style (UI lib **24** INFO @ 2026-07-17) |

Flutter SDK **is installed**. Historical “SDK missing” claims are superseded.

### Residual honesty (what remains open)

| Residual | Live state | In-scope for 0010? |
|---|---|---|
| Lint INFO (obs 53, UI 28) | Documented; not cleaned | Inventory only — **no** product lint cleanup under this task ID |
| Full `flutter test` package-green | **Not claimed** | Out of scope unless a later gate re-runs suites |
| `DSTaskCard` doc-comment residual | 1 comment reference | Not a compile ERROR |
| Dependent tasks 0011–0013 | Must revalidate against monorepo paths / residual scope | Impact table only |

---

## 2. Flutter / Dart SDK (Live)

```text
$ command -v flutter
/home/sephiroth/flutter/bin/flutter

$ flutter --version
Flutter 3.44.1 • channel stable • https://github.com/flutter/flutter.git
Framework • revision 924134a44c (6 weeks ago) • 2026-05-29 12:13:22 -0400
Engine • hash 39b1f7043775b9578bbb26a1676e79c4e31c8b5e (revision c416acfeb8) (1 months ago) • 2026-05-27 20:19:31.000Z
Tools • Dart 3.12.1 • DevTools 2.57.0

$ dart --version
Dart SDK version: 3.12.1 (stable) (Tue May 26 01:02:21 2026 -0700) on "linux_x64"
```

---

## 3. Workspace Topology (Live)

```text
$ test -d lib && echo ROOT_LIB:EXISTS || echo ROOT_LIB:ABSENT
ROOT_LIB:ABSENT

$ find . -maxdepth 3 -name pubspec.yaml
./packages/warp_prism_ui/pubspec.yaml
./apps/observatory/pubspec.yaml
./apps/catalog/pubspec.yaml
./apps/cybercore/pubspec.yaml
./pubspec.yaml   # Melos workspace root only
```

Root `pubspec.yaml` is workspace orchestration (`melos`, scripts `analyze` / `test` / `validate`). It is **not** an application package with `lib/main.dart`.

### Bootstrap entrypoints (live)

Historical audit claimed missing root `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`.
**Those historical paths are gone.** Current observatory bootstrap **exists**:

```text
EXISTS: apps/observatory/lib/main.dart
EXISTS: apps/observatory/lib/app/app.dart
EXISTS: apps/observatory/lib/app/router.dart
EXISTS: apps/observatory/lib/app/app_shell.dart
```

### Dart file counts (live)

| Path | `*.dart` count |
|---|---:|
| `apps/observatory/lib` | 109 |
| `packages/warp_prism_ui/lib` | 86 |
| `apps/catalog/lib` | 1 |
| `apps/cybercore/lib` | 16 |

### Test directories (presence inventory only — full `flutter test` not claimed green)

| Path | `*.dart` | `*_test.dart` |
|---|---:|---:|
| `apps/observatory/test` | 40 | 40 |
| `packages/warp_prism_ui/test` | 42 | 40 |
| `apps/catalog/test` | 1 | 1 |
| `apps/cybercore/test` | 2 | 2 |
| **Totals** | **85** | **83** |

UI non-`*_test.dart` support files under `test/`:

- `packages/warp_prism_ui/test/performance/virtual_scroll_benchmark.dart`
- `packages/warp_prism_ui/test/boundaries/contamination_probe.dart`

This task **does not** claim `flutter test` package-green. Presence inventory is recorded above; expensive full re-run remains out of audit scope unless a later gate task requires it.

---

## 4. Live Analyzer Baseline (2026-07-10 re-inventory)

Commands used (scoped, safe; session env: `HOME=$PWD/tmp/home`, `PUB_CACHE=$PWD/tmp/pub-cache`, `FLUTTER_SUPPRESS_ANALYTICS=true`):

```bash
cd apps/observatory && dart analyze --format=machine lib
cd packages/warp_prism_ui && dart analyze --format=machine lib
cd apps/catalog && dart analyze --format=machine lib
cd apps/cybercore && dart analyze --format=machine lib
```

Machine outputs archived in-repo (not host `/tmp`):

- `tmp/0010-live-baseline/observatory.machine.txt` (+ `.human.txt`, `.exit.txt`)
- `tmp/0010-live-baseline/ui.machine.txt`
- `tmp/0010-live-baseline/catalog.machine.txt`
- `tmp/0010-live-baseline/cybercore.machine.txt`

### 4.1 `apps/observatory/lib` — compile GREEN / lint INFO baseline

| Metric | Count |
|---|---:|
| Machine lines | 52 |
| ERROR | **0** |
| WARNING | **0** |
| INFO | **52** |
| Process exit | **0** |

Human summary line: `52 issues found.` (all info severity, 2026-07-17).

**INFO codes:**

| Code | Count |
|---|---:|
| `PREFER_CONST_CONSTRUCTORS` | 45 |
| `PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES` | 6 |
| `UNNECESSARY_IMPORT` | 1 |
| `DANGLING_LIBRARY_DOC_COMMENTS` | 1 |

**Top INFO files:**

| File | INFO count |
|---|---:|
| `lib/features/operate/operate_workspace_view.dart` | 16 |
| `lib/features/operate/operate_task_detail_mapper.dart` | 9 |
| `lib/features/governance/presentation/widgets/governance_issue_group.dart` | 6 |
| `lib/features/operate/operate_task_detail_panel.dart` | 6 |
| `lib/data/parsers/workspace_markdown_parser.dart` | 4 |
| `lib/features/governance/presentation/widgets/governance_issue_filters.dart` | 4 |
| `lib/features/history/presentation/history_page.dart` | 3 |

**DS\* residual (live):**

```text
$ rg -o '\bDS[A-Z][A-Za-z]+\b' apps/observatory/lib --glob '*.dart' | wc -l
1
# apps/observatory/lib/data/models/task_projection.dart:14
# /// Contains all fields required by [DSTaskCard] and the inspector,

$ rg -o '\bPrism[A-Z][A-Za-z]+\b' apps/observatory/lib --glob '*.dart' | wc -l
1219
```

### 4.2 `packages/warp_prism_ui/lib` — compile GREEN / lint INFO baseline

| Metric | Count |
|---|---:|
| Machine lines | 24 |
| ERROR | **0** |
| WARNING | **0** |
| INFO | **24** |
| Process exit | **0** |

Human summary line: `24 issues found.` (2026-07-17) — **not package-clean under lint rules**, but **no compile ERROR**.

**INFO codes:**

| Code | Count |
|---|---:|
| `PREFER_CONST_CONSTRUCTORS` | 14 |
| `DEPRECATED_MEMBER_USE` | 12 (`withOpacity` → prefer `withValues`) |
| `PREFER_CONST_DECLARATIONS` | 3 |
| `PREFER_CONST_LITERALS_TO_CREATE_IMMUTABLES` | 1 |
| `PREFER_FINAL_FIELDS` | 1 |

**Top INFO files:**

| File | INFO count |
|---|---:|
| `lib/src/organisms/tab_bar/ds_tab_bar.dart` | 9 |
| `lib/src/organisms/command_palette/ds_command_palette.dart` | 8 |
| `lib/src/organisms/split_pane/ds_split_pane.dart` | 4 |
| `lib/src/templates/master_detail_template.dart` | 4 |
| `lib/src/organisms/ds_lane_board.dart` | 3 |
| `lib/src/organisms/ds_detail_inspector.dart` | 2 |
| `lib/src/organisms/ds_timeline.dart` | 1 |

### 4.3 `apps/catalog/lib` and `apps/cybercore/lib`

Both scoped machine analyzes produced **0 lines / 0 issues**, process exit **0**.

```text
Analyzing lib...
No issues found!
```

---

## 5. Taxonomy (Live failure classes)

| Class | Live evidence | Package impact |
|---|---|---|
| **A. Bootstrap missing** | Historical only (root `lib/main.dart` etc.) | Superseded — observatory bootstrap files exist |
| **B. Naming/API contract drift (`DS*` vs `Prism*`)** | Mid-wave primary RED; live residual is **1 doc comment** | **CLOSED as compile class** |
| **C. Design-system / app lint debt** | UI **24** INFO; observatory **52** INFO | Non-blocking for compile of scoped `lib/` |
| **D. Docs / inventory currency drift** | Prior report claimed 920 ERROR, then 69/75 INFO after packages greened | Process risk — re-run analyze before quoting |
| **E. Full test gate** | 85 test `*.dart` present; full `flutter test` green **not claimed** | Out of scope for this audit refresh |

---

## 6. Dependent task impact

| Task | Historical / mid-wave claim | Live implication |
|---|---|---|
| **0011 bootstrap main/router/shell** | Create root `lib/main.dart` etc. | Paths must be monorepo (`apps/observatory/lib/...`). Bootstrap files **already exist**; 0011 scope needs independent revalidation — not “missing main.dart”. |
| **0012 DS API normalization** | Fix Ds\* vs DS\* / body vs content; mid-wave: migrate apps `DS*` → `Prism*` | **Primary compile migration appears closed** in observatory `lib/` (comment-only residual). 0012 should re-scope against residual comment/docs/internal DS\* package names, not a 900+ ERROR consumer surface. |
| **0013+** | Depend on “baseline” | Treat this report as **compile-green scoped lib inventory + lint INFO debt**, not as RED ERROR baseline and not as monorepo test-green. |

---

## 7. Historical Snapshot (2026-06-07) — SUPERSEDED

> The section below is retained as historical record only.
> Root `lib/` no longer exists. Counts and missing-file claims are **not** live truth.

### 7.1 Historical executive claims (non-reproducible)

- Root Flutter app with ~40 Dart files under `lib/design_system/` + `lib/data/`
- Missing: `lib/main.dart`, `lib/app/app.dart`, `lib/app/router.dart`, `test/`
- Flutter SDK reported unavailable in original executor environment
- Naming: no `Ds*` (lowercase s) mismatches; all `DS*` consistent in that tree
- `draft.md` body/content and DsShell claims did not match that tree
- `flutter analyze` / `flutter test` were **never successfully captured** for that root app state

### 7.2 Historical evidence status

| Historical claim | Status after monorepo migration |
|---|---|
| 40-file root `lib/` inventory | **Non-reproducible** (`ROOT_LIB:ABSENT`) |
| Missing root bootstrap files | **Superseded** by monorepo paths |
| SDK not installed | **Superseded** (Flutter 3.44.1 present) |
| Exact historical `flutter analyze` output | **Never captured** — do not invent |
| Exact historical `flutter test` output | **Never captured** — do not invent |

### 7.3 Mid-wave RED inventory (earlier 2026-07-09) — SUPERSEDED

A builders refresh documented observatory machine analyze as **962 issues (920 ERROR, 7 WARNING, 35 INFO)** with primary class `UNDEFINED_IDENTIFIER` on `DSColors` / `DSSpacing` / etc.

Independent re-review (40/100) and later re-runs show that surface is **gone**:

| Mid-wave claim | Live re-run (2026-07-10) |
|---|---|
| Observatory 920 ERROR | **0 ERROR / 53 INFO / EXIT 0** |
| UI 82 issues (1 WARNING) | **31 INFO / 0 ERROR / 0 WARNING / EXIT 0** |
| Primary class DS\* vs Prism\* | **CLOSED** (comment residual only) |
| Observatory lib 106 files | **109** |
| UI lib 85 files | **86** |

### 7.4 Prior INFO snapshot (2026-07-09 compile-green) — SUPERSEDED for exact INFO totals

| Prior claim (2026-07-09) | Live re-run (2026-07-10) |
|---|---|
| Observatory 69 INFO | **53 INFO** |
| UI 75 INFO | **31 INFO** |
| Observatory lib 108 | **109** |
| Prism\* ≈ 1255 | **1219** |
| 0 ERROR / EXIT 0 | **Unchanged (still true)** |

Do **not** cite mid-wave RED counts or the 69/75 INFO snapshot as current package health.

### 7.5 Changelog path drift

Executor originally claimed `docs/changelog/2026-06-07-task-0010-foundation-audit.md`.
That path is **ABSENT**. Existing related notes:

- `docs/changelog/20260607-210444-0000-2026-06-07-task-0010-foundation-audit-repair-bot.md`
- `docs/changelog/2026-06-29-task-0010-foundation-audit-migration-reclassification.md`
- `docs/changelog/2026-07-09-task-0010-live-monorepo-baseline-inventory.md` (mid-wave RED story — payload obsolete)
- `docs/changelog/2026-07-09-task-0010-live-compile-green-baseline-reinventory.md` (prior 69/75 INFO snapshot — INFO totals obsolete)
- `docs/changelog/2026-07-10-task-0010-live-info-currency-reinventory.md` (this INFO currency refresh)

---

## 8. What this task is / is not

### Is

- A foundation **audit / inventory** of compile and layout baseline evidence
- Honest **live** package-scoped analyzer counts (ERROR/WARNING/INFO + exit codes)
- Explicit classification that **mid-wave package RED is superseded** and live scoped `lib/` is compile-green
- Dependency guidance for 0011/0012 against monorepo reality

### Is not

- A product-code migration or lint cleanup under this task ID
- Proof that `flutter test` / Melos validate pass monorepo-wide
- Authorization to rewrite product code under this task ID
- A claim that historical root-app inventory, mid-wave 920 ERROR, or prior 69/75 INFO is still live

---

## 9. Evidence command table (Live 2026-07-10 re-inventory)

| Command | Result (literal summary) |
|---|---|
| `command -v flutter && flutter --version` | Flutter 3.44.1 / Dart 3.12.1 |
| `test -d lib` | `ROOT_LIB:ABSENT` |
| `test -f apps/observatory/lib/main.dart` (and app/router) | All `EXISTS` |
| `find apps/observatory/lib -name '*.dart' \| wc -l` | `109` |
| `find packages/warp_prism_ui/lib -name '*.dart' \| wc -l` | `86` |
| `find apps/catalog/lib -name '*.dart' \| wc -l` | `1` |
| `find apps/cybercore/lib -name '*.dart' \| wc -l` | `16` |
| `find apps/observatory/test -name '*.dart' \| wc -l` | `40` |
| `find packages/warp_prism_ui/test -name '*.dart' \| wc -l` | `42` (40 `*_test.dart`) |
| `dart analyze --format=machine` (from `apps/observatory`, target `lib`) | 53 lines: ERROR 0 / WARNING 0 / INFO 53; EXIT 0 |
| `dart analyze lib` (observatory human) | `53 issues found.`; EXIT 0 |
| `dart analyze --format=machine` (from `packages/warp_prism_ui`, target `lib`) | 31 lines: ERROR 0 / WARNING 0 / INFO 31; EXIT 0 |
| `dart analyze lib` (UI human) | `31 issues found.`; EXIT 0 |
| `dart analyze --format=machine` (catalog `lib`) | 0 issues; EXIT 0 |
| `dart analyze --format=machine` (cybercore `lib`) | 0 issues; EXIT 0 |
| `rg` DS\* / Prism\* in observatory lib | DS\* **1** (comment); Prism\* **1219** |
| Full monorepo `flutter test` / Melos validate | **Not re-run this pass**; package-test-green not claimed |

---

## 10. Review lineage pointers

| Report | Score / verdict | Note |
|---|---|---|
| `docs/reports/build-gate-review/0010-review.md` | 100/100 APPROVED | **Stale** — treated blocked SDK as complete |
| `docs/reports/review-wave-3/0010-review.md` | 58/100 REJECTED_TO_DOING | Historical vs current ambiguity |
| Task Review Ledger 2026-06-30 | 42/100 REJECTED | Live package red + stale root `lib/` evidence |
| Builders mid-wave rewrite (earlier 2026-07-09) | Self 100 as RED inventory | **Superseded** — counts became stale after Prism migration |
| `docs/reports/review-wave-2026-07-09/task-0010-foundation-audit-analyzer-baseline-independent-rereview.md` | **40/100 REJECTED_TO_DOING** | Inventory not live-current vs 0 ERROR |
| Builders compile-green rewrite (2026-07-09) | Self 100 as live 69/75 INFO | **Superseded for INFO totals** — S=86 hold 2026-07-10 |
| `docs/reports/review-wave-2026-07-10/path-to-100-mass-rereview.md` | **86/100 NEEDS_FIX** | Claimed 69/75 INFO; live 53/31 |
| This refresh (2026-07-10 INFO currency) | Honest **compile-green + exact INFO** baseline | Test-green still out of scope |
| `docs/reports/review-wave-2026-07-10/task-0010-foundation-audit-info-currency-rereview.md` | **100/100 PASS** | Live re-run matches 53/31; promoted to `03-review/` |

---

*Live currency refresh by builders 2026-07-10 after S=86/100 re-review. Independent re-review 2026-07-10 S=100 confirmed exact INFO. Scoped package `lib/` analyze is 0 ERROR; INFO totals are 53 (observatory) and 31 (UI). Do not promote as monorepo test-green. Do not re-cite mid-wave 920 ERROR or prior 69/75 INFO as live.*
