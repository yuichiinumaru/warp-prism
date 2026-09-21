# Review Report: Task 1107 — Melos Monorepo Migration — 2026-06-17

## Review Lineage

- **Current task**: Task 1107 (`warp-prism-melos-monorepo-migration`), reviewed at `docs/tasks/03-review/1107-warp-prism-melos-monorepo-migration.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/1107-review.md` — prior 100/100 approval.
- **Related reports considered**:
  - `docs/reports/build-gate-review/1104-review.md` — prerequisite architecture task rejected and returned to doing.
  - `docs/reports/build-gate-review/1101-review-2026-06-17.md` and `docs/reports/build-gate-review/1102-review-2026-06-17.md` — upstream prerequisite chain rejected.
- **Review mode**: independent re-review / live workspace gate.

## Score And Verdict

- **Score**: `24/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: Flutter and Dart tooling are available live (`flutter --version` and `dart --version` pass).
- `RESOLVED`: Package/app directories and pubspec files exist for `packages/warp_prism_ui`, `apps/observatory`, `apps/catalog`, and `apps/cybercore`.

### Persistent Findings

- None were recorded in the previous report.

### Regressions

- `REGRESSION`: The required `melos.yaml` file is absent, despite the task and previous report marking the exit condition complete.
- `REGRESSION`: Fresh workspace commands fail before Melos/analyze/test can execute because the workspace glob captures nested `tmp/pub-cache` packages.

### New Findings

- `NEW`: The task depends on Task 1104, which is rejected and currently in `02-doing` with a Builder Done/lane-state defect.
- `NEW`: Completion evidence claims `melos bootstrap`, analyze, and test outcomes that are not reproducible today.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: Prior test/analyze pass evidence is stale and non-reproducible in the live checkout.

## Findings

| ID | Class | Severity | Status | Summary | Evidence |
| --- | --- | --- | --- | --- | --- |
| F1 | REGRESSION | Critical | Open | Required root `melos.yaml` does not exist. Task 1107 explicitly requires it, and the prior report marked it PASS, but fresh file check exits 1 and `Read` reports file not found. | `docs/tasks/03-review/1107-warp-prism-melos-monorepo-migration.md:51,85`; `docs/reports/build-gate-review/1107-review.md:27`; fresh command `test -f melos.yaml` exit=1; `pubspec.yaml:14-58` contains Melos config but does not satisfy the `melos.yaml` exit condition |
| F2 | REGRESSION | Critical | Open | The migrated workspace is not live-validatable. The root workspace globs `packages/**` and `apps/**`, so nested `apps/observatory/tmp/pub-cache/.../pubspec.yaml` files are treated as workspace members and break `dart pub get`, `flutter analyze`, `dart run melos run analyze`, and `dart run melos run test`. | `pubspec.yaml:7-12`; fresh command output: `apps/observatory/tmp/pub-cache/hosted/pub.dev/flutter_lints-4.0.0/pubspec.yaml is included in the workspace ... but does not have resolution: workspace` |
| F3 | EXTERNAL_BLOCKER | High | Open | Declared prerequisite Task 1104 is rejected and returned to doing, so the migration cannot be accepted as an implementation of an accepted architecture plan. | `docs/tasks/03-review/1107-warp-prism-melos-monorepo-migration.md:9`; `docs/tasks/02-doing/1104-warp-prism-melos-monorepo-architecture-plan.md:3-4,137-144`; `docs/reports/build-gate-review/1104-review.md:23-54` |
| F4 | EVIDENCE_GAP | Medium | Open | Completion evidence and previous report claim `melos bootstrap`, analyze, and test pass/partial results that are stale and cannot be reproduced in the live checkout. | `docs/tasks/03-review/1107-warp-prism-melos-monorepo-migration.md:153-165`; `docs/reports/build-gate-review/1107-review.md:17-20,31-33`; fresh commands above |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/1107-warp-prism-melos-monorepo-migration.md`.
- Where-table artifacts: architecture plan, root `pubspec.yaml`, package/app pubspecs, catalog app entrypoint, UI package public barrel, current directory tree.
- Previous and prerequisite reports listed above.
- Runtime wiring proof: `apps/catalog/lib/main.dart` imports `package:warp_prism_ui/warp_prism_ui.dart`; app/package directories exist. The monorepo orchestration itself is not currently validatable.
- Commands run:
  - `flutter --version; dart --version` — PASS, Flutter 3.44.1 / Dart 3.12.1.
  - `test -f melos.yaml` — FAIL, exit 1.
  - `PUB_CACHE="$PWD/tmp/pub-cache" dart pub get` — FAIL, workspace nested pub-cache inclusion.
  - `PUB_CACHE="$PWD/tmp/pub-cache" dart run melos run analyze` — FAIL, same workspace nested pub-cache inclusion.
  - `PUB_CACHE="$PWD/tmp/pub-cache" dart run melos run test` — FAIL, same workspace nested pub-cache inclusion.
  - `PUB_CACHE="$PWD/tmp/pub-cache" flutter analyze` — FAIL, same workspace nested pub-cache inclusion.
  - `bash .agents/skills/project-management/sub-skills/manage-changelog/scripts/rebuild.sh validate` — FAIL on unrelated `1302-public-barrel-audit.md` missing `timestamp`.

## Path To 100

1. Repair/re-approve Task 1104 first, then align the migration with the accepted architecture.
2. Add the required root `melos.yaml` or formally amend Task 1107 and all dependent docs/reports to use `pubspec.yaml`-embedded Melos configuration instead; until then the explicit exit condition is false.
3. Fix workspace globs/cache placement so repository-local `tmp/pub-cache` directories are not included as Dart workspace members, then rerun `dart pub get`.
4. Re-run `melos bootstrap`, `melos run analyze`, and `melos run test` from the root with `PUB_CACHE` inside the repository and record exact outputs.
5. Update completion evidence and previous claims to distinguish true passes from pre-existing failures and current workspace blockers.

## Task Ledger Patch Suggestion

Add a latest-review entry with score `24/100`, verdict `REJECTED_TO_DOING`, this report path, F1-F4, live command failures, dependency blocker, and the path-to-100 above. Preserve `docs/reports/build-gate-review/1107-review.md` as previous-report lineage.
