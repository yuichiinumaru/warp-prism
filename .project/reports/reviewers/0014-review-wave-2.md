# Review Report: Task 0014 — DS Token Contract and Inventory — 2026-06-14

## Review Lineage

- **Current task**: Task 0014 (`0014-warp-prism-ds-token-contract-and-inventory`); live path `docs/tasks/03-review/0014-warp-prism-ds-token-contract-and-inventory.md`.
- **Previous reports read**:
  - `docs/reports/build-gate-review/0014-review.md` — 100/100, approved, but accepted stale missing-SDK validation and treated deferred changelog as pass.
- **Related reports considered**:
  - `docs/reports/warp-prism-ds-inventory.md` — task deliverable and mismatch ledger.
  - `docs/reports/build-gate-review/0013-review.md` — same stale environment-blocked pattern.
  - `docs/reports/build-gate-review/0015-review.md` — downstream atoms/molecules task depending on this contract.
- **Review mode**: `re-review` / final gate.

## Score And Verdict

- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Lane recommendation**: `return-to-doing`

The token contract test passes and the inventory exists, but the task cannot be approved because its analyzer exit condition is not met under the now-available Flutter/Dart toolchain. The token scope itself has exactly 12 analyzer info-level issues, and the whole package gate has exactly 592 analyzer issues. The report also carries stale naming truth: the inventory declares `DS*` as canonical, while the current package public API is `Prism*` aliases over internal `DS*` classes.

## Axiom Compliance

| Axiom | Status | Evidence |
| --- | --- | --- |
| Analyzer Integrity | FAIL | `flutter analyze --no-pub` in `packages/warp_prism_ui/` exits 2 with exactly 592 issues: 0 errors, 11 warnings, 581 infos. Token scope has exactly 12 infos: 11 `DEPRECATED_MEMBER_USE` in `lib/src/tokens/ds_shadows.dart` and 1 `DANGLING_LIBRARY_DOC_COMMENTS` in `lib/src/tokens/ds_motion.dart`. |
| Lifecycle Safety | PASS | Token contract/inventory task introduces no controllers/subscriptions/timers/listeners. Task-owned lifecycle count: 0 controllers, 0 subscriptions, 0 timers, 0 listeners, 0 disposal requirements. |
| Dependency Direction | PASS | Token files remain package-local and do not import presentation apps. Public package alias direction is implementation `DS*` -> public `Prism*` typedefs via `lib/src/prism_aliases.dart`; no domain/data/presentation layers are introduced. |
| UI Accessibility | PARTIAL | Token task is not a widget task, but it defines colors/shadows/typography that downstream accessibility relies on. No automated contrast proof exists in Task 0014. Interactive widgets introduced by this task: 0. Semantics widgets required by this task: 0. |
| Proof Reality | PARTIAL | Targeted token tests pass: 36 token contract tests within the 136-test targeted run. Analyzer does not pass, and old review claimed SDK unavailable despite current executable tooling. Changelog evidence is absent. |
| Release Security | PASS | No secrets, network endpoints, prints, signing, or release paths introduced. |

## Delta Summary

### Resolved Since Previous Review

- `RESOLVED`: The token contract test file exists at `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart` and participates in the passing targeted test run.
- `RESOLVED`: Public package naming has a current bridge: `packages/warp_prism_ui/lib/warp_prism_ui.dart:21` exports `src/prism_aliases.dart`, and `packages/warp_prism_ui/lib/src/prism_aliases.dart:1-14` documents `Prism*` public aliases over internal `DS*` implementation classes.

### Persistent Findings

- `PERSISTENT`: Analyzer gate is still not clean. The previous review treated missing SDK as environmental; current package analyzer produces deterministic issues.
- `PERSISTENT`: Changelog evidence remains missing. Task exit condition says changelog added at `docs/tasks/03-review/0014...md:53`, but completion evidence says N/A at `docs/tasks/03-review/0014...md:121`, and `docs/changelog/**/*0014*` returned 0 files.

### Regressions

- `REGRESSION`: The previous 100/100 report accepted `flutter test test/design_system/tokens/` as pass while no SDK validation had run. Current targeted test path is `test/tokens/ds_token_contract_test.dart`, not the stale task path.

### New Findings

- `NEW`: Inventory naming contract is stale relative to the public package contract. `docs/reports/warp-prism-ds-inventory.md:81-96` says `DS*` is canonical, while `README.md:55-69` and `packages/warp_prism_ui/lib/src/prism_aliases.dart:1-14` say public ADS components use `Prism*` and internal `DS*` classes are hidden implementation aliases.
- `NEW`: Token scope has exact analyzer debt: `lib/src/tokens/ds_motion.dart:1:1` dangling library doc comment and 11 deprecated `withOpacity` uses in `lib/src/tokens/ds_shadows.dart`.

### Evidence Gaps / External Blockers

- `EVIDENCE_GAP`: No current clean analyzer proof exists for the task or package.
- `EVIDENCE_GAP`: No ThemeData/ThemeExtension bridge verification was added by this task despite the objective/test requirement at `docs/tasks/03-review/0014...md:41`.
- `EXTERNAL_BLOCKER`: None. Flutter/Dart tooling is available.

## Findings

| ID | Class | Severity | Status | Summary | First seen | Evidence |
| --- | --- | --- | --- | --- | --- | --- |
| F1 | PERSISTENT | MODERATE | Open | Analyzer integrity fails for the package and has token-scope issues directly inside Task 0014 files. | 2026-06-14 wave-2 | `flutter analyze --no-pub` => 592 issues, exit 2; token scope: `lib/src/tokens/ds_motion.dart:1:1`, `lib/src/tokens/ds_shadows.dart:36:34`, `:41:34`, `:50:36`, `:55:36`, `:64:34`, `:69:34`, `:78:37`, `:87:35`, `:96:37`, `:109:24`, `:111:24`. |
| F2 | NEW | MODERATE | Open | Inventory declares stale canonical naming (`DS*`) and conflicts with the current public `Prism*` alias contract. | 2026-06-14 wave-2 | `docs/reports/warp-prism-ds-inventory.md:81-96`; `README.md:55-69`; `packages/warp_prism_ui/lib/warp_prism_ui.dart:21`; `packages/warp_prism_ui/lib/src/prism_aliases.dart:1-14`, `:99-140`, `:146-149`, `:179-209`, `:229-392`. |
| F3 | PERSISTENT | LOW | Open | Required changelog evidence is inconsistent/missing. | Task handoff / 2026-06-13 review missed it | `docs/tasks/03-review/0014...md:53` claims checked; `docs/tasks/03-review/0014...md:121` says N/A; `docs/changelog/**/*0014*` returned 0 files. |
| F4 | EVIDENCE_GAP | MODERATE | Open | Theme bridge requirement is documented as needed but not proven by code/test. | Task definition | Requirement at `docs/tasks/03-review/0014...md:41`; active gap at `docs/tasks/03-review/0014...md:149-152`; no ThemeData/ThemeExtension verification in `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart:1-422`. |
| F5 | REGRESSION | LOW | Open | Previous review artifact overstated test/analyzer status and used stale paths/counts. | 2026-06-14 wave-2 | Previous report `docs/reports/build-gate-review/0014-review.md:27-29` treats SDK blocker/test creation as pass; actual targeted path is `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`, and package analyzer fails. |

## Evidence Reviewed

- Task file: `docs/tasks/03-review/0014-warp-prism-ds-token-contract-and-inventory.md`.
- Previous report: `docs/reports/build-gate-review/0014-review.md`.
- Deliverable: `docs/reports/warp-prism-ds-inventory.md`.
- Source/test files:
  - `packages/warp_prism_ui/pubspec.yaml`
  - `packages/warp_prism_ui/analysis_options.yaml`
  - `packages/warp_prism_ui/lib/warp_prism_ui.dart`
  - `packages/warp_prism_ui/lib/src/prism_aliases.dart`
  - `packages/warp_prism_ui/test/tokens/ds_token_contract_test.dart`
- Runtime wiring proof or non-runtime rationale: package API contract task. Runtime app wiring is not applicable, but public package export wiring is proven through `lib/warp_prism_ui.dart:21` -> `lib/src/prism_aliases.dart`.
- Commands run:
  - `flutter test --no-pub test/tokens/ds_token_contract_test.dart test/atoms/atoms_contract_test.dart test/molecules/molecules_contract_test.dart` from `packages/warp_prism_ui/` — PASS, exactly 136 tests passed.
  - `flutter analyze --no-pub` from `packages/warp_prism_ui/` — FAIL, exactly 592 issues: 0 errors, 11 warnings, 581 infos.
  - Analyzer scope script using `dart analyze --format=machine` — token scope exactly 12 infos, 0 warnings, 0 errors.
- Commands not run and why:
  - `flutter test test/design_system/tokens/` was not run because that path does not exist in current package layout; actual token test path is `test/tokens/ds_token_contract_test.dart`.

## Path To 100

1. Fix token-scope analyzer issues:
   - Add a `library;` directive after the library doc in `packages/warp_prism_ui/lib/src/tokens/ds_motion.dart:1`.
   - Replace all 11 deprecated `withOpacity` calls in `packages/warp_prism_ui/lib/src/tokens/ds_shadows.dart` with `withValues(alpha: ...)` preserving exact opacity semantics.
2. Align `docs/reports/warp-prism-ds-inventory.md:81-96` with current naming truth: internal implementation classes are `DS*`; public `warp_prism_ui` consumers use `Prism*` aliases exported by `lib/warp_prism_ui.dart` and defined in `lib/src/prism_aliases.dart`.
3. Add or explicitly defer with governance approval the required ThemeData/ThemeExtension bridge. If the bridge is out-of-scope now, update Task 0014's checked exit condition and mismatch ledger so it does not claim completion.
4. Add Task 0014 changelog evidence under `docs/changelog/` or correct the task exit condition to unchecked with a documented blocker.
5. Re-run `flutter analyze --no-pub` in `packages/warp_prism_ui/` and achieve 0 errors, 0 warnings, 0 infos under `analysis_options.yaml` before requesting approval.
6. Re-run `flutter test --no-pub test/tokens/ds_token_contract_test.dart` and record the exact passing count in the task ledger.

## Task Ledger Patch Suggestion

```markdown
---

## Review Ledger

> [!IMPORTANT]
> Before path-to-100 work, read the latest full report and all reports listed
> under Previous Reports. Persistent findings and regression guards are part of
> the acceptance contract; do not fix the latest finding by undoing a previously
> accepted repair.

### Latest Review

- **Date**: 2026-06-14
- **Reviewer profile**: `reviewers`
- **Score**: `78/100`
- **Verdict**: `REJECTED_TO_DOING`
- **Full report**: `docs/reports/build-gate-review/0014-review-wave-2.md`
- **Lane outcome**: `return to doing`
- **Task reference**: Task 0014 (`0014-warp-prism-ds-token-contract-and-inventory`); resolve current path from `docs/tasks/tasklist.md` or search under `docs/tasks/`

#### Current Open Blockers

- `PERSISTENT`: `flutter analyze --no-pub` in `packages/warp_prism_ui/` fails with 592 issues; token scope has 12 info-level issues.
- `NEW`: `docs/reports/warp-prism-ds-inventory.md` still declares `DS*` canonical, but public API is now `Prism*` aliases over internal `DS*` classes.
- `PERSISTENT`: Changelog evidence is missing/inconsistent.
- `EVIDENCE_GAP`: ThemeData/ThemeExtension bridge requirement is not proven.

#### Path-to-100 Summary

- Fix token analyzer infos in `ds_motion.dart` and `ds_shadows.dart`.
- Update inventory naming contract to internal `DS*` / public `Prism*` truth.
- Add or honestly defer ThemeData/ThemeExtension bridge proof.
- Add changelog evidence and re-run analyzer/test gates.

### Previous Reports

- `2026-06-13` — `100/100` — `docs/reports/build-gate-review/0014-review.md`
  - **Carried forward**: Inventory and token contract test exist.
  - **Resolved since**: Targeted token tests now actually run under available SDK as part of a 136-test passing command.
  - **Regression guard**: Do not accept stale missing-SDK analyzer/test claims; require exact current command output.
```
