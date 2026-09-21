# Warp Prism OOM Risk and Safe Execution Plan

> **Date**: 2026-06-26
> **Author**: builders
> **Scope**: Read-only investigation of CPU/RAM crash risk before remediation waves
> **Method**: No Flutter, Dart, Melos, build, test, analyze, or coverage commands were executed. Findings are based on task files, reports, root script config, and read-only investigator packets.

---

## Executive Summary

Warp Prism has enough evidence to treat broad validation commands as unsafe on a constrained workstation. The likely crash/OOM triggers are not one single daemon, but a combination of unbounded Melos scripts, full Flutter test/analyze runs, golden rendering, coverage instrumentation, stale build artifacts, and very large UI/gallery test surfaces.

Do **not** run these until the repo has a safe execution profile:

- `dart run melos run validate`
- `dart run melos run test`
- `dart run melos run analyze`
- `dart run melos run test-ui`
- `flutter test` from package/app roots without a narrow path
- `flutter test --coverage`
- `flutter test test/goldens/`
- `flutter analyze lib/` on the whole UI package
- `flutter test apps/observatory/`
- `flutter analyze apps/observatory/`

Safe or comparatively safe commands are currently limited to pure-Dart probes and narrow file/path checks, especially:

- `dart run melos run test-boundaries`
- `dart run melos run test-contamination`
- `dart format --output=none --set-exit-if-changed <small-path>`
- `dart analyze <single-file-or-small-lib-path>`
- focused `flutter test --no-pub <single test file or narrow directory>` when needed

---

## Existing Evidence That Still Matters

Useful planning artifacts already exist:

- `docs/dependency-tree.md` — corrected stabilization dependency order.
- `docs/reports/warp-prism-stabilization-strategy.md` — stabilization strategy context.
- `docs/reports/warp-prism-review-backlog-snapshot.md` — lane/review state snapshot.
- `docs/reports/warp-prism-test-failure-baseline.md` — current-ish failure baseline.
- `docs/reports/observatory-failure-baseline.md` — historical Observatory 64-failure baseline.
- `docs/reports/corpus-frontmatter-audit.md` — corpus/frontmatter/parser evidence.
- `docs/reports/build-gate-review/*` and `docs/reports/review-wave-*/*` — review return evidence.

Important caveat: many old reports include stale success claims. Treat independent rejection reports and current task review ledgers as higher-signal than early `100/100` build-gate claims.

---

## Confirmed High-Risk Surfaces

### 1. Root Melos Scripts

Root `pubspec.yaml` defines broad scripts with no resource caps:

- `analyze`: `dart run melos exec --dir-exists=lib -- flutter analyze`
- `test`: `dart run melos exec --dir-exists=test -- flutter test`
- `validate`: `format && analyze && test`
- `test-ui`: full UI package tests
- `test-observatory`: full Observatory tests
- `test-fast`: narrower than `test-ui`, but still runs a large UI subset plus CyberCore

Risks:

- No `--concurrency` cap.
- No sharding.
- Melos workspace globs include `packages/**` and `apps/**`, so nested cache/pubspec contamination can explode resolution.
- Broad analyzer/test commands are known to fail already, causing wasted CPU/RAM.

### 2. `packages/warp_prism_ui`

Risk drivers:

- `lib/src/gallery/design_system_gallery_sections.dart` is a very large compile unit (~3k lines) and currently appears in multiple task blockers.
- Golden suite renders and compares many PNGs; prior evidence shows 50+ golden tests and failure artifacts.
- `flutter test --coverage` instruments thousands of lines and should be considered maximum-risk.
- Full package analyze has hundreds/thousands of low-signal info diagnostics in reports.
- `test-fast` and catalog/CyberCore can still be blocked by gallery compile errors.

Current critical blocker from review evidence:

- `SingleChildScrollView(shrinkWrap: true)` in `design_system_gallery_sections.dart` is invalid and breaks compile paths used by multiple Melos scripts.

### 3. `apps/observatory`

Risk drivers:

- Full Observatory test suite is large and historically had 64 failures, later narrowed but still stale.
- `apps/observatory/build/` was reported around 51MB by investigator evidence.
- `apps/observatory/tmp/pub-cache` contamination has repeatedly broken workspace resolution in task ledgers.
- Several Observatory tests parse/project large mock corpora or render large detail variants.

Safe pattern in existing evidence:

- Narrow `flutter test --no-pub <specific directory/file>` has been used successfully in reports and avoids pub resolution contamination.

### 4. Historical Backlog Tasks

The historical clusters (`000x`, `001x`, `031x`, `041x`, etc.) repeatedly show this pattern:

1. Early build review claimed `100/100`.
2. Later independent review rejected with lower score.
3. Many tasks contain stale path claims from pre-melOS or pre-monorepo layouts.
4. Many validation commands are broad (`flutter analyze`, `flutter test`, `melos run analyze/test`).

These tasks should not be mass-revalidated with broad commands. They need report-driven, narrow, dependency-aware repair waves.

---

## Safe Execution Policy Before Any Remediation Wave

### Prohibited by default

Do not run unless explicitly unlocked by the user:

```bash
dart run melos run validate
dart run melos run test
dart run melos run analyze
dart run melos run test-ui
dart run melos run test-observatory
flutter test
flutter test --coverage
flutter test test/goldens/
flutter analyze lib/
flutter analyze apps/observatory/
```

### Allowed low-risk probes

```bash
dart run melos run test-boundaries
dart run melos run test-contamination
dart format --output=none --set-exit-if-changed <small-path>
dart analyze <single-file-or-small-path>
rg <pattern> <bounded-path>
```

### Conditional medium-risk probes

Only after confirming the target task scope and avoiding broad package roots:

```bash
flutter test --no-pub <single-test-file>
flutter test --no-pub <small-test-directory>
flutter analyze <single-file-or-small-lib-path>
```

### Recommended environment limits

If tests must run later, use a constrained shell profile:

```bash
HOME="$PWD/tmp/home" \
PUB_CACHE="$PWD/tmp/pub-cache" \
TMPDIR="$PWD/tmp" \
flutter test --concurrency=1 --no-pub <single-test-file>
```

For Melos commands that support it, prefer explicit scopes and serial execution:

```bash
dart run melos exec --concurrency=1 --scope <package-name> -- <command>
```

---

## Remediation Roadmap Impact

Before fixing the codebase broadly, the next roadmap must include an explicit Phase -1:

### Phase -1 — Machine Safety / OOM Prevention

1. Freeze broad validation commands.
2. Use only read-only investigators and report parsing for planning.
3. Cleanly classify commands into safe / conditional / prohibited.
4. Require `--no-pub`, `--concurrency=1`, and explicit paths for any Flutter test that must run.
5. Treat `test-boundaries` and `test-contamination` as safe preflights.
6. Defer coverage and goldens until the compile/test graph is stable.

Only after Phase -1 should builder remediation waves start.

---

## Immediate Dependency Implications

Most urgent technical blockers from evidence:

1. `1304` gallery compile cleanup is blocking `1204`, `1305`, and package-level proof because of `design_system_gallery_sections.dart` compile/analyzer debt.
2. `1303` component contract reconciliation remains a core ADS blocker for `1304`, `1306`, `1307`, `1309`.
3. `1305` catalog expansion has real review findings but should not be fixed via broad catalog/full UI runs; use targeted test edits and narrow catalog commands only.
4. `1401-1408` Observatory remediation should use `--no-pub` scoped tests and treat the old 64-failure baseline as historical unless refreshed safely.
5. Historical backlog needs report-driven triage before any command execution.

---

## Open Questions for User / Next Planning Step

1. Do you want me to create a permanent `docs/reports/builders/remediation-roadmap.md` that incorporates this OOM policy plus the dependency tree?
2. Should we add a repository-local `safe-test` / `safe-analyze` script later, or keep this as operator guidance only for now?
3. Are broad commands completely forbidden until you explicitly unlock them, or should agents be allowed to run safe narrow Flutter tests with `--concurrency=1 --no-pub`?

---

## Bottom Line

The machine crash risk is real and documented by existing evidence. The next remediation plan should be built around **narrow, serial, path-scoped validation** and should avoid broad Melos/Flutter commands until the compile blockers and stale task evidence are resolved.
